// mlos-host-utils runs on the host PC and does the platform half
// of USB passthrough, so that Moonlight OS does not have to.
//
// Moonlight OS already refuses to care what operating system it is streaming
// from -- it speaks one protocol to Sunshine and that is the end of it.  USB
// passthrough was the one place that leaked: the menus had to print a
// different command for Windows than for Linux, and a human had to carry it
// across and run it with the right privileges.  This agent moves that
// knowledge to the machine that actually knows the answer.
//
//	mlos-host-utils install    set everything up, print the pairing code
//	mlos-host-utils status     what is installed and what is attached
//	mlos-host-utils pair       print the pairing code again
//	mlos-host-utils run        run the agent in the foreground
//	mlos-host-utils uninstall  remove all of it
package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"runtime"
	"sort"
	"strings"
)

func usage() {
	fmt.Fprintf(os.Stderr, `mlos-host-utils %s -- USB passthrough agent for Moonlight OS

Runs on the host PC.  Moonlight OS tells it which USB devices are plugged
in at your end; it makes them appear at this end.

  install      install the USB/IP client, start the agent, print the pairing code
  status       show what is installed, paired and attached
  pair         print the pairing code and the addresses to reach this PC on
  run          run the agent in the foreground (what the service does)
  uninstall    stop the agent and remove the service and firewall rule
  testsigning  on|off -- Windows only, and only if the driver refuses to load

Flags:
  --port N     listen on N instead of %d
  --verbose    log every command it runs
`, Version, DefaultPort)
	os.Exit(2)
}

func main() {
	log.SetFlags(log.Ltime)
	log.SetPrefix("")

	// Double-clicked from Explorer there is no command line to give, and a
	// console app that prints usage and exits closes its own window before
	// anyone can read it.  Owning the console is the tell, so that case gets
	// the wizard instead.
	if len(os.Args) < 2 {
		if ownsConsole() {
			runWizard()
			return
		}
		usage()
	}
	cmd := os.Args[1]

	fs := flag.NewFlagSet(cmd, flag.ExitOnError)
	port := fs.Int("port", 0, "TCP port to listen on")
	fs.BoolVar(&verbose, "verbose", false, "log every command")
	_ = fs.Parse(os.Args[2:])

	switch cmd {
	case "install":
		cmdInstall(*port)
	case "wizard":
		runWizard()
	case "run":
		cmdRun(*port)
	case "status":
		cmdStatus()
	case "pair":
		cmdPair()
	case "uninstall":
		cmdUninstall()
	case "testsigning":
		cmdTestSigning(fs.Arg(0))
	case "version", "--version", "-v":
		fmt.Printf("mlos-host-utils %s (%s/%s)\n", Version, runtime.GOOS, runtime.GOARCH)
	case "help", "--help", "-h":
		usage()
	default:
		fmt.Fprintf(os.Stderr, "unknown command %q\n\n", cmd)
		usage()
	}
}

func mustConfig() *Config {
	cfg, err := loadConfig()
	if err != nil {
		die("could not read %s: %v", configPath(), err)
	}
	return cfg
}

func cmdInstall(port int) {
	if !isPrivileged() {
		die("install needs administrator rights -- %s", privilegeHint())
	}

	cfg := mustConfig()
	if port != 0 {
		cfg.Port = port
		if err := saveConfig(cfg); err != nil {
			die("could not save the config: %v", err)
		}
	}

	fmt.Println("Setting up USB passthrough for Moonlight OS.")
	fmt.Println()

	// This used to install itself as moonlight-os-host-utils.  An orphaned
	// copy of the old name is not harmless: it is a second agent holding the
	// same port, so the new one comes up dead and nothing says why.
	if acts := removeLegacyInstall(); len(acts) > 0 {
		fmt.Println("  Older install ... cleaned up")
		for _, a := range acts {
			fmt.Println("      -", a)
		}
	}

	fmt.Print("  USB/IP client ... ")
	res, err := ensureClient()
	if err != nil && !res.Installed {
		fmt.Println("failed")
		die("%s", res.Message)
	}
	if res.Installed {
		fmt.Println("ok")
	} else {
		fmt.Println("not installed")
	}
	for _, a := range res.Actions {
		fmt.Println("      -", a)
	}
	if res.Message != "" {
		fmt.Println("      ", res.Message)
	}

	fmt.Print("  Firewall ... ")
	if acts := openFirewall(cfg.Port); len(acts) > 0 {
		fmt.Println("ok")
		for _, a := range acts {
			fmt.Println("      -", a)
		}
	} else {
		fmt.Println("nothing to do")
	}

	fmt.Print("  Binary ... ")
	exe, binActs, err := installBinary()
	if err != nil {
		fmt.Println("failed")
		die("%v", err)
	}
	if len(binActs) == 0 {
		fmt.Println("already in place")
	} else {
		fmt.Println("ok")
		for _, a := range binActs {
			fmt.Println("      -", a)
		}
	}

	fmt.Print("  PATH ... ")
	if pathActs, err := ensureOnPath(exe); err != nil {
		fmt.Println("skipped")
		fmt.Println("      ", err)
	} else if len(pathActs) == 0 {
		fmt.Println("already there")
	} else {
		fmt.Println("ok")
		for _, a := range pathActs {
			fmt.Println("      -", a)
		}
	}

	fmt.Print("  Agent ... ")
	acts, err := installService(exe, cfg.Port)
	if err != nil {
		fmt.Println("failed")
		for _, a := range acts {
			fmt.Println("      -", a)
		}
		die("%v", err)
	}
	fmt.Println("ok")
	for _, a := range acts {
		fmt.Println("      -", a)
	}

	fmt.Println()
	printPairing(cfg)
	fmt.Println()
	fmt.Printf("  %s is on your PATH now: open a new terminal and run\n", exeName())
	fmt.Println("  `mlos-host-utils status` or `mlos-host-utils pair` from anywhere.")

	if res.NeedsReboot {
		fmt.Println()
		fmt.Println("Reboot this PC before streaming: the USB/IP driver is installed but")
		fmt.Println("does not take effect until then.")
	}
}

func cmdRun(port int) {
	cfg := mustConfig()
	if port != 0 {
		cfg.Port = port
	}
	if !isPrivileged() {
		logf("warning: not running as root/SYSTEM -- attaching devices will fail (%s)", privilegeHint())
	}
	a := NewAgent(cfg)
	if err := a.Serve(cfg.Port); err != nil {
		die("%v", err)
	}
}

func cmdStatus() {
	cfg := mustConfig()

	fmt.Printf("mlos-host-utils %s on %s/%s\n", Version, runtime.GOOS, runtime.GOARCH)
	fmt.Printf("config      %s\n", configPath())
	fmt.Printf("listening   port %d", cfg.Port)
	if listening(cfg.Port) {
		fmt.Println("  (agent is running)")
	} else {
		fmt.Println("  (agent is NOT running)")
	}

	t, present := findTool()
	if present {
		fmt.Printf("usb/ip      %s", t.Path)
		if v := t.Version(); v != "" {
			fmt.Printf("  %s", v)
		}
		fmt.Println()
	} else {
		fmt.Printf("usb/ip      not installed -- run: %s install\n", exeName())
	}
	if needsReboot() {
		fmt.Println("            driver installed but not live until this PC reboots")
	}

	if present {
		list, err := t.Attached()
		if err != nil && list == nil {
			fmt.Printf("attached    could not read the port table: %v\n", err)
		} else if len(list) == 0 {
			fmt.Println("attached    nothing")
		} else {
			fmt.Println("attached")
			for _, a := range list {
				label := a.Label
				if label == "" {
					label = "(unnamed device)"
				}
				fmt.Printf("            port %-2d  %-8s from %-15s  %s\n", a.Port, a.BusID, a.Server, label)
			}
		}
	}
	fmt.Println()
	printPairing(cfg)
}

func cmdPair() {
	printPairing(mustConfig())
}

// printPairing shows the three things that have to be typed into Moonlight
// OS.  The code is boxed rather than listed with the rest: it is the one
// line someone is copying across the room, and after an install it has to be
// findable in a screenful of progress output at a glance.
//
// The box is ASCII on purpose -- box-drawing characters come out as mojibake
// in a legacy Windows console, which is exactly where this gets read.
func printPairing(cfg *Config) {
	code := FormatToken(cfg.Token)
	line := strings.Repeat("-", len(code)+8)
	fmt.Printf("  +%s+\n", line)
	fmt.Printf("  |    %s    |\n", code)
	fmt.Printf("  +%s+\n", line)
	fmt.Println("       ^ the pairing code")
	fmt.Println()

	fmt.Println("  Pair this PC from Moonlight OS:")
	fmt.Println("  Devices & input -> USB passthrough -> Pair this host PC")
	fmt.Println()
	addrs := localAddrs()
	if len(addrs) == 0 {
		fmt.Println("  Address:  (no network address found)")
	} else {
		fmt.Printf("  Address:  %s\n", addrs[0])
		for _, a := range addrs[1:] {
			fmt.Printf("            %s\n", a)
		}
	}
	fmt.Printf("  Port:     %d\n", cfg.Port)
	fmt.Printf("  Code:     %s\n", code)
	fmt.Println()
	fmt.Println("  The dashes and the case do not matter when you type it.")
	fmt.Println("  Keep the code to yourself: anyone with it can plug their own USB")
	fmt.Println("  devices into this PC over the network.")
}

func cmdUninstall() {
	if !isPrivileged() {
		die("uninstall needs administrator rights -- %s", privilegeHint())
	}
	cfg := mustConfig()

	if t, present := findTool(); present {
		if done, err := t.DetachAll(""); err == nil && len(done) > 0 {
			fmt.Printf("detached %d device(s)\n", len(done))
		}
	}
	for _, a := range uninstallService() {
		fmt.Println("-", a)
	}
	for _, a := range removeFromPath() {
		fmt.Println("-", a)
	}
	closeFirewall(cfg.Port)
	fmt.Println("- removed the firewall rule")
	fmt.Println()
	fmt.Printf("The USB/IP client itself was left alone; %s still has it.\n", hostDescription())
	fmt.Printf("The pairing code is still in %s -- delete that directory to forget it.\n", stateDir())
}

func hostDescription() string {
	if runtime.GOOS == "windows" {
		return "Add or remove programs"
	}
	return "your package manager"
}

func cmdTestSigning(arg string) {
	if runtime.GOOS != "windows" {
		die("testsigning is a Windows thing; Linux loads vhci-hcd from the kernel it already trusts")
	}
	if !isPrivileged() {
		die("this needs administrator rights -- %s", privilegeHint())
	}
	switch arg {
	case "on":
		if err := setTestSigning(true); err != nil {
			die("%v", err)
		}
		fmt.Println("Test signing enabled.  Reboot for it to take effect.")
		fmt.Println()
		fmt.Println("This lets Windows load drivers Microsoft has not signed, which is a")
		fmt.Println("real reduction in what the machine checks.  Released usbip-win2")
		fmt.Println("drivers are signed, so try without this first -- and turn it back")
		fmt.Println("off with `testsigning off` if it was not what was wrong.")
	case "off":
		if err := setTestSigning(false); err != nil {
			die("%v", err)
		}
		fmt.Println("Test signing disabled.  Reboot for it to take effect.")
	default:
		die("usage: mlos-host-utils testsigning on|off")
	}
}

func exeName() string {
	if runtime.GOOS == "windows" {
		return "mlos-host-utils.exe"
	}
	return "mlos-host-utils"
}

func listening(port int) bool {
	c, err := net.DialTimeout("tcp", net.JoinHostPort("127.0.0.1", fmt.Sprint(port)), 2e9)
	if err != nil {
		return false
	}
	c.Close()
	return true
}

// localAddrs lists the addresses Moonlight OS could reach this PC on, with
// tailnet addresses first -- if there is a tailnet, that is the one that
// works from anywhere, and it is the one people actually want to type.
func localAddrs() []string {
	ifaces, err := net.Interfaces()
	if err != nil {
		return nil
	}
	var tailnet, lan []string
	for _, ifi := range ifaces {
		if ifi.Flags&net.FlagUp == 0 || ifi.Flags&net.FlagLoopback != 0 {
			continue
		}
		addrs, err := ifi.Addrs()
		if err != nil {
			continue
		}
		for _, a := range addrs {
			ipnet, ok := a.(*net.IPNet)
			if !ok {
				continue
			}
			ip := ipnet.IP
			if ip.IsLoopback() || ip.IsLinkLocalUnicast() || ip.To4() == nil {
				continue
			}
			s := ip.String()
			// Tailscale hands out 100.64.0.0/10.
			if strings.HasPrefix(s, "100.") && isCGNAT(ip) {
				tailnet = append(tailnet, s+"  (tailnet)")
			} else {
				lan = append(lan, s)
			}
		}
	}
	sort.Strings(tailnet)
	sort.Strings(lan)
	return append(tailnet, lan...)
}

func isCGNAT(ip net.IP) bool {
	v4 := ip.To4()
	return v4 != nil && v4[0] == 100 && v4[1] >= 64 && v4[1] <= 127
}
