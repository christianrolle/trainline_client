FROM ruby:3.4-slim

# Allow apt to work with https-based sources
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
  apt-get install -yqq --no-install-recommends \
  build-essential \
  libpq-dev \
  libyaml-dev \
  apt-utils \
  apt-transport-https \
  vim \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

COPY Gemfile* /usr/src/app/
ENV BUNDLE_PATH=/app/vendor/bundle
ENV GEM_HOME=/app/vendor/bundle/ruby/3.4.3

WORKDIR /usr/src/app
RUN bundle install
COPY . /usr/src/app/

CMD [ "tail", "-f", "/dev/stdout" ]
