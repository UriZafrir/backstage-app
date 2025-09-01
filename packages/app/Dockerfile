FROM nginx:alpine
COPY packages/app/dist/ /usr/share/nginx/html/
COPY packages/app/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]