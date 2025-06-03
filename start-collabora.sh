#!/bin/bash
set -e

echo "🚀 Starting Collabora CODE with German locale support..."

# Prüfe systemplate bei jedem Start
if [ -d "/opt/cool/systemplate" ] && [ -w "/opt/cool/systemplate" ]; then
    echo "📁 Updating systemplate..."
    rsync -a --delete /etc/ /opt/cool/systemplate/etc/
    cp /etc/{passwd,group,hosts,resolv.conf} /opt/cool/systemplate/etc/
    echo "✅ systemplate updated"
fi

# Zeige Locale-Info
echo "🌍 Current locale: $(locale | grep LANG)"

# Starte Collabora mit korrekten Parametern
echo "🔧 Starting coolwsd..."
exec /usr/bin/coolwsd \
    --version \
    --o:sys_template_path=/opt/cool/systemplate \
    --o:child_root_path=/opt/cool/child-roots \
    --o:file_server_root_path=/usr/share/coolwsd \
    "$@"
