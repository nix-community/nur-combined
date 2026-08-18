package main

import "encoding/json"

// The wire between Moonlight OS and this agent.
//
// One line of JSON per message, both directions, UTF-8, no framing beyond the
// newline.  Deliberately dull: the Moonlight OS end is a ~200 line Python
// script with no dependencies, and it has to stay that way.
//
// The point of the whole exercise is that Moonlight OS never learns which
// operating system is at the other end.  It says "these are the devices I am
// offering", and the agent works out whether that means usbip-win2 with a
// bus id or /usr/lib/linux-tools/usbip on Ubuntu.  Every op below is phrased
// in terms of USB devices, never in terms of a platform.

const (
	// ProtocolVersion is bumped only for changes the other end cannot
	// ignore.  Adding a field to a response is not one of those.
	ProtocolVersion = 1

	// DefaultPort is where the agent listens.  Sunshine already owns
	// 47984-47990 and 48010, so this sits clear of the whole block.
	DefaultPort = 48020

	// DefaultUSBIPPort is the port usbipd listens on, on the Moonlight OS
	// side.  Fixed by USB/IP itself.
	DefaultUSBIPPort = 3240
)

type Request struct {
	V     int             `json:"v"`
	ID    string          `json:"id,omitempty"`
	Token string          `json:"token"`
	Op    string          `json:"op"`
	Args  json.RawMessage `json:"args,omitempty"`
}

type Response struct {
	V     int    `json:"v"`
	ID    string `json:"id,omitempty"`
	OK    bool   `json:"ok"`
	Error string `json:"error,omitempty"`
	Code  string `json:"code,omitempty"`
	Data  any    `json:"data,omitempty"`
}

// Error codes.  The Moonlight OS menus switch on these to decide what to
// offer the user, so the strings are part of the contract.
const (
	CodeBadToken     = "bad_token"
	CodeBadRequest   = "bad_request"
	CodeUnknownOp    = "unknown_op"
	CodeNotInstalled = "not_installed" // no USB/IP client on this machine yet
	CodeNeedsReboot  = "needs_reboot"  // driver installed, not live until reboot
	CodeToolFailed   = "tool_failed"
)

// Device is one USB device Moonlight OS is offering.  BusID is the only
// field the agent acts on; the rest exist so the agent's own logs and
// `status` output are readable by a human on the host PC.
type Device struct {
	BusID string `json:"busid"`
	HWID  string `json:"hwid,omitempty"`  // "046d:c52b"
	Label string `json:"label,omitempty"` // "Logitech G920"
}

// SyncArgs is the interesting one.  It is declarative: "this is the complete
// set of devices I am offering right now, make it so".  Anything attached
// from this peer that is not in the list gets detached.
//
// That is what makes unplugging work.  Moonlight OS does not have to notice
// which device went away and send a matching detach -- it just re-sends the
// list, and a device that vanished is simply absent from it.  Replays are
// harmless and a dropped message costs nothing but a late update.
type SyncArgs struct {
	Devices []Device `json:"devices"`
	Server  string   `json:"server,omitempty"` // default: the peer address
	Port    int      `json:"port,omitempty"`   // default: 3240
}

type AttachArgs struct {
	BusID  string `json:"busid"`
	Server string `json:"server,omitempty"`
	Port   int    `json:"port,omitempty"`
}

type DetachArgs struct {
	BusID string `json:"busid,omitempty"`
	All   bool   `json:"all,omitempty"`
}

// Attached is one device currently imported by this machine, as read back
// out of the USB/IP client rather than from anything the agent remembers.
// The agent keeps no state across restarts on purpose -- the kernel (or the
// usbip-win2 driver) already holds the truth, and a cache would only get to
// disagree with it.
type Attached struct {
	Port   int    `json:"port"`
	BusID  string `json:"busid"`
	Server string `json:"server"`
	Label  string `json:"label,omitempty"`
}

type SyncResult struct {
	Attached []string     `json:"attached"`
	Detached []string     `json:"detached"`
	Failed   []FailedItem `json:"failed"`
	Current  []Attached   `json:"current"`
}

type FailedItem struct {
	BusID string `json:"busid"`
	Error string `json:"error"`
}

type PingResult struct {
	Agent       string   `json:"agent"`
	Version     string   `json:"version"`
	Protocol    int      `json:"protocol"`
	OS          string   `json:"os"`
	Arch        string   `json:"arch"`
	Hostname    string   `json:"hostname"`
	ClientTool  ToolInfo `json:"client_tool"`
	NeedsReboot bool     `json:"needs_reboot"`
	Attached    int      `json:"attached"`
}

type ToolInfo struct {
	Present bool   `json:"present"`
	Path    string `json:"path,omitempty"`
	Version string `json:"version,omitempty"`
	Kind    string `json:"kind"` // "usbip" | "usbip-win2"
}

type InstallResult struct {
	Installed   bool     `json:"installed"`
	Actions     []string `json:"actions"`
	NeedsReboot bool     `json:"needs_reboot"`
	Message     string   `json:"message"`
	ClientTool  ToolInfo `json:"client_tool"`
}
