systemctl stop printer.service || true
systemctl stop printer.socket || true
mkdir -p /home/root/bin
cd /home/root/bin
wget -O release.zip http://github.com/evidlo/remarkable_printer/releases/latest/download/release.zip
unzip -o release.zip
mv printer.service /etc/systemd/system
mv printer.socket /etc/systemd/system
systemctl daemon-reload
systemctl enable --now printer.socket
rm printer.x86 release.zip
