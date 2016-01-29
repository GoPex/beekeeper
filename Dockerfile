# Uses GoPex Ubuntu stock image
FROM gopex/ubuntu_ruby:2.3.0
MAINTAINER Albin Gilles "albin.gilles@gmail.com"
ENV REFRESHED_AT 2016-01-29.6

# Default port used by Sinatra
EXPOSE 9292

# Prepare container for our app
ENV APP_DIR /beewolf
RUN mkdir -p $APP_DIR && mkdir -p /var/log
WORKDIR $APP_DIR
COPY . .

# Install required gems
RUN bundle install
