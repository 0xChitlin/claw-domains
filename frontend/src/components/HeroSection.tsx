import { useState, useCallback } from 'react';
import { HeroArt } from './HeroArt';
import { NameChecker } from './NameChecker';
import { MintButton } from './MintButton';

export function HeroSection() {
  const [mintName, setMintName] = useState('');
  const [isAvailable, setIsAvailable] = useState(false);

  const handleNameValid = useCallback((name: string, available: boolean) => {
    setMintName(name);
    setIsAvailable(available);
  }, []);

  return (
    <section className="relative py-20 md:py-32 px-4 overflow-hidden">
      {/* Background grid */}
      <div
        className="absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage:
            'linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)',
          backgroundSize: '60px 60px',
        }}
      />

      {/* Gradient orbs */}
      <div className="absolute top-20 left-10 w-96 h-96 bg-claw-purple/10 rounded-full blur-3xl" />
      <div className="absolute bottom-20 right-10 w-96 h-96 bg-claw-green/10 rounded-full blur-3xl" />

      <div className="max-w-6xl mx-auto flex flex-col lg:flex-row items-center gap-12 lg:gap-20 relative">
        {/* Text + mint form */}
        <div className="flex-1 text-center lg:text-left animate-fade-in">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-claw-purple/10 border border-claw-purple/20 text-claw-purple-light text-xs mb-6">
            <div className="w-1.5 h-1.5 rounded-full bg-claw-green animate-pulse" />
            Live on Abstract Testnet
          </div>
          <h1 className="text-4xl md:text-6xl lg:text-7xl font-bold leading-tight mb-6">
            Claim your{' '}
            <span className="bg-gradient-to-r from-claw-purple-light via-claw-accent to-claw-green bg-clip-text text-transparent">
              .claw
            </span>
            <br />
            identity
          </h1>
          <p className="text-lg md:text-xl text-gray-400 max-w-xl mb-10">
            On-chain domain names with unique generative art. Each name is a living
            NFT — minted, owned, and rendered entirely on-chain.
          </p>

          <NameChecker onNameValid={handleNameValid} />

          <div className="mt-8">
            <MintButton name={mintName} available={isAvailable} />
          </div>
        </div>

        {/* Art preview */}
        <div className="flex-shrink-0">
          <HeroArt />
        </div>
      </div>
    </section>
  );
}
