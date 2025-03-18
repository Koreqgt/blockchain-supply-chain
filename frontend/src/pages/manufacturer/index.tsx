import React, { useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '@/components/Layout';

const Manufacturer: React.FC = () => {
  const router = useRouter();
  const [walletAddress, setWalletAddress] = useState('0xebbe4b8bd3047f554e27d83377cdda04829d11ec');
  const [status, setStatus] = useState('');
  const [productId, setProductId] = useState('');
  const [rawMaterialRFID, setRawMaterialRFID] = useState('');
  const [machineLogs, setMachineLogs] = useState('');
  const [inspection, setInspection] = useState('');
  const [offChainRef, setOffChainRef] = useState('');

  const disconnectWallet = () => {
    setWalletAddress('');
    router.push('/');
  };

  const recordManufacturing = async () => {
    try {
      setStatus('Recording manufacturing details...');
      await new Promise((resolve) => setTimeout(resolve, 2000));
      setStatus('Manufacturing details recorded successfully!');
    } catch (error) {
      console.error(error);
      setStatus('Error recording manufacturing details.');
    }
  };

  return (
    <Layout>
      <div className="card bg-base-100 shadow-xl p-8">
        <h1 className="mb-4 text-center text-2xl font-bold text-gray-800">
          Manufacturer Dashboard
        </h1>
        <div>
          <h2 className="mb-4 text-xl font-semibold text-gray-700">
            Record Manufacturing Details
          </h2>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              recordManufacturing();
            }}
            className="space-y-4"
          >
            <div>
              <label className="label">
                <span className="label-text">Product ID:</span>
              </label>
              <input
                type="text"
                value={productId}
                onChange={(e) => setProductId(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Raw Material RFID:</span>
              </label>
              <input
                type="text"
                value={rawMaterialRFID}
                onChange={(e) => setRawMaterialRFID(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Machine Logs:</span>
              </label>
              <input
                type="text"
                value={machineLogs}
                onChange={(e) => setMachineLogs(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Final Inspection Reports:</span>
              </label>
              <input
                type="text"
                value={inspection}
                onChange={(e) => setInspection(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Off-Chain Data Reference:</span>
              </label>
              <input
                type="text"
                value={offChainRef}
                onChange={(e) => setOffChainRef(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <button type="submit" className="btn btn-primary w-full">
              Record Manufacturing
            </button>
          </form>
          {status && (
            <div className="alert alert-info mt-4">
              <span>{status}</span>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
};

export default Manufacturer;
