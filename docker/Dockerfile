FROM node:18-alpine

WORKDIR /app

# Install dependencies first (better caching)
COPY package.json package-lock.json ./
RUN npm install

# Copy rest of the project
COPY . .

# Compile smart contracts
RUN npx hardhat compile

# Run deployment on container start
CMD ["sh", "./docker/entrypoint.sh"]
