FROM node:22-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY app.js ./
COPY bin ./bin
COPY routes ./routes
COPY views ./views
COPY public ./public
ENV NODE_ENV=production
CMD ["npm", "start"]
