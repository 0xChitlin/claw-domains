import { useTotalSupply, useMintPrice } from '../hooks/useClawContract';
import { formatEther } from 'viem';

export function StatsBar() {
  const { data: totalSupply } = useTotalSupply();
  const { data: mintPrice } = useMintPrice();

  return (
    <div className="glass-card px-4 sm:px-6 py-3 flex flex-wrap items-center justify-center gap-4 sm:gap-8 text-sm animate-fade-in">
      <div className="flex items-center gap-2">
        <div className="w-2 h-2 rounded-full bg-claw-green animate-pulse" />
        <span className="text-gray-400">Total Minted</span>
        <span className="font-mono font-semibold text-white">
          {totalSupply !== undefined ? totalSupply.toString() : '—'}
        </span>
      </div>

      <div className="hidden sm:block w-px h-4 bg-claw-border" />

      <div className="flex items-center gap-2">
        <span className="text-gray-400">Price</span>
        <span className="font-mono font-semibold text-white">
          {mintPrice !== undefined ? `${formatEther(mintPrice)} ETH` : '0.0005 ETH'}
        </span>
      </div>

      <div className="hidden sm:block w-px h-4 bg-claw-border" />

      <div className="flex items-center gap-2">
        <div className="px-2 py-0.5 rounded-full bg-claw-purple/20 border border-claw-purple/30 text-claw-purple-light text-xs font-mono">
          Abstract Testnet
        </div>
      </div>
    </div>
  );
}
