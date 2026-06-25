# syntax=docker/dockerfile:1

# --- Stage 1: install production dependencies
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# --- Stage 2: minimal production runtime
FROM node:22-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app

# tini = a tiny, valid PID 1 that forwards signals (clean graceful shutdown)
RUN apk add --no-cache tini

COPY --from=deps /app/node_modules ./node_modules
COPY package.json ./
COPY index.js ./
COPY src ./src

# Run as the built-in unprivileged user
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "index.js"]
