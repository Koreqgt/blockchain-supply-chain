import React, { useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '@/components/Layout';

const Distributor: React.FC = () => {
  const router = useRouter();
  const [walletAddress, setWalletAddress] = useState('0xebbe4b8bd3047f554e27d83377cdda04829d11ec');
  const [status, setStatus] = useState('');
  const [productId, setProductId] = useState('');
  const [weight, setWeight] = useState('');
  const [measurements, setMeasurements] = useState('');
  const [packing, setPacking] = useState('');
  const [deliveryDate, setDeliveryDate] = useState('');
  const [gps, setGps] = useState('');

  const disconnectWallet = () => {
    setWalletAddress('');
    router.push('/');
  };

  const recordDistribution = async () => {
    try {
      setStatus('Recording distribution details...');
      await new Promise((resolve) => setTimeout(resolve, 2000));
      setStatus('Distribution details recorded successfully!');
    } catch (error) {
      console.error(error);
      setStatus('Error recording distribution details.');
    }
  };

  const updateGPS = async () => {
    try {
      setStatus('Updating GPS data...');
      await new Promise((resolve) => setTimeout(resolve, 2000));
      setStatus('GPS data updated successfully!');
    } catch (error) {
      console.error(error);
      setStatus('Error updating GPS data.');
    }
  };

  return (
    <Layout>
      <div className="card bg-base-100 shadow-xl p-8">
        <h1 className="mb-4 text-center text-2xl font-bold text-gray-800">
          Distributor Dashboard
        </h1>
        <div className="mb-6">
          <h2 className="mb-4 text-xl font-semibold text-gray-700">
            Record Distribution Details
          </h2>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              recordDistribution();
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
                <span className="label-text">Weight:</span>
              </label>
              <input
                type="text"
                value={weight}
                onChange={(e) => setWeight(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Measurements:</span>
              </label>
              <input
                type="text"
                value={measurements}
                onChange={(e) => setMeasurements(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Packing Conditions:</span>
              </label>
              <input
                type="text"
                value={packing}
                onChange={(e) => setPacking(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Anticipated Delivery Date:</span>
              </label>
              <input
                type="text"
                value={deliveryDate}
                onChange={(e) => setDeliveryDate(e.target.value)}
                placeholder="Unix timestamp or date"
                required
                className="input input-bordered w-full"
              />
            </div>
            <div>
              <label className="label">
                <span className="label-text">Initial GPS:</span>
              </label>
              <input
                type="text"
                value={gps}
                onChange={(e) => setGps(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <button type="submit" className="btn btn-primary w-full">
              Record Distribution
            </button>
          </form>
        </div>

        <div className="mb-6">
          <h2 className="mb-4 text-xl font-semibold text-gray-700">
            Update GPS Data
          </h2>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              updateGPS();
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
                <span className="label-text">New GPS Data:</span>
              </label>
              <input
                type="text"
                value={gps}
                onChange={(e) => setGps(e.target.value)}
                required
                className="input input-bordered w-full"
              />
            </div>
            <button type="submit" className="btn btn-success w-full">
              Update GPS
            </button>
          </form>
        </div>

        {status && (
          <div className="alert alert-info mt-4">
            <span>{status}</span>
          </div>
        )}
      </div>
    </Layout>
  );
};

export default Distributor;
