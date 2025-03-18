import { http, createConfig } from '@wagmi/core'
import { injected } from '@wagmi/connectors'

const bscTestnet = {
  id: 97,
  name: 'BNB Chain Testnet',
  network: 'bsc-testnet',
  nativeCurrency: {
    name: 'Testnet Binance Coin',
    symbol: 'tBNB',
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ['https://data-seed-prebsc-1-s1.binance.org:8545/'],
    },
    public: {
      http: ['https://data-seed-prebsc-1-s1.binance.org:8545/'],
    },
  },
  blockExplorers: {
    default: { name: 'BscScan', url: 'https://testnet.bscscan.com' },
  },
  testnet: true,
}

export const config = createConfig({
  chains: [bscTestnet],
  connectors: [injected()],
  transports: {
    [bscTestnet.id]: http(),
  },
  ssr: true, 
})