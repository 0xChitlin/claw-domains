import { useAccount } from 'wagmi';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useMintDomain } from '../hooks/useClawContract';
import { formatEther } from 'viem';
import { MINT_PRICE } from '../config/contract';
import { abstractTestnet } from '../config/chain';

interface MintButtonProps {
  name: string;
  available: boolean;
  onMinted: (tokenId: bigint) => void;
}

export function MintButton({ name, available }: MintButtonProps) {
  const { isConnected, chain } = useAccount();
  const { mint, isPending, isConfirming, isSuccess, hash, error } = useMintDomain();

  const wrongNetwork = isConnected && chain?.id !== abstractTestnet.id;

  if (!isConnected) {
    return (
      <div className="flex flex-col items-center gap-3">
        <ConnectButton />
        <p className="text-gray-500 text-sm">Connect wallet to mint</p>
      </div>
    );
  }

  if (wrongNetwork) {
    return (
      <div className="flex flex-col items-center gap-3">
        <ConnectButton />
        <p className="text-yellow-400 text-sm">Switch to Abstract Testnet</p>
      </div>
    );
  }

  const disabled = !name || !available || isPending || isConfirming;

  return (
    <div className="flex flex-col items-center gap-4 animate-slide-up">
      <button
        onClick={() => mint(name)}
        disabled={disabled}
        className={`
          group relative px-8 py-4 rounded-xl font-semibold text-lg transition-all duration-300
          ${disabled
            ? 'bg-gray-800 text-gray-500 cursor-not-allowed'
            : 'bg-gradient-to-r from-claw-purple to-claw-green text-white hover:shadow-lg hover:shadow-claw-purple/25 hover:scale-[1.02] active:scale-[0.98]'
          }
        `}
      >
        {isPending ? (
          <span className="flex items-center gap-2">
            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
            Confirm in wallet...
          </span>
        ) : isConfirming ? (
          <span className="flex items-center gap-2">
            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
            Minting...
          </span>
        ) : isSuccess ? (
          <span className="flex items-center gap-2">
            ✨ Minted {name}.claw!
          </span>
        ) : (
          <span>
            Mint <strong>{name || '___'}.claw</strong> for {formatEther(MINT_PRICE)} ETH
          </span>
        )}
      </button>

      {/* Transaction status */}
      {hash && (
        <a
          href={`https://explorer.testnet.abs.xyz/tx/${hash}`}
          target="_blank"
          rel="noopener noreferrer"
          className="text-sm text-claw-purple-light hover:underline"
        >
          View transaction ↗
        </a>
      )}

      {error && (
        <p className="text-red-400 text-sm max-w-md text-center">
          {(error as Error).message?.includes('User rejected')
            ? 'Transaction rejected'
            : (error as Error).message?.slice(0, 100) || 'Mint failed'}
        </p>
      )}
    </div>
  );
}
