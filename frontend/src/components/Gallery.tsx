import { useState } from 'react';
import { useTokenURI } from '../hooks/useClawContract';

function decodeTokenURI(uri: string): { name: string; description: string; image: string } | null {
  try {
    const json = uri.startsWith('data:application/json;base64,')
      ? JSON.parse(atob(uri.split(',')[1]))
      : JSON.parse(uri);
    return json;
  } catch {
    return null;
  }
}

function extractSvg(imageData: string): string | null {
  try {
    if (imageData.startsWith('data:image/svg+xml;base64,')) {
      return atob(imageData.split(',')[1]);
    }
    if (imageData.startsWith('data:image/svg+xml,')) {
      return decodeURIComponent(imageData.split(',')[1]);
    }
    if (imageData.startsWith('<svg')) {
      return imageData;
    }
    return null;
  } catch {
    return null;
  }
}

function TokenCard({ tokenId }: { tokenId: bigint }) {
  const { data: tokenURI, isLoading } = useTokenURI(tokenId);
  const [fullscreen, setFullscreen] = useState(false);

  if (isLoading) {
    return (
      <div className="aspect-square rounded-xl bg-claw-card border border-claw-border animate-pulse flex items-center justify-center">
        <div className="w-8 h-8 border-2 border-claw-purple border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!tokenURI) {
    return (
      <div className="aspect-square rounded-xl bg-claw-card border border-claw-border flex items-center justify-center">
        <p className="text-gray-500 text-sm">Token not found</p>
      </div>
    );
  }

  const metadata = decodeTokenURI(tokenURI);
  if (!metadata) return null;

  const svg = extractSvg(metadata.image);

  return (
    <>
      <div
        className="group relative aspect-square rounded-xl overflow-hidden border border-claw-border hover:border-claw-purple/50 transition-all duration-300 cursor-pointer hover:scale-[1.02] hover:shadow-xl hover:shadow-claw-purple/10"
        onClick={() => setFullscreen(true)}
      >
        {svg ? (
          <div
            className="w-full h-full"
            dangerouslySetInnerHTML={{ __html: svg }}
          />
        ) : metadata.image ? (
          <img src={metadata.image} alt={metadata.name} className="w-full h-full object-cover" />
        ) : null}
        <div className="absolute bottom-0 left-0 right-0 p-3 bg-gradient-to-t from-black/80 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
          <p className="text-sm font-mono text-claw-green-light">{metadata.name}</p>
        </div>
      </div>

      {fullscreen && (
        <div
          className="fixed inset-0 z-50 bg-black/90 flex items-center justify-center p-8 cursor-pointer animate-fade-in"
          onClick={() => setFullscreen(false)}
        >
          <div className="max-w-2xl w-full aspect-square">
            {svg ? (
              <div
                className="w-full h-full"
                dangerouslySetInnerHTML={{ __html: svg }}
              />
            ) : metadata.image ? (
              <img src={metadata.image} alt={metadata.name} className="w-full h-full object-contain" />
            ) : null}
          </div>
          <div className="absolute bottom-8 text-center">
            <p className="text-xl font-mono text-white">{metadata.name}</p>
            <p className="text-sm text-gray-400 mt-1">Token #{tokenId.toString()}</p>
          </div>
        </div>
      )}
    </>
  );
}

export function Gallery() {
  const [viewTokenId, setViewTokenId] = useState('');
  const tokenId = viewTokenId && !isNaN(Number(viewTokenId)) ? BigInt(viewTokenId) : undefined;

  return (
    <section id="gallery" className="py-20 px-4">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-3xl md:text-4xl font-bold text-center mb-4">
          <span className="bg-gradient-to-r from-claw-purple-light to-claw-green-light bg-clip-text text-transparent">
            Gallery
          </span>
        </h2>
        <p className="text-gray-500 text-center mb-10">
          Each .claw domain is a unique piece of on-chain generative art
        </p>

        <div className="max-w-xs mx-auto mb-12">
          <div className="flex gap-2">
            <input
              type="number"
              min="1"
              value={viewTokenId}
              onChange={(e) => setViewTokenId(e.target.value)}
              placeholder="Token ID"
              className="flex-1 h-10 px-4 rounded-lg bg-claw-card border border-claw-border text-white font-mono placeholder:text-gray-600 focus:outline-none focus:border-claw-purple/50 transition-all text-sm"
            />
            <button
              disabled={!tokenId}
              className="px-4 h-10 rounded-lg bg-claw-purple/20 text-claw-purple-light text-sm font-medium hover:bg-claw-purple/30 transition-colors disabled:opacity-50"
            >
              View
            </button>
          </div>
        </div>

        {tokenId !== undefined && tokenId > 0n ? (
          <div className="max-w-sm mx-auto animate-slide-up">
            <TokenCard tokenId={tokenId} />
          </div>
        ) : (
          <div className="text-center text-gray-600 py-12 border border-dashed border-claw-border rounded-xl">
            <p className="text-4xl mb-3">🎨</p>
            <p>Enter a token ID to view its on-chain art</p>
            <p className="text-sm mt-1">or mint your own to see it here</p>
          </div>
        )}
      </div>
    </section>
  );
}
