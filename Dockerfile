# Use Node.js 22 Alpine image as the build stage
FROM node:22-alpine AS builder

RUN apk update && apk upgrade --no-cache

# Set the working directory inside the container
WORKDIR /app

# Copy only package.json and package-lock.json first, This allows Docker to cache dependencies if they don't change "Best Practices"
COPY package*.json ./

# Install project dependencies
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Build the production version of the application, This generates the "dist" folder "/app/dist"
RUN npm run build

# Second stage: use nginx to serve the built application
FROM nginx:alpine AS server

# Copy the built static files from the builder stage /app/dist -> default nginx static directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 so the container can serve HTTP traffic
EXPOSE 80

# Start nginx in the foreground
# "daemon off;" keeps nginx running so the container does not exit
CMD ["nginx", "-g", "daemon off;"]