import { ConnectButton } from '@rainbow-me/rainbowkit';

export function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 border-b border-claw-border/50 bg-claw-bg/80 backdrop-blur-xl">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-2xl">🦀</span>
          <span className="font-mono font-bold text-lg tracking-tight">.claw</span>
        </div>
        <ConnectButton
          chainStatus="icon"
          showBalance={false}
          accountStatus={{
            smallScreen: 'avatar',
            largeScreen: 'address',
          }}
        />
      </div>
    </header>
  );
}
