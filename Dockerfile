# syntax=docker/dockerfile:1

# FROM ubuntu:latest
# https://hub.docker.com/_/buildpack-deps
FROM buildpack-deps:22.04

ARG TARGETPLATFORM

RUN <<NUR
    # apt update
    # apt install -y git build-essential libncurses-dev

    git clone https://github.com/sbabic/swupdate.git
    cd swupdate

    if [ ${TARGETPLATFORM} = "linux/arm64" ];
    then
        # Linking command (at end of script) fails on arm64
        ./ci/setup.sh || true
        # Install lua libs separately for arm64
        apt update && apt install -y liblua5.4-dev
    else
        ./ci/setup.sh
    fi

    ./ci/install-src-deps.sh
NUR

COPY ./.config /swupdate/.config

WORKDIR /swupdate
