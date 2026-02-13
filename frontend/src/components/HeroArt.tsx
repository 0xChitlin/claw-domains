export function HeroArt() {
  // Inline a representative SVG based on the on-chain generative art style
  return (
    <div className="relative w-72 h-72 md:w-96 md:h-96 animate-float">
      {/* Glow backdrop */}
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-claw-purple/30 via-transparent to-claw-green/30 blur-3xl" />

      {/* SVG Art Preview */}
      <div className="relative rounded-2xl overflow-hidden border border-claw-border/50 shadow-2xl animate-glow">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 400 400"
          className="w-full h-full"
        >
          <defs>
            <filter id="organic">
              <feTurbulence type="fractalNoise" baseFrequency="0.015" numOctaves="3" seed="42" result="turb" />
              <feDisplacementMap in="SourceGraphic" in2="turb" scale="8" xChannelSelector="R" yChannelSelector="G" />
            </filter>
            <filter id="glow">
              <feGaussianBlur stdDeviation="6" result="blur" />
            </filter>
            <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stopColor="hsl(287,77%,36%)" />
              <stop offset="50%" stopColor="hsl(77,68%,47%)" />
              <stop offset="100%" stopColor="hsl(137,73%,39%)" />
            </linearGradient>
            <radialGradient id="glowGrad" cx="200" cy="200" r="180" gradientUnits="userSpaceOnUse">
              <stop offset="0%" stopColor="hsl(287,77%,76%)" stopOpacity="0.4" />
              <stop offset="40%" stopColor="hsl(77,68%,67%)" stopOpacity="0.2" />
              <stop offset="100%" stopColor="hsl(137,73%,46%)" stopOpacity="0" />
            </radialGradient>
            <radialGradient id="coreGrad" cx="200" cy="200" r="120" gradientUnits="userSpaceOnUse">
              <stop offset="0%" stopColor="hsl(287,77%,71%)" stopOpacity="0.9" />
              <stop offset="60%" stopColor="hsl(77,68%,67%)" stopOpacity="0.6" />
              <stop offset="100%" stopColor="hsl(287,77%,56%)" stopOpacity="0.3" />
            </radialGradient>
          </defs>
          <rect width="400" height="400" fill="url(#bgGrad)" />
          <rect width="400" height="400" fill="hsl(287,77%,31%)" filter="url(#organic)" opacity="0.3" />
          <g>
            <polygon points="284,311 146,328 62,216 116,89 254,72 338,184" fill="hsl(287,77%,61%)" opacity="0.4" stroke="hsl(287,77%,76%)" strokeWidth="1" />
            <polygon points="213,310 111,267 98,157 187,90 289,133 302,243" fill="hsl(77,68%,67%)" opacity="0.5" stroke="hsl(77,68%,82%)" strokeWidth="1" />
            <polygon points="168,277 117,210 150,134 232,123 283,190 250,266" fill="hsl(137,73%,61%)" opacity="0.6" stroke="hsl(137,73%,76%)" strokeWidth="1" />
            <circle cx="200" cy="200" r="20" fill="url(#coreGrad)" filter="url(#glow)" />
          </g>
          <circle cx="200" cy="200" r="160" fill="url(#glowGrad)" />
          <circle cx="190" cy="176" r="80" fill="hsl(317,63%,83%)" opacity="0.15" filter="url(#glow)" />
          <rect x="4" y="4" width="392" height="392" rx="12" ry="12" fill="none" stroke="hsl(107,48%,59%)" strokeWidth="1.5" opacity="0.5" />
          <rect x="120" y="365" width="160" height="24" rx="12" fill="hsl(287,77%,36%)" opacity="0.7" />
          <text x="200" y="382" fill="hsl(107,48%,74%)" fontFamily="monospace" fontSize="11" textAnchor="middle">
            yourname.claw
          </text>
        </svg>
      </div>
    </div>
  );
}
