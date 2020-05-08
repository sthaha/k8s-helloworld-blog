### Stage 1: Generate Blog ###
FROM ubuntu:latest as BUILD

# Install Hugo.
RUN apt-get update && apt-get -y install wget git

RUN wget https://github.com/gohugoio/hugo/releases/download/v0.63.2/hugo_0.63.2_Linux-64bit.tar.gz && \
    mkdir -p /opt/hugo && \
    tar xfvz hugo_0.63.2_Linux-64bit.tar.gz -C /opt/hugo

COPY . /site

# build the static site files.
RUN /opt/hugo/hugo -v --source=/site --destination=/site/public

### Stage 2: Use nginx to serve blog ###

# Install NGINX and deactivate NGINX's default index.html file.
# This directory is where the static site files will be served from by NGINX.
FROM nginx:stable-alpine

RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/old-index.html

# Move the static site files to NGINX's html directory.
COPY --from=BUILD /site/docker/nginx.conf /etc/nginx/nginx.conf
COPY --from=BUILD /site/docker/default.conf /etc/nginx/conf.d/default.conf
COPY --from=BUILD /site/public/ /usr/share/nginx/html/

# The container will listen on port 80 using the TCP protocol.
EXPOSE 80
