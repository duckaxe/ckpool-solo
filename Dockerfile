FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    CKPOOL_DIR=/opt/ckpool \
    CONF_FILE=/ckpool-conf/ckpool.conf

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    yasm \
    autoconf \
    automake \
    libtool \
    pkgconf \
    libzmq3-dev \
    ca-certificates && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-ca-certificates --fresh

WORKDIR ${CKPOOL_DIR}

RUN git clone https://github.com/duckaxe/ckpool-solo.git . && \
    ./autogen.sh && \
    ./configure CFLAGS="-O2" && \
    make -j$(nproc)

RUN mkdir -p /logs /runtime

VOLUME ["/logs", "/runtime", "/ckpool-conf"]

EXPOSE 3333

CMD bash -c 'if [ ! -f "$CONF_FILE" ]; then echo "Missing config: $CONF_FILE"; exit 1; fi; /opt/ckpool/src/ckpool -k -B -c "$CONF_FILE"'