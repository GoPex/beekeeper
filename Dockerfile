# Uses GoPex ubuntu_rails stock image
FROM gopex/ubuntu_rails:5.0.0.beta2
MAINTAINER Albin Gilles "albin.gilles@gmail.com"
ENV REFRESHED_AT 2016-02-13

# Set the port exposed by this application
EXPOSE 3000

# Override the rails entry point with launching our application with puma
ENTRYPOINT ["puma"]

# Send parameter to our entrypoint
CMD ["-C", "./config/puma.rb"]
