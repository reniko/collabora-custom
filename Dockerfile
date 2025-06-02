FROM collabora/code:latest

USER root

RUN mkdir -p /var/lib/apt/lists/partial && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        debconf-i18n \
        rsync && \
    sed -i 's/^# *\(de_DE.UTF-8 UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen de_DE.UTF-8 && \
    update-locale LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8 && \
    mkdir -p /opt/cool/systemplate && \
    rsync -a --delete /etc/ /opt/cool/systemplate/etc/ && \
    chmod -R 755 /opt/cool/systemplate && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
