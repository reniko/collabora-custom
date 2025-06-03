FROM collabora/code:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Minimaler Ansatz - nur das Nötigste
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      locales \
      debconf-i18n \
      rsync && \
    sed -i 's/^# *\(de_DE.UTF-8 UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen de_DE.UTF-8 && \
    update-locale LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Erstelle systemplate erst nach User-Wechsel oder im Startup-Script
# RUN mkdir -p /opt/cool/systemplate && \
#     rsync -a --delete /etc/ /opt/cool/systemplate/etc/ && \
#     chmod -R 755 /opt/cool/systemplate

ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de:en_US:en \
    LC_ALL=de_DE.UTF-8

# Kopiere das Start-Script
COPY start-collabora.sh /usr/local/bin/start-collabora.sh
RUN chmod +x /usr/local/bin/start-collabora.sh

USER cool

CMD ["/usr/local/bin/start-collabora.sh"]
