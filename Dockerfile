# Verwende ein spezifisches Tag für bessere Reproduzierbarkeit
FROM collabora/code:24.04

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Installiere deutsche Locales und notwendige Tools
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
    # Systemplate-Verzeichnis korrekt vorbereiten
    # Das ist wichtig für die Jail-Funktionalität von Collabora
    mkdir -p /opt/cool/systemplate && \
    # Stelle sicher, dass systemplate beschreibbar ist
    chown -R cool:cool /opt/cool && \
    # Synchronisiere System-Templates für Jail-Umgebung
    rsync -av --delete /etc/ /opt/cool/systemplate/etc/ && \
    # Wichtige Verzeichnisse für Jail-Umgebung
    mkdir -p /opt/cool/systemplate/{dev,tmp,proc,sys} && \
    mkdir -p /opt/cool/systemplate/etc/{passwd,group,hosts,resolv.conf} && \
    # Kopiere wichtige Dateien für Jail
    cp /etc/passwd /opt/cool/systemplate/etc/ && \
    cp /etc/group /opt/cool/systemplate/etc/ && \
    cp /etc/hosts /opt/cool/systemplate/etc/ && \
    cp /etc/resolv.conf /opt/cool/systemplate/etc/ && \
    # Setze korrekte Permissions
    chmod -R 755 /opt/cool/systemplate && \
    chown -R cool:cool /opt/cool && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Environment-Variablen für deutsche Locale
ENV LANG=de_DE.UTF-8 \
    LANGUAGE=de_DE:de:en_US:en \
    LC_ALL=de_DE.UTF-8 \
    LC_CTYPE=de_DE.UTF-8 \
    LC_NUMERIC=de_DE.UTF-8 \
    LC_TIME=de_DE.UTF-8 \
    LC_COLLATE=de_DE.UTF-8 \
    LC_MONETARY=de_DE.UTF-8 \
    LC_MESSAGES=de_DE.UTF-8 \
    LC_PAPER=de_DE.UTF-8 \
    LC_NAME=de_DE.UTF-8 \
    LC_ADDRESS=de_DE.UTF-8 \
    LC_TELEPHONE=de_DE.UTF-8 \
    LC_MEASUREMENT=de_DE.UTF-8 \
    LC_IDENTIFICATION=de_DE.UTF-8

# Zusätzliche Collabora-spezifische Umgebungsvariablen
ENV dictionaries="de_DE en_US" \
    server_name="localhost" \
    extra_params="--o:ssl.enable=false --o:ssl.termination=true"

# Zurück zum original User
USER cool

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:9980/hosting/discovery || exit 1

# Expose Port
EXPOSE 9980

# Labels für bessere Metadaten
LABEL maintainer="your-email@example.com"
LABEL description="Collabora CODE with German locale support"
LABEL version="1.0"
