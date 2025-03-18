import React, { useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '@/components/Layout';

const Retailer: React.FC = () => {
  const router = useRouter();
  const [productId, setProductId] = useState('');
  const [status, setStatus] = useState('');
  const [productDetails, setProductDetails] = useState<any>(null);
  const [walletAddress, setWalletAddress] = useState('0xebbe4b8bd3047f554e27d83377cdda04829d11ec');

  const disconnectWallet = () => {
    setWalletAddress('');
    router.push('/');
  };

  const fetchProductDetails = async () => {
    try {
      setStatus('Fetching product details...');
      // Replace with real smart contract call
      await new Promise((resolve) => setTimeout(resolve, 2000));
      // Dummy data
      setProductDetails({
        rawMaterial: { rfid: 'RFID123', quality: 'Passed' },
        manufacturing: { productId, machineLogs: 'Machine Logs Here' },
        distribution: { gps: 'GPS: 12.3456, 65.4321', deliveryDate: 'Tomorrow' },
      });
      setStatus('');
    } catch (error) {
      console.error(error);
      setStatus('Error fetching product details.');
    }
  };

  const confirmReceipt = async () => {
    try {
      setStatus('Confirming receipt...');
      // Replace with real smart contract call
      await new Promise((resolve) => setTimeout(resolve, 2000));
      setStatus('Receipt confirmed!');
    } catch (error) {
      console.error(error);
      setStatus('Error confirming receipt.');
    }
  };

  return (
    <Layout>
      <div className="card bg-base-100 shadow-xl p-8">
        <h1 className="mb-4 text-center text-2xl font-bold text-gray-800">
          Retailer Dashboard
        </h1>
        <div className="mb-6">
          <h2 className="mb-4 text-xl font-semibold text-gray-700">Check Product Details</h2>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              fetchProductDetails();
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
            <button type="submit" className="btn btn-primary w-full">
              Fetch Details
            </button>
          </form>
        </div>

        {productDetails && (
          <div className="mb-6 rounded-lg bg-gray-100 p-4">
            <h3 className="mb-2 text-lg font-semibold text-gray-800">
              Product Details:
            </h3>
            <p className="text-sm text-gray-700">
              <strong>Raw Material:</strong> RFID {productDetails.rawMaterial.rfid}, Quality {productDetails.rawMaterial.quality}
            </p>
            <p className="text-sm text-gray-700">
              <strong>Manufacturing:</strong> {productDetails.manufacturing.machineLogs}
            </p>
            <p className="text-sm text-gray-700">
              <strong>Distribution:</strong> {productDetails.distribution.gps}, Delivery {productDetails.distribution.deliveryDate}
            </p>
          </div>
        )}

        <div className="mb-6">
          <h2 className="mb-4 text-xl font-semibold text-gray-700">Confirm Receipt</h2>
          <form
            onSubmit={(e) => {
              e.preventDefault();
              confirmReceipt();
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
            <button type="submit" className="btn btn-success w-full">
              Confirm Receipt
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

export default Retailer;
