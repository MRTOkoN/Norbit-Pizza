# Multi-stage Dockerfile to build Flutter web and serve with nginx
# Builder stage: installs Flutter SDK, enables web, runs pub get and builds web release
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \ 
    ca-certificates \ 
    git \ 
    curl \ 
    unzip \ 
    xz-utils \ 
    zip \ 
    libglu1-mesa \ 
    wget \ 
    gnupg2 \ 
    openjdk-11-jdk \ 
    python3 \ 
    python3-pip \ 
 && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_ROOT=/opt/flutter
ENV PATH="$FLUTTER_ROOT/bin:$PATH"

# Clone Flutter SDK (stable channel)
RUN git clone --depth 1 https://github.com/flutter/flutter.git -b stable ${FLUTTER_ROOT}

WORKDIR /app

# Copy project files
COPY . /app

# Ensure web enabled and get packages
RUN flutter channel stable || true
RUN flutter --version
RUN flutter config --enable-web
RUN flutter pub get

# Build web release
RUN flutter build web --release

# Final image: nginx serving the built web app
FROM nginx:stable-alpine

# Copy built web output from builder
COPY --from=builder /app/build/web /usr/share/nginx/html

# Add a simple nginx config to ensure correct headers (overrides default)
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
