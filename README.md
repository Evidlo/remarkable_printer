# remarkable_printer

Print natively to your reMarkable wirelessly with no extensions or reMarkable cloud.

![](img.jpg)

## Quick Start

Connect the reMarkable via USB and make sure it has internet access.

Connect to the reMarkable with [SSH](https://remarkable.guide/guide/access/ssh.html) and execute

    wget -O - http://evidlo.github.io/remarkable_printer/install.sh | sh
    
Then configure your OS to print to the reMarkable, shown below.
    
## Adding the reMarkable as a printer

#### Linux/OSX (easy)

    make install_config host=10.11.99.1

#### Linux (manual)

We will add the reMarkable as an Appsocket/JetDirect printer and use the PDF printer driver.

    $ sudo system-config-printer
    # Add > Network Printer > AppSocket/HP JetDirect
    # Enter the address/hostname of the device (10.11.99.1 for USB connected device)
    # Forward > Generic > Forward > PDF > Forward
    # Set the printer name and save
    
You may need to install system-config-printer first.
    
#### OSX (manual)

See [Add a network printer by its IP address](https://support.apple.com/guide/mac-help/add-a-printer-on-mac-mh14004/mac).  Use `10.11.99.1` for the address and `HP Jetdirect` for the protocol.

#### Windows (manual)

See [here](https://github.com/Evidlo/remarkable_printer/wiki/Windows-Setup)

#### Caveats

No authentication, so keep WiFi off while not in use.

## How it works

Virtually all network printers accept raw Postscript/PDF data on TCP port 9100 via the Appsocket/HP Jetdirect protocol.  Sometimes this data is preceded by a few plaintext lines telling the printer information such as the print job name and print settings.

This setup simply listens on TCP 9100 and upon data sent waits for a PDF header, then begins saving data to a pdf file (while also creating the accompanying .metadata file) and then exits again, waiting for the next connection on the port to repeat the procedure.  The output filename is extracted from the print job name line, if it exists.

## Testing on host

    $ make printer.x86
    $ ./printer.x86 -h
    Usage of ./printer.x86:
      -debug
            enable debug output
      -host string
            override bind address (default "0.0.0.0")
      -port string
            override bind port (default "9100")
      -restart
            restart xochitl after saving PDF
      -test
            use /tmp as output dir

## Debugging

On the reMarkable (via [SSH](https://remarkablewiki.com/tech/ssh))

    journalctl --unit printer -f
    
Then try to print a document.
