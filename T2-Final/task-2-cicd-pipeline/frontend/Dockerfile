FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Build the production version
RUN npm run build

# Install serve to serve the static files
RUN npm install -g serve

EXPOSE 3000

# Serve the production build
CMD ["serve", "-s", "build", "-l", "3000"] 