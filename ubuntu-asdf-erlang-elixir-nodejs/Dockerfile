FROM ubuntu:18.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV TZ Etc/UTC
RUN echo "${TZ}" > /etc/timezone
RUN ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime

# Install needed packages for erlang, elixir or phoenix
RUN apt-get update -q \
 && apt-get install -y \
    autoconf \
    build-essential \
    curl \
    fop \
    git \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libncurses5-dev \
    libpng-dev \
    libpq-dev \
    libssh-dev \
    libwxgtk3.0-dev \
    locales \
    postgis \
    tzdata \
    unixodbc-dev \
    wget \
    xsltproc \
 && apt-get clean

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main"-pgdg main | tee /etc/apt/sources.list.d/pgdg.list

RUN apt-get update -q \
 && apt-get install -y \
    postgis \
    postgresql-11 \
    postgresql-11-postgis-2.5 \
    postgresql-11-postgis-2.5-scripts \
 && apt-get clean

RUN mkdir -p /build

# Install ASDF VM and plugins
# ASDF will only correctly install plugins into the home directory
ENV ASDF_ROOT /root/.asdf
ENV ASDF_VERSION v0.7.4
ENV PATH "${ASDF_ROOT}/bin:${ASDF_ROOT}/shims:$PATH"

RUN git clone https://github.com/asdf-vm/asdf.git "${ASDF_ROOT}" --branch "${ASDF_VERSION}" \
  && asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git \
  && asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git \
  && asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
  && ${ASDF_ROOT}/plugins/nodejs/bin/import-release-team-keyring

# Set locales & TimeZone
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install erlang
ENV ERLANG_VERSION 22.1
RUN asdf install erlang ${ERLANG_VERSION} \
 && asdf global erlang ${ERLANG_VERSION}

# Install elixir
ENV ELIXIR_VERSION 1.9.1-otp-22
RUN asdf install elixir ${ELIXIR_VERSION} \
 && asdf global elixir ${ELIXIR_VERSION}

# Install hex & rebar into container
RUN mix local.hex --force \
 && mix local.rebar --force

# Install nodejs
ENV NODEJS_VERSION 10.16.3
RUN asdf install nodejs ${NODEJS_VERSION} \
 && asdf global nodejs ${NODEJS_VERSION}
