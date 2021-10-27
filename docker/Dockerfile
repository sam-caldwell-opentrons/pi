# Raspberry Probe Image Builder
# (c) 2021 Opentrons, Inc.  <samuel.caldwell@opentrons.com>
#
# This docker file will create an AMD64 or ARM64 environment
# with QEMU for building Raspberry Pi images using QEMU and
# hashicorp packer.
#
ARG GO_VERSION=1.17.2
ARG PACKER_VERSION=1.7.7

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
    apt-get install -y tzdata
RUN apt-get install ${APT_ARGS} ca-certificates
RUN apt-get install ${APT_ARGS} git
RUN apt-get install ${APT_ARGS} wget
RUN apt-get install ${APT_ARGS} dosfstools
RUN apt-get install ${APT_ARGS} gdisk
RUN apt-get install ${APT_ARGS} kpartx
RUN apt-get install ${APT_ARGS} parted
RUN apt-get install ${APT_ARGS} psmisc
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
#
# Extend the base image to create a golang build environment
#
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
    wget "${GO_URL}"&& \
    echo "Unpack tar: ${GO_PKG}" && \
    ls -la "${GO_PKG}" && \
    tar -C /usr/local -xzf ${GO_PKG} && \
    go version
#
# Download the packer artifact using our base_image.
# This just increases build speed.
#
FROM base_image AS packer_artifact
ARG PACKER_VERSION
RUN case "$(uname -m)" in \
        "aarch64") \
          ARCH="arm64" \
          ;; \
        "*") \
          ARCH="amd64" \
          ;; \
        esac && \
    echo "ARCH: ${ARCH}" && \
    wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${ARCH}.zip \
         -q \
         -O /tmp/packer.zip && \
    unzip /tmp/packer.zip -d /bin && \
    rm /tmp/packer.zip
RUN upx-ucl --lzma /bin/packer
#
# Use our builder image to build the packer raspberry pi plugin.
#
FROM builder_base AS plugin_builder
ARG PACKER_PLUGIN_REPO
RUN git clone ${PACKER_PLUGIN_REPO} && \
    cd packer-builder-arm && \
    go mod download && \
    go build -o packer-builder-arm && \
    upx-ucl --lzma /build/packer-builder-arm/packer-builder-arm
#
# Finally, create our image_builder image.
#
FROM base_image AS image_builder
ARG APT_ARGS
ENV PACKER=/bin/packer
ENV DONT_SETUP_QEMU=1
RUN rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY docker/entrypoint.sh /entrypoint.sh
COPY --from=packer_artifact /bin/packer /bin/
COPY --from=plugin_builder /build/packer-builder-arm /bin/
COPY --from=base_image /usr/bin/ /usr/bin

ENTRYPOINT ["/entrypoint.sh"]
