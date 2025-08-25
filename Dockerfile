# build do Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.35.1 AS build

WORKDIR /app

# copia o projeto inteiro para dentro do container
COPY . .

# faz o build da aplicação web
RUN flutter build web

# servir com Nginx
FROM nginx:alpine

# remove configs padrão e adiciona a sua
RUN rm -rf /usr/share/nginx/html/*

# copia os arquivos gerados pelo Flutter build
COPY --from=build /app/build/web /usr/share/nginx/html

# expõe a porta 80
EXPOSE 80

# comando padrão do nginx
CMD ["nginx", "-g", "daemon off;"]
