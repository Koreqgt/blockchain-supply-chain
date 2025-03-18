import React, { useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '@/components/Layout';

const Supplier: React.FC = () => {
  const router = useRouter();
  const [rfid, setRfid] = useState('');
  const [batch, setBatch] = useState('');
  const [quality, setQuality] = useState('');
  const [status, setStatus] = useState('');

  const registerRawMaterial = async () => {
    try {
      setStatus('Submitting transaction...');
      // Replace with real smart contract interaction
      await new Promise((resolve) => setTimeout(resolve, 2000));
      setStatus('✅ Raw material registered successfully!');
    } catch (error) {
      console.error(error);
      setStatus('❌ Error registering raw material.');
    }
  };

  return (
    <Layout>
      <div className="flex flex-col flex-1 w-full px-6 py-10">
        <h1 className="text-3xl font-bold text-white text-center mb-6">
          Supplier Dashboard
        </h1>
        
        {/* Full-Width Container */}
        <div className="flex-1 flex flex-col items-center justify-center w-full">
          <div className="w-full max-w-4xl bg-base-100 shadow-xl p-8 rounded-lg">
            <h2 className="mb-6 text-xl font-semibold text-gray-100 flex items-center gap-2">
              📦 Register Raw Material
            </h2>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                registerRawMaterial();
              }}
              className="grid grid-cols-1 gap-4 md:grid-cols-2"
            >
              <div className="col-span-2">
                <label className="label">
                  <span className="label-text text-gray-200">RFID/QR Code:</span>
                </label>
                <input
                  type="text"
                  value={rfid}
                  onChange={(e) => setRfid(e.target.value)}
                  required
                  className="input input-bordered w-full text-white placeholder-gray-400"
                />
              </div>

              <div>
                <label className="label">
                  <span className="label-text text-gray-200">Batch Number:</span>
                </label>
                <input
                  type="text"
                  value={batch}
                  onChange={(e) => setBatch(e.target.value)}
                  required
                  className="input input-bordered w-full text-white placeholder-gray-400"
                />
              </div>

              <div>
                <label className="label">
                  <span className="label-text text-gray-200">Quality Inspection Data:</span>
                </label>
                <input
                  type="text"
                  value={quality}
                  onChange={(e) => setQuality(e.target.value)}
                  required
                  className="input input-bordered w-full text-white placeholder-gray-400"
                />
              </div>

              <div className="col-span-2 flex justify-center">
                <button type="submit" className="btn btn-primary w-full md:w-1/2 flex items-center gap-2">
                  🚀 Register
                </button>
              </div>
            </form>

            {status && (
              <div className="alert alert-info mt-4">
                <span>{status}</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
};

export default Supplier;
