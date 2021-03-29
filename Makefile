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
	curl -LO http://github.com/evidlo/remarkable_printer/releases/latest/download/release.zip
	unzip release.zip

# install to device
.PHONY: install
install: printer.arm
	eval $(shell ssh-agent -s)
	ssh -o AddKeysToAgent=yes root@$(host) systemctl stop printer || true
	scp printer.arm root@$(host):
	scp printer.service root@$(host):/etc/systemd/system
	ssh root@$(host) systemctl daemon-reload
	ssh root@$(host) systemctl enable printer
	ssh root@$(host) systemctl restart printer

.PHONY: release
release: printer.arm printer.x86
	rm -f release.zip
	zip release.zip printer.arm printer.x86 printer.service -r

.PHONY: install_config
install_config:
	sudo lpadmin -p reMarkable \
		-E \
		-o printer-error-policy=abort-job \
		-v socket://$(host) \
		-P remarkable.ppd
		# -m lsb/usr/cupsfilters/Generic-PDF_Printer-PDF.ppd
	sudo cp rmfilter /usr/lib/cups/filter

clean:
	rm -f printer.x86 printer.arm release.zip
