# syntax=docker/dockerfile:1

# FROM ubuntu:latest
# https://hub.docker.com/_/buildpack-deps
FROM buildpack-deps:22.04

RUN <<NUR
    # apt update
    # apt install -y git build-essential libncurses-dev

    git clone https://github.com/sbabic/swupdate.git
    cd swupdate
    ./ci/setup.sh || true # Linking command fails on arm64
    ./ci/install-src-deps.sh
NUR

COPY ./.config /swupdate/.config
