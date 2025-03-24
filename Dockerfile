FROM node:20-slim AS build

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack disable && npm install -g pnpm@latest

COPY . /app
WORKDIR /app

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build:local

FROM node:20-slim AS prod

WORKDIR /app

COPY --from=build /app/packages/apps/local/dist/index.js /app/dist/index.js
COPY --from=build /app/packages/apps/local/package-docker.json /app/package.json
# Copy the Bash script into the container
COPY create-configs.sh /app/create-configs.sh

# Ensure the script is executable
RUN chmod +x /app/create-configs.sh

RUN npm install
EXPOSE 8787

# Run the script at runtime before starting the application
CMD ["/bin/bash", "-c", "/app/create-configs.sh && node /app/dist/index.js"]
