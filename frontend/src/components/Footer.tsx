import { abstractTestnet } from '../config/wagmi';
import { CLAW_REGISTRY_ADDRESS } from '../config/contract';

export function Footer() {
  const contractUrl = `${abstractTestnet.blockExplorers.default.url}/address/${CLAW_REGISTRY_ADDRESS}`;

  return (
    <footer className="border-t border-claw-border py-8 px-4">
      <div className="max-w-6xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-gray-500">
        <div className="flex items-center gap-2">
          <span className="text-lg">🦀</span>
          <span className="font-mono">.claw domains</span>
        </div>

        <div className="flex items-center gap-4">
          <a
            href={contractUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-claw-purple-light transition-colors font-mono text-xs"
          >
            Contract ↗
          </a>
          <span className="text-claw-border">·</span>
          <a
            href="https://github.com/0xChitlin/claw-domains"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-claw-purple-light transition-colors"
          >
            GitHub ↗
          </a>
          <span className="text-claw-border">·</span>
          <span>Abstract Testnet</span>
        </div>
      </div>
    </footer>
  );
}
