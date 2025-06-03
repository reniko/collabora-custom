#!/bin/bash
set -e

echo "🚀 Starting Collabora CODE with German locale support..."

# Erstelle und aktualisiere systemplate bei jedem Start
echo "📁 Setting up systemplate..."
sudo mkdir -p /opt/cool/systemplate/{dev,tmp,proc,sys}
sudo rsync -a --delete /etc/ /opt/cool/systemplate/etc/
sudo cp /etc/{passwd,group,hosts,resolv.conf} /opt/cool/systemplate/etc/ 2>/dev/null || true
sudo chmod -R 755 /opt/cool/systemplate
sudo chown -R cool:cool /opt/cool
echo "✅ systemplate setup complete"

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
