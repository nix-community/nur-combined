package main

import "testing"

// Real `usbip port` output.  The Linux and Windows forms are close but not
// identical -- usbip-win2 prints its own speed strings and pads differently
// -- and the whole design leans on one parser handling both, so both are
// pinned here.
const linuxPorts = `Imported USB devices
====================
Port 00: <Port in Use> at Full Speed(12Mbps)
       Logitech, Inc. : G920 Driving Force Racing Wheel (046d:c262)
       1-1 -> usbip://192.168.1.40:3240/1-2
           -> remote bus/dev 001/005
Port 01: <Port in Use> at High Speed(480Mbps)
       Thrustmaster : T-LCM Pedals (044f:b68f)
       2-1 -> usbip://192.168.1.40:3240/1-4.2
           -> remote bus/dev 001/009
`

const windowsPorts = `Imported USB devices
====================
Port 00: device in use at High Speed(480Mbps)
       Guillemot Corp. : Unknown (06f8:b104)
       3-1 -> usbip://100.83.12.7:3240/2-1.3
           -> remote bus/dev 002/004
`

func TestParsePortTableLinux(t *testing.T) {
	got := parsePortTable(linuxPorts)
	if len(got) != 2 {
		t.Fatalf("want 2 entries, got %d: %+v", len(got), got)
	}
	if got[0].Port != 0 || got[0].BusID != "1-2" || got[0].Server != "192.168.1.40" {
		t.Errorf("entry 0 wrong: %+v", got[0])
	}
	// The bus id, not the local vhci port path -- attaching 1-2 and then
	// reading back 1-1 would make every sync think the device vanished
	// and re-attach it forever.
	if got[1].BusID != "1-4.2" {
		t.Errorf("want busid 1-4.2, got %q", got[1].BusID)
	}
	if got[1].Port != 1 {
		t.Errorf("want port 1, got %d", got[1].Port)
	}
	if got[0].Label == "" {
		t.Errorf("label was dropped")
	}
}

func TestParsePortTableWindows(t *testing.T) {
	got := parsePortTable(windowsPorts)
	if len(got) != 1 {
		t.Fatalf("want 1 entry, got %d: %+v", len(got), got)
	}
	if got[0].BusID != "2-1.3" || got[0].Server != "100.83.12.7" {
		t.Errorf("wrong: %+v", got[0])
	}
}

func TestParsePortTableEmpty(t *testing.T) {
	if got := parsePortTable("Imported USB devices\n====================\n"); len(got) != 0 {
		t.Errorf("want nothing attached, got %+v", got)
	}
	if got := parsePortTable(""); len(got) != 0 {
		t.Errorf("want nothing attached, got %+v", got)
	}
}

func TestParsePortTableIPv6(t *testing.T) {
	const s = `Port 00: <Port in Use> at High Speed(480Mbps)
       Some : Device (1234:5678)
       1-1 -> usbip://[fd7a:115c:a1e0::1]:3240/1-2
           -> remote bus/dev 001/005
`
	got := parsePortTable(s)
	if len(got) != 1 {
		t.Fatalf("want 1 entry, got %d", len(got))
	}
	// Brackets stripped: this string is fed straight back to `usbip
	// detach` bookkeeping and compared against the peer address, which
	// never has them.
	if got[0].Server != "fd7a:115c:a1e0::1" {
		t.Errorf("want unbracketed IPv6, got %q", got[0].Server)
	}
}

func TestSameHost(t *testing.T) {
	if !sameHost("192.168.1.5", "192.168.1.5") {
		t.Error("identical addresses should match")
	}
	if !sameHost("[fd7a::1]", "fd7a::1") {
		t.Error("bracketed and bare IPv6 should match")
	}
	if sameHost("192.168.1.5", "192.168.1.6") {
		t.Error("different addresses must not match")
	}
}
