FROM debian:bullseye-slim AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV TZ=Etc/UTC
RUN echo "${TZ}" > /etc/timezone \
   && ln -fs "/usr/share/zoneinfo/${TZ}" /etc/localtime \
   && mkdir -p /app
WORKDIR /app

RUN apt-get update \
   && apt-get install -y locales \
   && rm -rf /var/lib/apt/lists/* \
   && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
   && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
   && locale-gen en_US.UTF-8 \
   && dpkg-reconfigure locales \
   && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:UTF-8
ENV LC_ALL=en_US.UTF-8

# Fix a bug for openjdk-11-jre-headless before installing all OS dependencies
RUN mkdir -p /usr/share/man/man1 \
   && apt-get update -q \
   && apt-get install -y \
   ca-certificates \
   autoconf \
   make \
   build-essential \
   wget \
   git \
   libpq-dev \
   libssh-dev \
   locales \
   tzdata \
   # Python deps
   libssl-dev \
   libffi-dev \
   zlib1g-dev \
   libbz2-dev \
   libreadline-dev \
   libsqlite3-dev \
   xz-utils \
   tk-dev \
   libxml2-dev \
   libxmlsec1-dev \
   liblzma-dev \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
   && echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main"-pgdg main | tee /etc/apt/sources.list.d/pgdg.list \
   && apt-get update -q \
   && apt-get install -y \
   postgis \
   postgresql-14 \
   postgresql-14-postgis-3 \
   postgresql-14-postgis-3-scripts \
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
RUN asdf plugin add python https://github.com/danhper/asdf-python.git

# Set locales & TimeZone
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install python
ENV PYTHON_VERSION=3.12.9
RUN asdf install python ${PYTHON_VERSION} \
   && asdf set python ${PYTHON_VERSION}

# Install b2 CLI
ENV B2_VERSION 4.3.0
RUN python -m pip install b2==${B2_VERSION}

ENV PATH=/root/.asdf/installs/python/${PYTHON_VERSION}/bin:$PATH

# Check commands are available
RUN b2 --help
RUN pg_dump --help

# Add backup script
ADD ./backup.sh /app
RUN chmod +x /app/backup.sh
