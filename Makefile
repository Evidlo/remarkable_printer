.ONESHELL:
.SILENT:

host=10.11.99.1

printer.arm:
	go get ./...
	env GOOS=linux GOARCH=arm GOARM=5 go build -o printer.arm

printer.x86:
	go get ./...
	go build -o printer.x86

# get latest prebuilt releases
.PHONY: download_prebuilt
download_prebuilt:
	wget http://github.com/evidlo/remarkable_printer/releases/latest/download/release.zip

# install to device
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

.PHONY: release
release: printer.arm printer.x86
	rm -f release.zip
	zip release.zip ./ -r

.PHONY: install_config
install_config:
	sudo lpadmin -p reMarkable \
		-E \
		-o printer-error-policy=abort-job \
		-v socket://$(host) \
		-m lsb/usr/cupsfilters/Generic-PDF_Printer-PDF.ppd

clean:
	rm -f printer.x86 printer.arm release.zip
