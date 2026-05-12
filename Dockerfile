# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

# Write an nginx config template with PORT placeholder
RUN echo 'server { listen __PORT__; location / { root /usr/share/nginx/html; try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf.template

# At runtime, substitute PORT and start nginx
CMD ["/bin/sh", "-c", "sed s/__PORT__/$PORT/g /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
