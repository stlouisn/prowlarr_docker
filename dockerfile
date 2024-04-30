FROM stlouisn/ubuntu:latest AS dl

ARG TARGETARCH

ARG APP_VERSION
ARG BRANCH=master

ARG DEBIAN_FRONTEND=noninteractive

RUN \

    # Update apt-cache
    apt-get update && \

    # Install curl
    apt-get install -y --no-install-recommends \
        curl && \

    # Download Prowlarr
    if [ "arm" = "$TARGETARCH" ]   ; then curl -o /tmp/prowlarr.tar.gz -sSL "https://github.com/Prowlarr/Prowlarr/releases/download/v$APP_VERSION/Prowlarr.$BRANCH.$APP_VERSION.linux-core-arm.tar.gz"   ; fi && \
    if [ "arm64" = "$TARGETARCH" ] ; then curl -o /tmp/prowlarr.tar.gz -sSL "https://github.com/Prowlarr/Prowlarr/releases/download/v$APP_VERSION/Prowlarr.$BRANCH.$APP_VERSION.linux-core-arm64.tar.gz" ; fi && \
    if [ "amd64" = "$TARGETARCH" ] ; then curl -o /tmp/prowlarr.tar.gz -sSL "https://github.com/Prowlarr/Prowlarr/releases/download/v$APP_VERSION/Prowlarr.$BRANCH.$APP_VERSION.linux-core-x64.tar.gz" ; fi && \

    # Extract Prowlarr
    mkdir -p /userfs && \
    tar -xf /tmp/prowlarr.tar.gz -C /userfs/ && \

    # Disable Prowlarr-Update
    rm -r /userfs/Prowlarr/Prowlarr.Update/ && \

    # Tag Prowlarr Version
    mkdir -p userfs/etc && \
    echo "$APP_VERSION" > userfs/etc/docker-image && \
    echo "UpdateMethod=docker\nBranch=$BRANCH\nPackageVersion=$APP_VERSION\nPackageAuthor=stlouisn" > userfs/Prowlarr/package_info

FROM stlouisn/ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

COPY rootfs /

RUN \

    # Create prowlarr group
    groupadd \
        --system \
        --gid 10000 \
        prowlarr && \

    # Create prowlarr user
    useradd \
        --system \
        --no-create-home \
        --shell /sbin/nologin \
        --comment prowlarr \
        --gid 10000 \
        --uid 10000 \
        prowlarr && \

    # Update apt-cache
    apt-get update && \

    # Install sqlite
    apt-get install -y --no-install-recommends \
        sqlite3 && \

    # Install unicode support
    apt-get install -y --no-install-recommends \
        libicu74 && \

    # Clean apt-cache
    apt-get autoremove -y --purge && \
    apt-get autoclean -y && \

    # Cleanup temporary folders
    rm -rf \
        /root/.cache \
        /root/.wget-hsts \
        /tmp/* \
        /usr/local/man \
        /usr/local/share/man \
        /usr/share/doc \
        /usr/share/doc-base \
        /usr/share/man \
        /var/cache \
        /var/lib/apt \
        /var/log/*

COPY --chown=prowlarr:prowlarr --from=dl /userfs /

VOLUME /config

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
