FROM ubuntu:latest
# Using the ruby onbuild image is not currently possible because some gems dependencies
# needs to be resoveld before `bundle install` starts (rugged uses cmake).

ARG DIASPORA_PATH
ARG ENVIRONMENT_REQUIRE_SSL
ARG SERVER_RAILS_ENVIRONMENT
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD

RUN mkdir $DIASPORA_PATH
WORKDIR $DIASPORA_PATH

#  Install dependencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
      build-essential git curl ghostscript libgs-dev imagemagick libmagickwand-dev \
      nodejs redis-server libssl-dev ca-certificates libcurl4-openssl-dev \
      libxml2-dev libxslt1-dev libgmp-dev libpq-dev  cmake tzdata postgresql-client

#  Get and Set up RVM
RUN update-ca-certificates
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -l -s stable --ruby

#  Get the source
RUN git clone -b master https://github.com/diaspora/diaspora.git ./
#  Copy config
RUN cp config/diaspora.yml.example config/diaspora.yml
RUN cp config/database.yml.example config/database.yml
#  Update db config
RUN sed -i -e 's/host: localhost/host: postgres/g' config/database.yml
RUN sed -i -e 's/username: postgres/username: '$POSTGRES_USER'/g' config/database.yml
RUN sed -i -e 's/^  password:$/  password: '$POSTGRES_USER'/g' config/database.yml

#  Bundle
RUN /bin/bash -l -c "gem install bundler"
RUN /bin/bash -l -c "./script/configure_bundler"
RUN /bin/bash -l -c "./bin/bundle install --full-index"

#  Rake
RUN cp config/diaspora.yml.example config/diaspora.yml
RUN /bin/bash -l -c "RAILS_ENV=$SERVER_RAILS_ENVIRONMENT ENVIRONMENT_REQUIRE_SSL=$ENVIRONMENT_REQUIRE_SS ./bin/rake assets:precompile"

COPY start.sh start.sh
#  Booya
CMD /bin/bash -l -c "./start.sh"
