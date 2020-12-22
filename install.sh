mkdir -p /home/root
cd /home/root
wget -O release.zip http://github.com/evidlo/remarkable_printer/releases/latest/download/release.zip
unzip -o release.zip
mv printer.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now printer.service
rm printer.x86 release.zip
