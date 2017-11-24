# Format: FROM repository[:version]
FROM phusion/passenger-ruby24:0.9.26

# Format: MAINTAINER Name <email@addr.ess>
MAINTAINER Scorix <scorix@gmail.com>

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
RUN rm /etc/nginx/sites-available/default

# Set correct environment variables.
ENV HOME /root
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install ffmpeg with speex
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    SRC=/usr/local

RUN echo "deb http://us.archive.ubuntu.com/ubuntu trusty main multiverse" >> /etc/apt/sources.list

RUN buildDeps="autoconf \
               automake \
               cmake \
               curl \
               bzip2 \
               g++ \
               gcc \
               git \
               libtool \
               make \
               nasm \
               perl \
               pkg-config \
               python \
               libssl-dev \
               yasm \
               zlib1g-dev" && \
    export MAKEFLAGS="-j$(($(nproc) + 1))" && \
    apt-get -yqq update && \
    apt-get install -yq --no-install-recommends ${buildDeps} ca-certificates && \
    apt-get install -yq libspeex-dev && \
    DIR=$(mktemp -d) && cd ${DIR}
## ffmpeg https://ffmpeg.org/
ENV FFMPEG_VERSION 3.4
RUN curl -sL https://github.com/FFmpeg/FFmpeg/archive/n$FFMPEG_VERSION.tar.gz | \
    tar -zx --strip-components=1 && \
    ./configure \
    --disable-yasm \
    --enable-libspeex && \
    make -j4 && \
    make install && \
    make distclean && \
    apt-get purge -y ${buildDeps} && \
    apt-get autoremove -y && \
    apt-get clean -y
