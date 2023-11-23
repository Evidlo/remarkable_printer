# remarkable_printer

Print natively to your reMarkable wirelessly with no extensions or reMarkable cloud.

![](img.jpg)

## Quick Start

Connect the reMarkable via USB and make sure it has internet access.

Connect to the reMarkable with [SSH](https://remarkable.guide/guide/access/ssh.html) and execute

    wget -O - http://raw.githubusercontent.com/Evidlo/remarkable_printer/master/install.sh | sh
    
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

#### CUPS Website

Alternatively, if we use the CUPS printer service under Linux, we can use the local CUPS webservice to install the PDF printer. 

    open localhost:631
    go to Administration
    select Add Printer
    select Other Network Printers: AppSocket/HP JetDirect
    Enter the address/hostname under Connection e.g. socket:10.11.99.1 for USB
    Enter a Printer Name, Description and Location as you like
    Under Make: select `Generic` and press Continue
    Under Model: select `Generic PDF Printer` and select Add Printer
    Set Printer Default Options as desired (standard would be ok).
    
    Under the newly created Printer, select Maintainance and then Print Test Page.      
    
You may need to install system-config-printer first.
    
#### OSX (manual)

See [Add a network printer by its IP address](https://support.apple.com/guide/mac-help/add-a-printer-on-mac-mh14004/mac).  Use `10.11.99.1` for the address and `HP Jetdirect` for the protocol.

#### Windows (manual)

See [here](https://github.com/Evidlo/remarkable_printer/wiki/Windows-Setup)

#### Caveats

No authentication, so keep WiFi off while not in use.

## How it works

Virtually all network printers accept raw Postscript/PDF data on TCP port 9100 via the Appsocket/HP Jetdirect protocol.  Sometimes this data is preceded by a few plaintext lines telling the printer information such as the print job name and print settings.

This script simply listens on TCP 9100 and waits for a PDF header, then begins saving data to a pdf file (while also creating the accompanying .metadata file).  The output filename is extracted from the print job name line, if it exists.
Unforuntately, xochitl (the main programm running on the remarkable tablet) needs to get restarted to identify the new document. This will be done automatically by the printer-service on the remarkable. Thus, we can observe the new start of xochtil after a print. This is normal and intended and not a crash of xochitl.

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
