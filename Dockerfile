# Dockerfile
FROM ubuntu:12.04

RUN apt-get update -qq && apt-get install -y ca-certificates sudo curl git-core
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN curl -L https://get.rvm.io | bash -s stable
ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN /bin/bash -l -c rvm requirements
RUN source /usr/local/rvm/scripts/rvm && rvm install ruby-2.0.0-p247
RUN rvm all do gem install bundler

#TODO With Docker 0.8
#ONBUILD ADD . /opt/landing-page
#ONBUILD WORKDIR /opt/landing-page
#ONBUILD RUN rvm all do bundle install
#ONBUILD CMD rvm all do bundle exec unicorn -p $PORT config.ru
ADD . /opt/middleman-app
WORKDIR /opt/middleman-app
RUN rvm all do bundle install
CMD rvm all do bundle exec unicorn -p 4567 config.ru

EXPOSE 4567
