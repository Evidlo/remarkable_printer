# remarkable_printer

Print natively to your reMarkable wirelessly with no extensions or reMarkable cloud.

![](img.jpg)

## Install

With the reMarkable connected via USB, execute

    make download_prebuilt
    make install
    
This will install and start the printer service on the reMarkable.
    
Alternatively, you can build the executable yourself by omitting the `make download_prebuilt` step.

## Adding the reMarkable as a printer

#### Linux (easy)

Set `10.11.99.1` to your device's address or hostname.

    make install_config host=10.11.99.1

#### Linux (manual)

We will add the reMarkable as an Appsocket/JetDirect printer.

Linux

    $ sudo system-config-printer
    # Add > Network Printer > AppSocket/HP JetDirect
    # Enter the address/hostname of the device (10.11.99.1 for USB connected device)
    # Forward > Generic > Forward > PDF > Forward
    # Set the printer name and save
    
#### OSX (manual)

See [Add a network printer by its IP address](https://support.apple.com/guide/mac-help/add-a-printer-on-mac-mh14004/mac).  Choose `HP Jetdirect` for the protocol.

#### Caveats

No authentication, so keep WiFi off while not in use.

## How it works

Virtually all network printers accept raw Postscript/PDF data on TCP port 9100 via the Appsocket/HP Jetdirect protocol.  Sometimes this data is preceded by a few plaintext lines telling the printer information such as the print job name and print settings.

This script simply listens on TCP 9100 and waits for a PDF header, then begins saving data to a pdf file (while also creating the accompanying .metadata file).  The output filename is extracted from the print job name line, if it exists.

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
