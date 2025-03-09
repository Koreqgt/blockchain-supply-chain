const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

async function main() {
  // Connect to a local blockchain (e.g., Hardhat or Ganache)
  const provider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
  
  // Replace with your wallet private key (ensure proper security in production)
  const wallet = new ethers.Wallet("YOUR_PRIVATE_KEY", provider);

  // Load compiled contract artifact (update the path as necessary)
  const artifactPath = path.join(__dirname, "artifacts", "contracts", "SupplyChain.sol", "SupplyChain.json");
  const contractArtifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));

  // Deploy the contract
  const factory = new ethers.ContractFactory(contractArtifact.abi, contractArtifact.bytecode, wallet);
  const supplyChainContract = await factory.deploy();
  await supplyChainContract.deployed();
  console.log("SupplyChain contract deployed at:", supplyChainContract.address);

  // 1. Register a raw material (Raw Material Packaging)
  let tx = await supplyChainContract.registerRawMaterial(
    "RFID123",          // Unique RFID/QR code
    "BATCH001",         // Batch number
    "SUPPLIER001",      // Supplier ID
    "Quality Passed"    // Quality inspection findings
  );
  await tx.wait();
  console.log("Raw material registered.");

  // 2. Record manufacturing details (Manufacturing Details)
  tx = await supplyChainContract.recordManufacturing(
    "PRODUCT001",       // Unique Product ID
    "RFID123",          // Associated raw material RFID
    "Machine Log Data", // Machine logs
    "Line Authenticated", // Manufacturing line authentication
    "Final Inspection Passed", // Final inspection reports
    "OffChainRef001"    // Off-chain data reference
  );
  await tx.wait();
  console.log("Manufacturing details recorded.");

  // 3. Record distribution transfer (Distribution Transfer)
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const deliveryTimestamp = currentTimestamp + 86400; // Delivery expected in 1 day
  tx = await supplyChainContract.recordDistribution(
    "PRODUCT001",
    100,               // Weight (example unit)
    50,                // Measurements (example unit)
    "Good Condition",  // Packing conditions
    deliveryTimestamp, // Anticipated delivery date (unix timestamp)
    "GPS: 12.3456, 65.4321" // Initial GPS data
  );
  await tx.wait();
  console.log("Distribution details recorded.");

  // (Optional) Update GPS data as product moves
  tx = await supplyChainContract.updateGPSData("PRODUCT001", "GPS: 12.3460, 65.4330");
  await tx.wait();
  console.log("GPS data updated.");

  // 4. Retrieve complete product details for retailer traceability
  const productDetails = await supplyChainContract.getProductDetails("PRODUCT001");
  console.log("Product Details:", productDetails);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error:", error);
    process.exit(1);
  });
