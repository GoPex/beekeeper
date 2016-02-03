# Uses Busybox as test image
FROM busybox
MAINTAINER Albin Gilles "albin.gilles@gmail.com"
ENV REFRESHED_AT 2016-02-02

# Set the entrypoint
ENTRYPOINT ["tail"]
# Set the cmd
CMD ["-f", "/dev/null"]

# Set the beekeeper label
LABEL beekeeper="0.1.0"

# Set the port exposed
EXPOSE 3000
