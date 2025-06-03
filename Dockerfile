FROM collabora/code:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Installiere notwendige Pakete und konfiguriere Locales
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      locales \
      locales-all \
      debconf-i18n \
      rsync \
      curl && \
    # Konfiguriere deutsche und englische Locales
    echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8 && \
    # Erstelle systemplate Verzeichnis mit korrekten Berechtigungen
    mkdir -p /opt/cool/systemplate && \
    mkdir -p /opt/cool/systemplate/{dev,tmp,proc,sys} && \
    # Synchronisiere /etc nach systemplate
    rsync -av --delete /etc/ /opt/cool/systemplate/etc/ && \
    # Kopiere wichtige Systemdateien
    cp /etc/passwd /opt/cool/systemplate/etc/ && \
    cp /etc/group /opt/cool/systemplate/etc/ && \
    cp /etc/hosts /opt/cool/systemplate/etc/ && \
    cp /etc/resolv.conf /opt/cool/systemplate/etc/ && \
    # Setze Berechtigungen
    chmod -R 755 /opt/cool/systemplate && \
    chown -R cool:cool /opt/cool && \
    # Aufräumen
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setze Umgebungsvariablen für deutsche Lokalisierung
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de:en_US:en \
    LC_ALL=de_DE.UTF-8

# Kopiere das Start-Script
COPY start-collabora.sh /usr/local/bin/start-collabora.sh
RUN chmod +x /usr/local/bin/start-collabora.sh

USER cool

# Verwende das angepasste Start-Script
CMD ["/usr/local/bin/start-collabora.sh"]
