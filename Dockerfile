# must be renewed in every stage, without default value
ARG FOLDER_NAME=app
ARG NODE_IMAGE_VERSION=18.16.0-alpine3.17

# init NextJS app
FROM node:${NODE_IMAGE_VERSION} AS appinit
WORKDIR /app
ARG FOLDER_NAME
ARG NEXT_VERSION=13.4.1
ARG REACT_VERSION=18.2.0
ARG REACT_DOM_VERSION=18.2.0
ENV NODE_ENV=development
ENV FOLDER_NAME=${FOLDER_NAME}

RUN apk add --no-cache libc6-compat

# without controlling create-next version, only next, react and react-dom
RUN yarn add next@${NEXT_VERSION} react@${REACT_VERSION} react-dom@${REACT_DOM_VERSION}
#RUN yarn add next react react-dom

CMD [ "yarn", "create", "next-app", "${FOLDER_NAME}", "--src-dir" ]

# with my edits
FROM node:${NODE_IMAGE_VERSION} AS development
WORKDIR /app
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=development
ARG FOLDER_NAME
ENV FOLDER_NAME=${FOLDER_NAME}
COPY ./${FOLDER_NAME}/package*.json ./${FOLDER_NAME}/yarn.lock ./
# already installed & mapped
RUN yarn install --frozen-lockfile
EXPOSE 3000
CMD [ "yarn", "dev" ]

FROM node:${NODE_IMAGE_VERSION} AS dependencies
ENV NODE_ENV=production
ARG FOLDER_NAME
#ARG FOLDER_NAME=app
ENV FOLDER_NAME=${FOLDER_NAME}
WORKDIR /app
COPY ./${FOLDER_NAME}/package*.json ./${FOLDER_NAME}/yarn.lock ./
RUN yarn install --frozen-lockfile

# builder
FROM node:${NODE_IMAGE_VERSION} AS builder
ENV NODE_ENV=development
ARG FOLDER_NAME
#ARG FOLDER_NAME=app
ENV FOLDER_NAME=${FOLDER_NAME}
WORKDIR /app
COPY ./${FOLDER_NAME} .
RUN yarn install --frozen-lockfile && NODE_ENV=production yarn build

# build for production
FROM node:${NODE_IMAGE_VERSION} AS production
WORKDIR /app
ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production
COPY --chown=node --from=builder /app/next.config.js ./
COPY --chown=node --from=builder /app/public ./public
# * put because folder may or may not exist, depending on settings at create-next-app
COPY --chown=node --from=builder /app/dist* ./dist
COPY --chown=node --from=builder /app/.next ./.next
COPY --chown=node --from=builder /app/yarn.lock /app/package*.json ./
COPY --chown=node --from=dependencies /app/node_modules ./node_modules
USER node
EXPOSE 3000
CMD [ "yarn", "start" ]