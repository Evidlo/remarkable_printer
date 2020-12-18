mkdir -p /home/root/bin
cd /home/root/bin
curl -LO http://github.com/evidlo/remarkable_printer/releases/latest/download/release.zip
unzip release.zip
mv printer.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now printer.service
rm printer.x86 release.zip
