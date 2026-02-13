import '@rainbow-me/rainbowkit/styles.css';
import { RainbowKitProvider, darkTheme } from '@rainbow-me/rainbowkit';
import { WagmiProvider } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { config } from './config/wagmi';
import { Header } from './components/Header';
import { HeroSection } from './components/HeroSection';
import { StatsBar } from './components/StatsBar';
import { Gallery } from './components/Gallery';
import { NameRules } from './components/NameRules';
import { Footer } from './components/Footer';

const queryClient = new QueryClient();

export default function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider
          theme={darkTheme({
            accentColor: '#9b4dca',
            accentColorForeground: 'white',
            borderRadius: 'medium',
            overlayBlur: 'small',
          })}
        >
          <div className="min-h-screen bg-claw-bg">
            <Header />
            {/* Spacer for fixed header */}
            <div className="h-16" />
            <StatsBar />
            <HeroSection />

            <div className="max-w-6xl mx-auto px-4">
              <div className="border-t border-claw-border" />
            </div>

            <Gallery />

            <div className="max-w-6xl mx-auto px-4">
              <div className="border-t border-claw-border" />
            </div>

            <NameRules />
            <Footer />
          </div>
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
