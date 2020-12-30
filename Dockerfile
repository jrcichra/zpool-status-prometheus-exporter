FROM ubuntu:20.10
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
EXPOSE 5000
RUN apt-get update && apt-get install -y \
    zfsutils-linux perl libprometheus-tiny-perl libplack-perl \
    && rm -rf /var/lib/apt/lists/*
CMD perl ./app.psgi