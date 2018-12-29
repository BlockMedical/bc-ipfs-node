FROM blcksync/go11-node:latest as builder

ENV SHELL=/bin/bash \
    IPFS_USER=ipfsuser \
    IPFS_UID=3888 \
    IPFS_GID=4888 \
    GOPATH=/go
ENV HOME=/home/$IPFS_USER

WORKDIR /root

RUN addgroup -g $IPFS_GID $IPFS_USER && \
    adduser -u $IPFS_UID -g $IPFS_GID -h $HOME -S -s /bin/bash $IPFS_USER && \
    chmod g+w /etc/passwd /etc/group && \
    source /etc/profile.d/go_path.sh && \
    chown -R $IPFS_UID:$IPFS_GID $HOME && \
    apk update && apk upgrade && \
    apk add --no-cache bash git \
    busybox-extras \
    python \
    python-dev \
    py-pip \
    libtool \
    autoconf \
    automake \
    build-base \
    make gcc musl-dev linux-headers \
    && rm -rf /var/cache/apk/* && \
    echo "export PATH=/usr/local/go/bin:\$GOPATH/bin:\$PATH:\$HOME/bin" > /etc/profile.d/go_path.sh

# Install go-ipfs and gx
RUN source /etc/profile.d/go_path.sh && \
    go get -u -d github.com/ipfs/go-ipfs && cd $GOPATH/src/github.com/ipfs/go-ipfs && \
    git remote add blcksync-v0.4.18 https://github.com/alee-blocksync/go-ipfs.git && git fetch blcksync-v0.4.18 && \
    git checkout blcksync-v0.4.18 && \
    make install_unsupported

USER $IPFS_UID

WORKDIR $HOME

# Install ipfs JS API
RUN mkdir $HOME/bin && \
    npm install --save \
    ipfs-http-client@28.1.0 \
    dat@13.11.4 \
    && ln -s $HOME/node_modules/dat/bin/cli.js $HOME/bin/dat ;

FROM blcksync/alpine-node:latest

LABEL maintainer="matr1xc0in"

ENV SHELL=/bin/bash \
    IPFS_USER=ipfsuser \
    IPFS_UID=3888 \
    IPFS_GID=4888 \
    GOPATH=/go
ENV HOME=/home/$IPFS_USER

USER root
WORKDIR /root

RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates bash git busybox-extras && \
    rm -rf /var/cache/apk/* && \
    echo "export PATH=/usr/local/go/bin:\$GOPATH/bin:\$PATH:\$HOME/bin" > /etc/profile.d/go_path.sh

COPY --from=builder /usr/local/go/bin/* /usr/local/go/bin/
COPY --from=builder /go/bin/* /go/bin/

# Install go-ipfs and gx
RUN addgroup -g $IPFS_GID $IPFS_USER && \
    adduser -u $IPFS_UID -g $IPFS_GID -h $HOME -S -s /bin/bash $IPFS_USER && \
    chmod g+w /etc/passwd /etc/group && \
    source /etc/profile.d/go_path.sh && \
    chown -R $IPFS_UID:$IPFS_GID $HOME && \
    chown -R $IPFS_UID:$IPFS_GID /usr/local/go/bin/* && \
    chown -R $IPFS_UID:$IPFS_GID /go/bin/* && \
    mkdir -p $HOME/ipfs && chown -R $IPFS_UID:$IPFS_GID $HOME/ipfs ; \
    echo "export IPFS_PATH=$HOME/ipfs" > /etc/profile.d/ipfs_path.sh

ENV IPFS_VERSION=0.4.18 \
    IPFS_SHA256=48a81cfc34d3a12c8563dbdfae8681be6e4d23c0664d6a192bc2758c4e4ef377

USER $IPFS_UID

WORKDIR $HOME

COPY ./bin/*.sh $HOME/bin/

CMD ["/home/ipfsuser/bin/launch.sh"]

# Ports for Swarm TCP, Swarm uTP, API, Gateway, Swarm Websockets
EXPOSE 4001
EXPOSE 4002/udp
EXPOSE 5001
EXPOSE 8080
EXPOSE 8081
