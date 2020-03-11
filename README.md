# remarkable_printer

Print natively to your reMarkable wirelessly with no extensions or reMarkable cloud.

![](img.jpg)

## Install

Assuming you have Go installed, simply run (with reMarkable connected via USB)

    make install
    
This will install and start the printer service on the reMarkable.
    
If you don't have go, you can download and unzip the precompiled binary from the releases page to this directory then run the above command.

## Adding the reMarkable as a printer

#### Linux (easy)

Modify printer.conf and change 10.11.99.1 to your reMarkable's address/hostname, then run

    make install_config

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
