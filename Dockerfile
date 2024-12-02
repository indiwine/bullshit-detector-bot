FROM node:20.16-alpine AS base

FROM base AS prepare_build
WORKDIR /build
COPY . .
RUN --mount=type=cache,target=/root/.npm npm install &&  \
    npm run 'build:prod' &&  \
    rm -rf node_modules src

FROM prepare_build AS build
WORKDIR /app

# Copy the dist folder and package.json to the app directory
COPY --from=prepare_build /build ./

# Install only production dependencies
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev &&  \
    rm -rf /build

# Expose the port the app runs in
EXPOSE 3000

# Serve the app
CMD ["npm", "run", "start:prod"]


FROM base AS dev_build
WORKDIR /app
COPY . .
RUN --mount=type=cache,target=/root/.npm npm install

CMD ["npm", "run", "start:debug"]





