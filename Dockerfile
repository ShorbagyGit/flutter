# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

# Railway provides PORT dynamically; configure Nginx to use it
RUN echo 'server { listen ${PORT}; location / { root /usr/share/nginx/html; try_files $uri $uri/ /index.html; } }' > /etc/nginx/templates/default.conf.template

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
