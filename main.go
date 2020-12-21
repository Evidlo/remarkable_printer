// Evan Widloski - 2020-03-10
// thanks to https://coderwall.com/p/wohavg/creating-a-simple-tcp-server-in-go

package main

import (
	"fmt"
	"net"
	"os"
	"os/exec"
	"bufio"
	"strings"
	"io"
	"flag"
	"github.com/google/uuid"
	"time"
)

var (
	CONN_HOST = "0.0.0.0"
	CONN_PORT = "9100"
	LOG_LEVEL = "error"
	XOCHITL_DIR = "/home/root/.local/share/remarkable/xochitl/"
)

const METADATA_TEMPLATE = `{
    "deleted": false,
    "lastModified": "%d000",
    "metadatamodified": true,
    "modified": true,
    "parent": "",
    "pinned": false,
    "synced": false,
    "type": "DocumentType",
    "version": 0,
    "visibleName": "%v"
}
`


func main() {

	// ----- Parse options -----

	debug := flag.Bool("debug", false, "enable debug output")
	test := flag.Bool("test", false, "use /tmp as output dir")
	restart := flag.Bool("restart", false, "restart xochitl after saving PDF")
	CONN_HOST := flag.String("host", CONN_HOST, "override bind address")
	CONN_PORT := flag.String("port", CONN_PORT, "override bind port")

	flag.Parse()

	if *debug {
		LOG_LEVEL = "debug"
	}
	if *test {
		XOCHITL_DIR = "/tmp/"
	}

	// ----- Listen for connections -----

	// Listen for incoming connections.
	l, err := net.Listen("tcp", *CONN_HOST + ":" + *CONN_PORT)
	check(err)
	defer l.Close()

	// Close the listener when the application closes.
	fmt.Println("Listening on " + *CONN_HOST + ":" + *CONN_PORT)
	for {
		// Listen for an incoming connection.
		conn, err := l.Accept()
		if err != nil {
			fmt.Println("Error accepting: ", err.Error())
			os.Exit(1)
		}
		handleRequest(conn)

		// Restart xochitl
		if *restart {
			stdout, err := exec.Command("systemctl", "restart", "xochitl").CombinedOutput()
			if err != nil {
				fmt.Println("xochitl restart failed with message:", string(stdout))
			}
		}

	}
}


func debug(msg ...string) {
	if LOG_LEVEL == "debug" {
		fmt.Println(msg)
	}
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}


// Handles incoming requests.
func handleRequest(conn net.Conn) {
	u, _ := uuid.NewRandom()
	pdf_path := XOCHITL_DIR + u.String() + ".pdf"
	fmt.Println("Saving PDF to", pdf_path)

	// ----- Create .pdf -----

	f, err := os.Create(pdf_path)
	check(err)

	reader := bufio.NewReader(conn)
	// Default name of new document
	title := "Printed"
	// Read until start of PDF
	for {
		line, err := reader.ReadString('\n')
		debug(line)
		// set print job name as file title
		if strings.HasPrefix(line, "@PJL JOB NAME") {
			title = strings.Split(line, "\"")[1]
			debug("Setting title to", title)
		}
		// PDF section started
		if strings.HasPrefix(line, "%PDF-") {
			debug("PDF begin")
			_, err := f.WriteString(line)
			check(err)
			break
		}
		if err == io.EOF {
			fmt.Println("Couldn't find PDF start")
			os.Exit(1)
		}
		check(err)
	}
	// Read until end of PDF
	for {
		line, err := reader.ReadString('\n')
		_, err = f.WriteString(line)
		check(err)
		// end of pdf file
		if strings.HasPrefix(line, "%%EOF") {
			f.Close()
			break
		}
		if err == io.EOF {
			debug(line)
			debug("Couldn't find PDF end")
			os.Exit(1)
		}
		check(err)
	}

	// ----- Create .metadata -----

	meta_path := XOCHITL_DIR + u.String() + ".metadata"
	fmt.Println("Saving metadata to", meta_path)
	f, err = os.Create(meta_path)
	f.WriteString(fmt.Sprintf(METADATA_TEMPLATE, time.Now().Unix(), title))
	f.Close()

	conn.Close()
}
