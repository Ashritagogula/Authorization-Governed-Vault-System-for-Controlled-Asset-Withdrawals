FROM node:18-alpine

WORKDIR /app

# Install dependencies first (better caching)
COPY package.json package-lock.json ./
RUN npm install

# Copy rest of the project
COPY . .

# Compile smart contracts
RUN npx hardhat compile

# Deploy contracts on container start
CMD ["npx", "hardhat", "run", "scripts/deploy.js", "--network", "docker"]
