FROM collabora/code:24.04

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Installiere deutsche Locales und Tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      locales \
      locales-all \
      debconf-i18n \
      rsync \
      curl && \
    # Deutsche Locale konfigurieren
    echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8 && \
    # Systemplate korrekt vorbereiten
    mkdir -p /opt/cool/systemplate && \
    chown -R cool:cool /opt/cool && \
    rsync -av --delete /etc/ /opt/cool/systemplate/etc/ && \
    mkdir -p /opt/cool/systemplate/{dev,tmp,proc,sys} && \
    cp /etc/{passwd,group,hosts,resolv.conf} /opt/cool/systemplate/etc/ && \
    chmod -R 755 /opt/cool/systemplate && \
    chown -R cool:cool /opt/cool && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Kopiere das Startup-Script
COPY start-collabora.sh /usr/local/bin/start-collabora.sh
RUN chmod +x /usr/local/bin/start-collabora.sh

# Environment-Variablen
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de:en_US:en \
    LC_ALL=de_DE.UTF-8 \
    dictionaries="de_DE en_US" \
    server_name="localhost" \
    extra_params="--o:ssl.enable=false --o:ssl.termination=true"

USER cool

# Verwende unser Startup-Script
ENTRYPOINT ["/usr/local/bin/start-collabora.sh"]

EXPOSE 9980

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:9980/hosting/discovery || exit 1
