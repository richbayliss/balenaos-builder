FROM debian:stretch-slim

# Add s6-overlay for service management
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# Non-interactive debconf package configuration
ARG DEBIAN_FRONTEND=noninteractive

# Add Debian repositories for docker and npm
RUN apt-get update && apt-get install -y curl lsb-release software-properties-common apt-transport-https ca-certificates gnupg2  && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && curl -sL https://deb.nodesource.com/setup_12.x | bash -

# Update Debian and Install Yocto Proyect Quick Start and Balena dependencies
RUN apt-get update && apt-get install -y locales gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm cpio curl python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa pylint3 xterm dos2unix vim sudo chrpath gawk docker-ce docker-ce-cli containerd.io nodejs npm jq file && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# # Set bash as default shell
# RUN echo "dash dash/sh boolean false" | debconf-set-selections - && dpkg-reconfigure dash

# Set the locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.utf8 \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8

# Install docker in docker
ARG DIND_COMMIT=52379fa76dee07ca038624d639d9e14f4fb719ff
ENV DOCKER_EXTRA_OPTS '--storage-driver=overlay'
RUN curl -fL -o /usr/local/bin/dind "https://raw.githubusercontent.com/moby/moby/${DIND_COMMIT}/hack/dind" && \
    chmod +x /usr/local/bin/dind

# Install repo
RUN curl -o /usr/local/bin/repo http://commondatastorage.googleapis.com/git-repo-downloads/repo && chmod a+x /usr/local/bin/repo

# Create the DIND service
RUN mkdir -p /etc/services.d/dind
COPY ./dind /etc/services.d/dind

# User management
RUN groupadd -g 1000 builder && \
    useradd -u 1000 -g 1000 -ms /bin/bash builder && \
    echo "builder:builder" | chpasswd && \
    echo "alias build='sudo -H -u builder ./balena-yocto-scripts/build/barys'" >> /root/.bashrc && \
    usermod -a -G docker builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY build-image.sh /build-image.sh
RUN chown builder:builder /build-image.sh && \
    chmod u+s /build-image.sh && \
    chmod g+s /build-image.sh

RUN mkdir /build

EXPOSE 2375
VOLUME ["/var/lib/docker","/build"]

WORKDIR /build
ENTRYPOINT ["/init"]
CMD ["/build-image.sh"]