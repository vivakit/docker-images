FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV TZ=Etc/UTC
RUN echo "${TZ}" > /etc/timezone \
   && ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime \
   && mkdir -p /app
WORKDIR /app

# Install needed packages for erlang, elixir or phoenix
RUN apt-get update -q \
   && apt-get install -y \
   ca-certificates \
   autoconf \
   make \
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
   libwxgtk3.0-gtk3-dev \
   locales \
   postgis \
   tzdata \
   unixodbc-dev \
   wget \
   xsltproc \
   procps \
   # Python deps
   libssl-dev \
   zlib1g-dev \
   libbz2-dev \
   libreadline-dev \
   libsqlite3-dev \
   xz-utils \
   tk-dev \
   libxml2-dev \
   libxmlsec1-dev \
   libffi-dev \
   liblzma-dev \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

RUN apt-get update -q \
   && apt-get install -y \
   postgis \
   postgresql-12 \
   postgresql-12-postgis-3 \
   postgresql-12-postgis-3-scripts \
   && apt-get clean

RUN mkdir -p /build

# Install ASDF VM and plugins
# ASDF will only correctly install plugins into the home directory
ENV ASDF_VERSION=v0.16.5
ENV ASDF_DATA_DIR=/root/.asdf

RUN mkdir /root/bin \
   && wget https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-amd64.tar.gz \
   && tar -xvzf asdf-${ASDF_VERSION}-linux-amd64.tar.gz -C /root/bin \
   && rm asdf-${ASDF_VERSION}-linux-amd64.tar.gz \
   && chmod +x /root/bin/asdf

ENV PATH=${ASDF_DATA_DIR}/shims:/root/bin:$PATH

# Install asdf plugins
RUN asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git \
   && asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git \
   && asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
   && asdf plugin add python https://github.com/danhper/asdf-python.git

# Set locales & TimeZone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install erlang
ENV ERLANG_VERSION=27.3.3
RUN asdf install erlang ${ERLANG_VERSION} \
   && asdf set erlang ${ERLANG_VERSION}

# Install elixir
ENV ELIXIR_VERSION=1.18.3
RUN asdf install elixir ${ELIXIR_VERSION} \
   && asdf set elixir ${ELIXIR_VERSION}

# Install hex & rebar into container
RUN mix local.hex --force \
   && mix local.rebar --force

# Install nodejs
ENV NODEJS_VERSION=22.14.0
RUN asdf install nodejs ${NODEJS_VERSION} \
   && asdf set nodejs ${NODEJS_VERSION}

# Install python
ENV PYTHON_VERSION=3.12.9
RUN asdf install python ${PYTHON_VERSION} \
   && asdf set python ${PYTHON_VERSION}

RUN asdf list
