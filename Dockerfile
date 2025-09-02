FROM ubuntu:24.04
EXPOSE 5000
RUN apt-get update && apt-get install -y \
    zfsutils-linux perl libprometheus-tiny-perl libplack-perl \
    && rm -rf /var/lib/apt/lists/*
COPY . /app/
WORKDIR /app/
ENTRYPOINT [ "perl", "/app/app.psgi" ]
