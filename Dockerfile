# init NextJS app
FROM node:17.1.0-alpine3.12 AS appinit
WORKDIR /app
ENV NODE_ENV=development

RUN apk add --no-cache libc6-compat
RUN yarn add next react react-dom
CMD [ "yarn", "create", "next-app" ]


# from https://github.com/vercel/next.js/discussions/16995#discussioncomment-2074122

# with my edits
FROM node:17.1.0-alpine3.12 AS development
WORKDIR /app
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=development

COPY ./app/package*.json ./app/yarn.lock ./
# already installed & mapped
RUN yarn install --frozen-lockfile
EXPOSE 3000
CMD [ "yarn", "dev" ]

FROM node:17.1.0-alpine3.12 AS dependencies
ENV NODE_ENV=production
WORKDIR /app
COPY ./app/package*.json ./app/yarn.lock ./

RUN yarn install --frozen-lockfile

FROM node:17.1.0-alpine3.12 AS builder
ENV NODE_ENV=development
WORKDIR /app
COPY ./app .
RUN yarn install --frozen-lockfile && NODE_ENV=production yarn build

FROM node:17.1.0-alpine3.12 AS production
WORKDIR /app
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production
COPY --chown=node --from=builder /app/next.config.js ./
COPY --chown=node --from=builder /app/public ./public
COPY --chown=node --from=builder /app/.next ./.next
COPY --chown=node --from=builder /app/yarn.lock /app/package.json ./
COPY --chown=node --from=dependencies /app/node_modules ./node_modules
#for debug purposes COPY --chown=node --from=builder /app/ ./app-builded
USER node
EXPOSE 3000
CMD [ "yarn", "start" ]