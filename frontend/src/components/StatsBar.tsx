import { useTotalSupply, useMintPrice } from '../hooks/useClawContract';
import { formatEther } from 'viem';

export function StatsBar() {
  const { data: totalSupply } = useTotalSupply();
  const { data: mintPrice } = useMintPrice();

  return (
    <div className="border-b border-claw-border bg-claw-card/50">
      <div className="max-w-6xl mx-auto px-4 py-3 flex flex-wrap items-center justify-center gap-4 sm:gap-8 text-sm">
        <div className="flex items-center gap-2">
          <span className="text-gray-500">Minted</span>
          <span className="font-mono font-semibold text-claw-green">
            {totalSupply !== undefined ? totalSupply.toString() : '—'}
          </span>
        </div>

        <div className="hidden sm:block w-px h-4 bg-claw-border" />

        <div className="flex items-center gap-2">
          <span className="text-gray-500">Price</span>
          <span className="font-mono font-semibold text-white">
            {mintPrice !== undefined ? `${formatEther(mintPrice)} ETH` : '0.0005 ETH'}
          </span>
        </div>

        <div className="hidden sm:block w-px h-4 bg-claw-border" />

        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-claw-green animate-pulse" />
          <span className="text-gray-400">Abstract Testnet</span>
        </div>
      </div>
    </div>
  );
}
