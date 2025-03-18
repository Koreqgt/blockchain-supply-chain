// pages/index.tsx
import React, { useEffect } from 'react';
import { useRouter } from 'next/router';
import { useConnect, useAccount } from 'wagmi';
import { injected } from 'wagmi/connectors';

const roleMapping: { [address: string]: string } = {
  '0xebbe4b8bd3047f554e27d83377cdda04829d11ec': 'supplier',
  '0xdef456...manufacturer': 'manufacturer',
  '0xghi789...distributor': 'distributor',
  '0xjkl012...retailer': 'retailer',
};

const Home: React.FC = () => {
  const router = useRouter();
  const { connectAsync, error } = useConnect();
  const { address, isConnected } = useAccount();

  useEffect(() => {
    if (isConnected && address) {
      const account = address.toLowerCase();
      if (roleMapping[account]) {
        router.push(`/${roleMapping[account]}`);
      }
    }
  }, [isConnected, address, router]);

  const handleConnect = async () => {
    try {
      await connectAsync({ connector: injected() });
    } catch (err) {
      console.error('Error connecting wallet:', err);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-base-200 p-6">
      <div className="card w-full max-w-md bg-base-100 shadow-xl p-8">
        <h1 className="mb-6 text-center text-3xl font-bold text-primary">
          Blockchain Supply Chain
        </h1>
        {!isConnected ? (
          <button onClick={handleConnect} className="btn btn-primary w-full">
            Connect Wallet
          </button>
        ) : (
          <p className="mb-4 text-center text-neutral">
            Connected Wallet:{" "}
            <span className="ml-1 font-medium text-primary">{address}</span>
          </p>
        )}

        {error && (
          <div className="alert alert-error text-sm">
            <span>{error.message}</span>
          </div>
        )}

        {/* Supply Chain Manager link */}
        <div className="mt-6 flex flex-col items-center">
          <button
            onClick={() => router.push('/manager')}
            className="btn btn-secondary btn-md text-white font-semibold shadow-lg transition duration-200 hover:bg-secondary-focus hover:scale-105 focus:ring focus:ring-secondary"
          >
            🔑 Register Roles (Manager)
          </button>
        </div>
      </div>
    </div>
  );
};

export default Home;
