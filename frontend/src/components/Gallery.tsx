import { useResolve, useTokenURI } from '../hooks/useClawContract';

function decodeTokenURI(uri: string): { name: string; description: string; image: string } | null {
  try {
    // tokenURI returns: data:application/json;base64,<base64>
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

interface GalleryProps {
  name: string;
}

export function Gallery({ name }: GalleryProps) {
  const { data: tokenId } = useResolve(name);
  const resolvedTokenId = tokenId && tokenId > 0n ? tokenId : undefined;
  const { data: tokenURI, isLoading } = useTokenURI(resolvedTokenId);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-8">
        <div className="w-8 h-8 border-2 border-claw-purple/30 border-t-claw-purple rounded-full animate-spin" />
      </div>
    );
  }

  if (!tokenURI) {
    return null;
  }

  const metadata = decodeTokenURI(tokenURI);
  if (!metadata) return null;

  const svg = extractSvg(metadata.image);

  return (
    <div className="animate-slide-up">
      <div className="glass-card overflow-hidden max-w-sm mx-auto">
        {/* SVG art */}
        {svg ? (
          <div
            className="w-full aspect-square nft-preview-glow"
            dangerouslySetInnerHTML={{ __html: svg }}
          />
        ) : metadata.image ? (
          <img
            src={metadata.image}
            alt={metadata.name}
            className="w-full aspect-square object-cover"
          />
        ) : null}

        {/* Metadata */}
        <div className="p-4 border-t border-claw-border">
          <h3 className="font-mono font-bold text-lg text-white">
            {metadata.name || `${name}.claw`}
          </h3>
          {metadata.description && (
            <p className="text-gray-400 text-sm mt-1">{metadata.description}</p>
          )}
        </div>
      </div>
    </div>
  );
}
