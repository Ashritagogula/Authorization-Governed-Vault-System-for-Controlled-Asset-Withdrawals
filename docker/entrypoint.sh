#!/bin/sh
set -e

echo "Starting local deployment..."

# Deploy contracts to local network
npx hardhat run scripts/deploy.js --network localhost

echo "Deployment completed."

# Keep container alive if needed (optional but safe)
tail -f /dev/null
