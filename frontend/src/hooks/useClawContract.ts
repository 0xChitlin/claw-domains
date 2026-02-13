import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { CLAW_REGISTRY_ADDRESS, CLAW_REGISTRY_ABI, MINT_PRICE } from '../config/contract';

export function useTotalSupply() {
  return useReadContract({
    address: CLAW_REGISTRY_ADDRESS,
    abi: CLAW_REGISTRY_ABI,
    functionName: 'totalSupply',
    query: {
      refetchInterval: 10000,
    },
  });
}

export function useMintPrice() {
  return useReadContract({
    address: CLAW_REGISTRY_ADDRESS,
    abi: CLAW_REGISTRY_ABI,
    functionName: 'mintPrice',
  });
}

export function useIsAvailable(name: string) {
  return useReadContract({
    address: CLAW_REGISTRY_ADDRESS,
    abi: CLAW_REGISTRY_ABI,
    functionName: 'isAvailable',
    args: [name],
    query: {
      enabled: name.length >= 3,
    },
  });
}

export function useTokenURI(tokenId: bigint | undefined) {
  return useReadContract({
    address: CLAW_REGISTRY_ADDRESS,
    abi: CLAW_REGISTRY_ABI,
    functionName: 'tokenURI',
    args: tokenId !== undefined ? [tokenId] : undefined,
    query: {
      enabled: tokenId !== undefined && tokenId > 0n,
    },
  });
}

export function useResolve(name: string) {
  return useReadContract({
    address: CLAW_REGISTRY_ADDRESS,
    abi: CLAW_REGISTRY_ABI,
    functionName: 'resolve',
    args: [name],
    query: {
      enabled: name.length >= 3,
    },
  });
}

export function useMint() {
  const { data: hash, writeContract, isPending, error, reset } = useWriteContract();

  const { isLoading: isConfirming, isSuccess, data: receipt } = useWaitForTransactionReceipt({
    hash,
  });

  const mint = (name: string) => {
    writeContract({
      address: CLAW_REGISTRY_ADDRESS,
      abi: CLAW_REGISTRY_ABI,
      functionName: 'mint',
      args: [name],
      value: MINT_PRICE,
    });
  };

  return {
    mint,
    hash,
    isPending,
    isConfirming,
    isSuccess,
    error,
    receipt,
    reset,
  };
}
