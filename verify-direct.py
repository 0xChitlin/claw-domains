#!/usr/bin/env python3
"""Direct verification submission to Abstract Block Explorer API.

Works around the hardhat-zksync-verify plugin bug where zkVM bytecodes
lack CBOR metadata, causing version inference to fail.
"""

import json
import os
import urllib.request
import time
import sys

VERIFY_URL = "https://api-explorer-verify.testnet.abs.xyz/contract_verification"
EXPLORER_URL = "https://explorer.testnet.abs.xyz"

# Deployer address (used as treasury)
DEPLOYER = "0x00CC14AF7d9ce9Be4fdf9aE858632a00287edE11"

# Contract definitions: (address, source_path, contract_name, constructor_args_encoded)
# Constructor args are ABI-encoded
CONTRACTS = {
    "ClawRenderer": {
        "address": "0x90f493bfB740F00E6Cf280f4B9A6943d4b96d274",
        "source": "contracts/ClawRenderer.sol",
        "args": "0x",  # no constructor args
    },
    "ClawRegistry": {
        "address": "0x01949e45FabCD684bcD4747966145140aB4778E5",
        "source": "contracts/ClawRegistry.sol",
        # constructor(address _renderer, uint256 _mintPrice, address _treasury)
        # renderer: 0x90f493bfB740F00E6Cf280f4B9A6943d4b96d274
        # mintPrice: 500000000000000 (0.0005 ETH)
        # treasury: deployer address
        "args": None,  # Will be computed
    },
    "ClawEvolution": {
        "address": "0xed61D90c46343D0399de04a2CDEd195A217aa583",
        "source": "contracts/ClawEvolution.sol",
        # constructor(address _registry)
        "args": None,  # Will be computed
    },
    "ClawReputation": {
        "address": "0x2E031ad274261e1a58C033d61F3b0f310c419904",
        "source": "contracts/ClawReputation.sol",
        # constructor(address _registry)
        "args": None,  # Will be computed
    },
}

def encode_address(addr):
    """ABI-encode an address (pad to 32 bytes)."""
    return addr.lower().replace("0x", "").zfill(64)

def encode_uint256(val):
    """ABI-encode a uint256."""
    return hex(val)[2:].zfill(64)

def compute_constructor_args():
    """Compute ABI-encoded constructor arguments."""
    renderer_addr = CONTRACTS["ClawRenderer"]["address"]
    registry_addr = CONTRACTS["ClawRegistry"]["address"]
    
    # ClawRegistry(address _renderer, uint256 _mintPrice, address _treasury)
    CONTRACTS["ClawRegistry"]["args"] = "0x" + encode_address(renderer_addr) + encode_uint256(500000000000000) + encode_address(DEPLOYER)
    
    # ClawEvolution(address _registry)
    CONTRACTS["ClawEvolution"]["args"] = "0x" + encode_address(registry_addr)
    
    # ClawReputation(address _registry)
    CONTRACTS["ClawReputation"]["args"] = "0x" + encode_address(registry_addr)

def load_source_code():
    """Load the compiler input from build-info."""
    build_dir = "artifacts-zk/build-info"
    files = [f for f in os.listdir(build_dir) if f.endswith(".json")]
    with open(os.path.join(build_dir, files[0])) as f:
        build_info = json.load(f)
    return build_info["input"], build_info["solcVersion"]

def get_zksolc_version():
    """Get zksolc version from contract metadata."""
    build_dir = "artifacts-zk/build-info"
    files = [f for f in os.listdir(build_dir) if f.endswith(".json")]
    with open(os.path.join(build_dir, files[0])) as f:
        build_info = json.load(f)
    
    # Try to get from contract metadata
    for source_name, contracts in build_info.get("output", {}).get("contracts", {}).items():
        for contract_name, contract_data in contracts.items():
            metadata = contract_data.get("metadata", {})
            if isinstance(metadata, dict) and "zk_version" in metadata:
                return f"v{metadata['zk_version']}"
    return "v1.5.10"  # fallback

def submit_verification(contract_name, contract_info, source_code, solc_version, zksolc_version):
    """Submit a single contract for verification."""
    request = {
        "contractAddress": contract_info["address"],
        "sourceCode": source_code,
        "codeFormat": "solidity-standard-json-input",
        "contractName": f"{contract_info['source']}:{contract_name}",
        "compilerSolcVersion": solc_version,
        "compilerZksolcVersion": zksolc_version,
        "constructorArguments": contract_info["args"],
        "optimizationUsed": True,
    }
    
    data = json.dumps(request).encode()
    req = urllib.request.Request(
        VERIFY_URL,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    
    try:
        resp = urllib.request.urlopen(req)
        verification_id = int(resp.read().decode())
        return verification_id
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"  ❌ HTTP Error {e.code}: {error_body[:200]}")
        return None

def check_status(verification_id):
    """Check verification status."""
    req = urllib.request.Request(
        f"{VERIFY_URL}/{verification_id}",
        headers={"Content-Type": "application/json"},
        method="GET"
    )
    resp = urllib.request.urlopen(req)
    return json.loads(resp.read().decode())

def wait_for_verification(verification_id, contract_name, max_retries=15):
    """Poll verification status until complete."""
    for i in range(max_retries):
        time.sleep(3)
        status = check_status(verification_id)
        state = status.get("status", "unknown")
        
        if state == "successful":
            return True, None
        elif state == "failed":
            return False, status.get("error", "Unknown error")
        elif state == "in_progress" or state == "queued":
            print(f"  ⏳ Still {state}... ({i+1}/{max_retries})")
        else:
            print(f"  ❓ Unknown status: {state}")
    
    return False, "Timeout waiting for verification"

def main():
    print("🐾 Claw Domains — Direct Contract Verification")
    print("=" * 50)
    
    compute_constructor_args()
    source_code, solc_version = load_source_code()
    zksolc_version = get_zksolc_version()
    
    print(f"Compiler: zksolc {zksolc_version}, solc {solc_version}")
    print()
    
    results = {}
    
    for name, info in CONTRACTS.items():
        print(f"📝 Verifying {name} at {info['address']}...")
        print(f"  Constructor args: {info['args'][:40]}{'...' if len(info['args']) > 40 else ''}")
        
        vid = submit_verification(name, info, source_code, solc_version, zksolc_version)
        if vid is None:
            results[name] = "FAILED (submission error)"
            continue
        
        print(f"  Verification ID: {vid}")
        
        success, error = wait_for_verification(vid, name)
        if success:
            print(f"  ✅ {name} verified successfully!")
            print(f"  🔗 {EXPLORER_URL}/address/{info['address']}#contract")
            results[name] = "VERIFIED"
        else:
            print(f"  ❌ {name} verification failed: {error}")
            results[name] = f"FAILED: {error}"
        
        print()
    
    print("\n" + "=" * 50)
    print("📊 VERIFICATION RESULTS")
    print("=" * 50)
    for name, result in results.items():
        emoji = "✅" if result == "VERIFIED" else "❌"
        print(f"  {emoji} {name}: {result}")
    
    return all(r == "VERIFIED" for r in results.values())

if __name__ == "__main__":
    sys.exit(0 if main() else 1)
