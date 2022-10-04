# zpool-status-prometheus-exporter
Simple Perl Prometheus exporter for `zpool status`. Know when your pool had problems.

# Dependencies (needs >= Ubuntu 20.10)
`sudo apt install perl libprometheus-tiny-perl libplack-perl`

# Usage
`./app.psgi` - shebang calls `plackup`
# Docker
Since most things aren't on Ubuntu 20.10 yet, you can use the docker container:
`docker run --privileged --name zpool-status-prometheus-exporter --restart unless-stopped -it -d -p 5000:5000 ghcr.io/jrcichra/zpool-status-prometheus-exporter`
