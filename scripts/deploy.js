const hre = require("hardhat");

async function main() {
  await hre.run("compile");
  const [deployer] = await hre.ethers.getSigners();


  const network = await hre.ethers.provider.getNetwork();

  console.log("🚀 Deploying contracts with account:", deployer.address);
  console.log("🌐 Network:", hre.network.name);
  console.log("🔗 Chain ID:", network.chainId);

  // Deploy AuthorizationManager
  const AuthorizationManager = await hre.ethers.getContractFactory(
    "AuthorizationManager"
  );

  const authManager = await AuthorizationManager.deploy(deployer.address);
  await authManager.waitForDeployment();

  const authManagerAddress = await authManager.getAddress();
  console.log("✅ AuthorizationManager deployed at:", authManagerAddress);

  // Deploy SecureVault
  const SecureVault = await hre.ethers.getContractFactory("SecureVault");

  const vault = await SecureVault.deploy(authManagerAddress);
  await vault.waitForDeployment();

  const vaultAddress = await vault.getAddress();
  console.log("✅ SecureVault deployed at:", vaultAddress);

  console.log("\n📌 DEPLOYMENT SUMMARY");
  console.log("--------------------");
  console.log("AuthorizationManager:", authManagerAddress);
  console.log("SecureVault:", vaultAddress);
}

main().catch((error) => {
  console.error("❌ Deployment failed:", error);
  process.exit(1);
});
