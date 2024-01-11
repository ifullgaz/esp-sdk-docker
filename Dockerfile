FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y \
    bison \
    ccache \
    cmake \
    dfu-util \
    flex \
    g++ \
    gcc \
    git \
    gperf \
    libavahi-client-dev \
    libcairo2-dev \
    libdbus-1-dev \
    libffi-dev \
    libgirepository1.0-dev \
    libglib2.0-dev \
    libreadline-dev \
    libssl-dev \
    libusb-1.0-0 \
    ninja-build \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    unzip \
    wget

# Install ESP-IDF SDK
ARG IDF_CLONE_URL=https://github.com/espressif/esp-idf.git
ARG IDF_CHECKOUT_REF=v5.1.1

ENV IDF_PATH=/opt/espressif/esp-idf
ENV IDF_TOOLS_PATH=/opt/espressif/tools
RUN set -x \
    && mkdir -p $IDF_PATH \
    && cd $IDF_PATH \
    && git init \
    && git remote add origin $IDF_CLONE_URL \
    && git fetch origin --depth=1 --recurse-submodules ${IDF_CHECKOUT_REF} \
    && git checkout FETCH_HEAD \
    && git submodule update --init --recursive  --depth 1 \
    && : # last line

# Setup ESP-IDF
RUN set -x \
    && cd $IDF_PATH \
    && ./install.sh \
    && : # last line

# Install ESP-HOMEKIT SDK
ARG ESP_HOMEKIT_CLONE_URL=https://github.com/espressif/esp-homekit-sdk.git
ARG ESP_HOMEKIT_CHECKOUT_REF=master

ENV HOMEKIT_PATH=/opt/espressif/esp-homekit-sdk
RUN set -x \
    && mkdir -p $HOMEKIT_PATH \
    && cd $HOMEKIT_PATH \
    && git init \
    && git remote add origin $ESP_HOMEKIT_CLONE_URL \
    && git fetch origin --depth=1 --recurse-submodules ${ESP_HOMEKIT_CHECKOUT_REF} \
    && git checkout FETCH_HEAD \
    && git submodule update --init --recursive  --depth 1 \
    && : # last line

# Install ESP-MATTER SDK
ARG ESP_MATTER_CLONE_URL=https://github.com/espressif/esp-matter.git
ARG ESP_MATTER_CHECKOUT_REF=main

ENV ESP_MATTER_PATH=/opt/espressif/esp-matter
RUN set -x \
    && mkdir -p $ESP_MATTER_PATH \
    && cd $ESP_MATTER_PATH \
    && git init \
    && git remote add origin $ESP_MATTER_CLONE_URL \
    && git fetch origin --depth=1 ${ESP_MATTER_CHECKOUT_REF} \
    && git checkout FETCH_HEAD \
    && git submodule update --init --depth 1 \
    && cd ./connectedhomeip/connectedhomeip \
    && ./scripts/checkout_submodules.py --platform esp32 linux --shallow \
    && : # last line

# Setup ESP-IDF
RUN set -x \
    && cd $ESP_MATTER_PATH \
    && . $IDF_PATH/export.sh \
    && ./install.sh \
    && : # last line

# Entrypoint script
COPY entrypoint.sh /opt/esp/entrypoint.sh
ENTRYPOINT [ "/opt/esp/entrypoint.sh" ]
CMD [ "/bin/bash" ]
