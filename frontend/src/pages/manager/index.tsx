import React, { useState } from "react";
import { useRouter } from "next/router";
import { useAccount, useWriteContract } from "wagmi";
import { parseEther } from "viem"; // Needed for sending ETH values
import MyContractABI from "@/artifacts/contracts/SupplyChain.sol/SupplyChain.json";

// ✅ Replace with actual contract address
const CONTRACT_ADDRESS = "0xYourContractAddress";
const CONTRACT_ABI = MyContractABI.abi; // ✅ Extract the ABI only


const Manager: React.FC = () => {
  const router = useRouter();
  const { isConnected } = useAccount();
  const [password, setPassword] = useState("");
  const [authenticated, setAuthenticated] = useState(false);
  const [error, setError] = useState("");

  // Manager password (Temporary for Demo)
  const correctPassword = "supplychain";

  // -------------------------------------
  // Role Registration Form
  // -------------------------------------
  const [role, setRole] = useState("supplier");
  const [walletAddr, setWalletAddr] = useState("");
  const [businessName, setBusinessName] = useState("");
  const [businessAddress, setBusinessAddress] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [companyRegNumber, setCompanyRegNumber] = useState("");

  // ✅ Wagmi v2 - Use useContractWrite directly
  const { writeContract, isPending, isError, error: contractError } = useWriteContract();


  // ✅ Handle Password Check
  const handlePasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (password === correctPassword) {
      setAuthenticated(true);
      setError("");
    } else {
      setError("❌ Incorrect password.");
    }
  };

  // ✅ Register Role in Smart Contract
  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await writeContract({
        address: CONTRACT_ADDRESS,
        abi: MyContractABI,
        functionName: "registerBusiness",
        args: [role, walletAddr, businessName, businessAddress, phoneNumber, companyRegNumber],
      });

      alert("✅ Role registered successfully on the blockchain!");
      setRole("supplier");
      setWalletAddr("");
      setBusinessName("");
      setBusinessAddress("");
      setPhoneNumber("");
      setCompanyRegNumber("");
    } catch (err) {
      console.error("❌ Registration error:", err);
      alert("Error registering role!");
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-900 p-6">
      <div className="card w-full max-w-xl bg-gray-800 shadow-xl p-8">
        
        {/* 🔹 Back to Home */}
        <div className="mb-4 flex justify-end">
          <button onClick={() => router.push("/")} className="btn btn-outline btn-sm text-white">
            ⬅ Back to Home
          </button>
        </div>

        {/* 🔹 Title */}
        <h1 className="mb-6 text-center text-2xl font-bold text-white">
          Supply Chain Manager Panel
        </h1>

        {/* 🔹 Password Check */}
        {!authenticated ? (
          <form onSubmit={handlePasswordSubmit} className="space-y-4">
            <div>
              <label className="label">
                <span className="label-text text-white">🔑 Enter Manager Password:</span>
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="input input-bordered w-full bg-gray-700 text-white"
              />
            </div>
            <button type="submit" className="btn btn-primary w-full">Enter</button>
            {error && <div className="alert alert-error mt-4">{error}</div>}
          </form>
        ) : (
          <div>
            {/* 🔹 Register Roles Form */}
            <h2 className="mb-4 text-xl font-semibold text-white">📝 Register Roles</h2>
            <form onSubmit={handleRegister} className="space-y-4">
              <div>
                <label className="label">
                  <span className="label-text text-white">🏢 Role Type:</span>
                </label>
                <select
                  className="select select-bordered w-full bg-gray-700 text-white"
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                >
                  <option value="supplier">Supplier</option>
                  <option value="manufacturer">Manufacturer</option>
                  <option value="distributor">Distributor</option>
                  <option value="retailer">Retailer</option>
                </select>
              </div>

              <div>
                <label className="label">
                  <span className="label-text text-white">📌 Wallet Address:</span>
                </label>
                <input
                  type="text"
                  value={walletAddr}
                  onChange={(e) => setWalletAddr(e.target.value)}
                  required
                  className="input input-bordered w-full bg-gray-700 text-white"
                  placeholder="0x1234..."
                />
              </div>

              <div>
                <label className="label">
                  <span className="label-text text-white">🏭 Business Name:</span>
                </label>
                <input
                  type="text"
                  value={businessName}
                  onChange={(e) => setBusinessName(e.target.value)}
                  required
                  className="input input-bordered w-full bg-gray-700 text-white"
                  placeholder="ABC Supply Co."
                />
              </div>

              <div>
                <label className="label">
                  <span className="label-text text-white">📍 Business Address:</span>
                </label>
                <input
                  type="text"
                  value={businessAddress}
                  onChange={(e) => setBusinessAddress(e.target.value)}
                  required
                  className="input input-bordered w-full bg-gray-700 text-white"
                  placeholder="123 Main Street"
                />
              </div>

              <div>
                <label className="label">
                  <span className="label-text text-white">📞 Phone Number:</span>
                </label>
                <input
                  type="text"
                  value={phoneNumber}
                  onChange={(e) => setPhoneNumber(e.target.value)}
                  required
                  className="input input-bordered w-full bg-gray-700 text-white"
                  placeholder="+1 555-123-4567"
                />
              </div>

              <div>
                <label className="label">
                  <span className="label-text text-white">📄 Company Registration Number:</span>
                </label>
                <input
                  type="text"
                  value={companyRegNumber}
                  onChange={(e) => setCompanyRegNumber(e.target.value)}
                  required
                  className="input input-bordered w-full bg-gray-700 text-white"
                  placeholder="REG-2023-12345"
                />
              </div>

              <button
                type="submit"
                className="btn btn-accent w-full mt-4"
                disabled={isPending}
              >
                {isPending ? "⏳ Registering..." : "✅ Register Role"}
              </button>

              {contractError && (
                <div className="alert alert-error mt-4">{contractError.message}</div>
              )}
            </form>
          </div>
        )}
      </div>
    </div>
  );
};

export default Manager;
