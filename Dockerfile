# Serves the prebuilt Flutter web bundle (build/web) on Cloud Run's port 8080.
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY build/web /usr/share/nginx/html
EXPOSE 8080
