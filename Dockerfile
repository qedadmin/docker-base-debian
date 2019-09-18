FROM    debian:buster-slim
LABEL   maintainer="QED"

ARG     BUILD_DATE
ARG     VCS_REF
ARG     BUILD_VERSION=0.1.0

## s6 overlay
ARG     S6_OVERLAY_VERSION="v1.22.1.0"
ARG     S6_OVERLAY_ARCH="amd64"


ENV     DEFAULTDOMAIN="" \
        NISSERVERS="" \
        TZ="UTC"


LABEL   org.label-schema.schema-version="1.0" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.name="docker-base-debian" \
        org.label-schema.description="Custom Debian 10 base image" \
        org.label-schema.url="https://github.com/qedadmin/docker-base-debian" \
        org.label-schema.vcs-url="https://github.com/qedadmin/docker-base-debian.git" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vendor="qedadmin" \
        org.label-schema.version=$BUILD_VERSION


## Install packages
RUN     \        
        echo "**** Install packages ****" && \
        apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install -y \
        acl apt-transport-https autofs \
        bc build-essential \
        curl \
        dnsutils \
        emacs \
        gnupg gnumeric \
        net-tools nfs-common nis \
        p7zip p7zip-full perl procps \
        rpcbind \
        socat ssh sudo sysstat \
        timelimit tmux \
        unzip \
        vim \
        wget \
        xterm xxdiff \
        zip && \
        echo "**** Clean up packages ****" && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*


## root filesystem
COPY    root /

## s6 overlay
ADD     https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.gz /tmp/s6-overlay.tar.gz
RUN     \
        echo "**** Install s6 overlay ****" && \
        tar xvfz /tmp/s6-overlay.tar.gz -C / && \
        rm /tmp/s6-overlay.tar.gz

RUN     echo "**** Done ****"

## init
ENTRYPOINT [ "/init" ]
