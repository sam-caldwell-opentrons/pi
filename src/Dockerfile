# Raspberry Probe Image Builder
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#
# This docker file will create an AMD64 or ARM64 environment
# with QEMU for building Raspberry Pi images using QEMU and
# hashicorp packer.
#
ARG GO_VERSION=1.17.2

#ToDo: Move this Repo to opentrons.
ARG PACKER_PLUGIN_REPO="https://github.com/sam-caldwell-opentrons/packer-builder-arm.git"
ARG APT_ARGS="-y --no-install-recommends"
#
# Create a base image 
#
FROM ubuntu:latest AS base_image
ARG APT_ARGS
ENV DOCKER_ENTRYPOINT=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
## preesed tzdata, update package index, upgrade packages and install needed software
RUN truncate -s0 /tmp/preseed.cfg; \
    echo "tzdata tzdata/Areas select Etc" >> /tmp/preseed.cfg; \
    echo "tzdata tzdata/Zones/Europe select UTC" >> /tmp/preseed.cfg; \
    debconf-set-selections /tmp/preseed.cfg && \
    rm -f /etc/timezone /etc/localtime && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tzdata && \
    rm /tmp/preseed.cfg || true \
RUN unminimize
RUN apt-get install ${APT_ARGS} ca-certificates
RUN apt-get install ${APT_ARGS} apt-transport-https
RUN apt-get install ${APT_ARGS} git
RUN apt-get install ${APT_ARGS} wget
RUN apt-get install ${APT_ARGS} dosfstools
RUN apt-get install ${APT_ARGS} gdisk
RUN apt-get install ${APT_ARGS} kpartx
RUN apt-get install ${APT_ARGS} parted
RUN apt-get install ${APT_ARGS} psmisc
RUN apt-get install ${APT_ARGS} kmod
RUN apt-get install ${APT_ARGS} sudo
RUN apt-get install ${APT_ARGS} unzip
RUN apt-get install ${APT_ARGS} upx-ucl
RUN apt-get install ${APT_ARGS} xz-utils
RUN apt-get install ${APT_ARGS} binutils
RUN apt-get install ${APT_ARGS} qemu-utils
RUN apt-get install ${APT_ARGS} qemu-user-binfmt
RUN apt-get install ${APT_ARGS} qemu-system-common
RUN apt-get install ${APT_ARGS} qemu-system-arm
RUN apt-get install ${APT_ARGS} qemu-system-data
RUN apt-get install ${APT_ARGS} qemu-efi-aarch64
RUN apt-get install ${APT_ARGS} libarchive-tools



FROM base_image AS raspbian_base
WORKDIR /build
RUN wget https://downloads.raspberrypi.org/raspbian_lite_latest && \
    unzip -p raspbian_lite_latest > base.img
    #ToDo: Verify hash


FROM base_image AS builder_base
ARG APT_ARGS
ARG GO_VERSION
ENV DOCKER_ENTRYPOINT=noninteractive
ENV PATH=${PATH}:/usr/local/go/bin
WORKDIR /build
RUN echo "Removing old go (if it exists)"  && \
    rm -rf /usr/local/go &> /dev/null
RUN case "$(uname -m)" in \
    "aarch64") \
      export ARCH="arm64" \
      ;; \
    "*") \
      export ARCH="amd64" \
      ;; \
    esac && \
    export GO_PKG="go${GO_VERSION}.linux-${ARCH}.tar.gz" && \
    export GO_URL="https://golang.org/dl/${GO_PKG}" && \
    echo "ARCH: ${ARCH}" && \
    echo "GO_URL: ${GO_URL}" && \
    echo "GO_PKG: ${GO_PKG}" && \
    echo "Downloading '${GO_URL}'" && \
    while true; do \
      echo "download go..." && \
      wget -T 15 -c "${GO_URL}" && break; \
      echo -n "sleep before try again...";\
      for i in $(seq 1 5); do echo -n ".";sleep 1; done;\
      echo ""; \
    done && \
    echo "Unpack tar: ${GO_PKG}" && \
    ls -la "${GO_PKG}" && \
    tar -C /usr/local -xzf ${GO_PKG} && \
    go version
#
# Finally, create our image_builder image.
#
FROM base_image AS image_builder
ARG APT_ARGS
ENV PACKER=/bin/packer
ENV DONT_SETUP_QEMU=1
RUN rm -rf /var/lib/apt/lists/*
WORKDIR /build

RUN mkdir -p /build/scripts/
COPY --from=raspbian_base /build/base.img /build/
COPY src/ /build/

# This is the directory where we will write the output artifact.
RUN mkdir /output

# This entrypoint will build a raspberry pi image and store it in /output
ENTRYPOINT ["/build/main.sh"]
