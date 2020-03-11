.ONESHELL:
host=10.11.99.1

printer.arm:
	env GOOS=linux GOARCH=arm GOARM=5 go build -o printer.arm

printer.x86:
	go build -o printer.x86

.PHONY: install
install: printer.arm
	ssh-add
	ssh root@$(host) systemctl stop printer
	scp printer.arm root@$(host):
	scp printer.service root@$(host):/etc/systemd/system
	ssh root@$(host) <<- ENDSSH
		systemctl daemon-reload
		systemctl enable printer
		systemctl restart printer
	ENDSSH

.PHONY: fetch_prebuilt
fetch_prebuilt:
	wget https://github.com/evidlo/remarkable_printer/releases/latest/download/printer.zip

.PHONY: install_prebuilt
install_prebuilt: fetch_prebuilt install

.PHONY: install_config
install_config:
	sudo cat printer.conf >> /etc/cups/printers.conf

clean:
	rm printer.x86 printer.arm
