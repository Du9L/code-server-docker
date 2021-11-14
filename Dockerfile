# syntax=docker/dockerfile:1.2

FROM debian:11

# Set user name and home path (/home/$USER).
# Note: This is a build-time argument and cannot be changed later (e.g. during `docker run`).
ARG USER=user

RUN --mount=type=bind,target=/opt/installer \
    # Note: `code-server` DEB installer should be downloaded and placed in the same folder as Dockerfile as `code-server.deb`
    set -eux; \
    # Create user first to ensure a consistent UID
    useradd --create-home --uid 1000 "$USER"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        dumb-init \
        zsh \
        htop \
        locales \
        man \
        nano \
        git \
        procps \
        openssh-client \
        sudo \
        vim.tiny \
        lsb-release \
    ; \
    \
    sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen; \
    locale-gen; \
    \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd; \
    \
    # Install main code-server package
    apt install -y /opt/installer/code-server.deb; \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    USER=$USER

EXPOSE 8080

WORKDIR /home/$USER

USER 1000

ENTRYPOINT [ \
    "dumb-init", \
    "/usr/bin/code-server" \
]

CMD [ \
    "--bind-addr", \
    "0.0.0.0:8080", \
    "." \
]
