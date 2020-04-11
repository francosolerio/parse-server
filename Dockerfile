# Build stage
FROM node:lts-alpine as build

RUN apk update; \
  apk add git python3 make g++;
WORKDIR /tmp
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Release stage
FROM node:lts-alpine as release

RUN apk update; \
  apk add git;

VOLUME /parse-server/cloud /parse-server/config

WORKDIR /parse-server

COPY package*.json ./

RUN npm ci --production --ignore-scripts

COPY bin bin
COPY public_html public_html
COPY views views
COPY push push
COPY parse-digitalia-config.json parse-digitalia-config.json
COPY --from=build /tmp/lib lib
RUN mkdir -p logs && chown -R node: logs

ENV PORT=1337
USER node
EXPOSE $PORT

ENTRYPOINT ["node", "./bin/parse-server", "parse-digitalia-config.json"]
