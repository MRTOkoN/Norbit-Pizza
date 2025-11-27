# Multi-stage Dockerfile
# Stage 1: install dependencies
FROM node:18-alpine AS deps
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --silent || npm install --silent

# Stage 2: final image
FROM node:18-alpine
WORKDIR /usr/src/app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
EXPOSE 3000

# Default start command (production). For development override with `npm run dev` in docker-compose or locally.
CMD ["node", "index.js"]
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package manifests and install dependencies
COPY package*.json ./
RUN npm install --production=false

# Copy source
COPY . .

EXPOSE 3000

# Default command: use dev script so nodemon works for development; override in production
CMD ["npm", "run", "dev"]
FROM node:18-alpine

WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production || npm install --only=production

# Copy source
COPY . .

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "index.js"]
