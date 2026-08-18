//go:build windows

package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
	"time"
	"unsafe"
)

// The scheduled task carries the program's name, so it renamed with it.  The
// old name is not just left behind: removeLegacyInstall deletes it, because
// two boot tasks racing for one port is worse than either alone.
const taskName = "MlosHostUtils"

func configDir() string {
	if d := os.Getenv("ProgramData"); d != "" {
		return filepath.Join(d, "mlos-host-utils")
	}
	return filepath.Join(os.Getenv("SystemDrive")+`\`, "mlos-host-utils")
}

// isPrivileged tests for Administrator the way that actually works without
// pulling in golang.org/x/sys: try to open a handle only an administrator
// gets.  Reading \\.\PHYSICALDRIVE0 needs the privilege and changes nothing.
func isPrivileged() bool {
	f, err := os.Open(`\\.\PHYSICALDRIVE0`)
	if err == nil {
		f.Close()
		return true
	}
	// No physical drive 0 on some VMs; fall back to a directory only
	// administrators may write to.
	probe := filepath.Join(os.Getenv("SystemRoot"), "System32", "mlos-probe.tmp")
	if f, err := os.Create(probe); err == nil {
		f.Close()
		os.Remove(probe)
		return true
	}
	return false
}

func privilegeHint() string {
	return "run this from an Administrator PowerShell or Command Prompt"
}

// The agent runs from a scheduled task with no desktop, but the CLI is used
// interactively -- without this every usbip call flashes a console window.
func hideWindow(cmd *exec.Cmd) {
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
}

// Windows ships no USB/IP client at all, in either direction that matters
// here.  usbipd-win (the winget one) is a *server*: it exports devices from
// Windows to WSL and Linux.  It cannot import, and upstream says it never
// will.  usbip-win2 is the only thing that does this direction, so it is
// what gets installed.
func findTool() (Tool, bool) {
	candidates := []string{}
	for _, env := range []string{"ProgramFiles", "ProgramW6432", "ProgramFiles(x86)"} {
		if d := os.Getenv(env); d != "" {
			candidates = append(candidates,
				filepath.Join(d, "USBip", "usbip.exe"),
				filepath.Join(d, "usbip-win2", "usbip.exe"))
		}
	}
	for _, p := range candidates {
		if st, err := os.Stat(p); err == nil && !st.IsDir() {
			return Tool{Path: p, Kind: "usbip-win2"}, true
		}
	}
	// Only after the known locations: a usbip.exe on PATH could be the
	// WSL helper shipped by usbipd-win, which is a different program.
	if p, err := exec.LookPath("usbip.exe"); err == nil {
		return Tool{Path: p, Kind: "usbip-win2"}, true
	}
	return Tool{}, false
}

// Where install puts the binary, so the scheduled task still finds it after
// the download folder it was run from has been cleared out.
func installedExePath() string {
	dir := os.Getenv("ProgramFiles")
	if dir == "" {
		dir = filepath.Join(os.Getenv("SystemDrive")+`\`, "Program Files")
	}
	return filepath.Join(dir, "mlos-host-utils", "mlos-host-utils.exe")
}

// isPackagedLocation reports whether winget owns this binary.  A portable
// winget package is unpacked under %LOCALAPPDATA%\Microsoft\WinGet\Packages
// and reached through a shim in the sibling Links directory, which is on
// PATH -- so the file is already permanent, already reachable, and already
// something `winget upgrade` expects to be the one in use.
func isPackagedLocation(p string) bool {
	local := os.Getenv("LOCALAPPDATA")
	if local == "" {
		return false
	}
	abs, err := filepath.Abs(p)
	if err != nil {
		return false
	}
	root := filepath.Join(local, "Microsoft", "WinGet") + string(filepath.Separator)
	return strings.HasPrefix(strings.ToLower(abs), strings.ToLower(root))
}

// ---------------------------------------------------------------- PATH ----

// The machine PATH lives in the registry, and it is edited there rather than
// with setx: setx silently truncates anything past 1024 characters, and a
// machine PATH on a PC that has had a few SDKs on it is routinely longer
// than that.  Truncating the system PATH is not a bug anyone would connect
// back to a USB passthrough agent.
const pathEnvKey = `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`

// readSystemPath returns the machine PATH and the registry type it is stored
// as, because rewriting a REG_EXPAND_SZ as REG_SZ turns every %SystemRoot%
// already in there into a literal that resolves to nothing.
func readSystemPath() (value, kind string, err error) {
	out, err := output("reg.exe", "query", pathEnvKey, "/v", "Path")
	if err != nil {
		return "", "", fmt.Errorf("could not read the system PATH: %w", err)
	}
	return parseRegPath(out)
}

// parseRegPath pulls the value out of `reg query` output, which is
//
//	<blank>
//	HKEY_LOCAL_MACHINE\SYSTEM\...\Environment
//	    Path    REG_EXPAND_SZ    C:\Windows;C:\Program Files\Git\cmd
//
// The value is taken as everything after the type token rather than by
// splitting on whitespace, because directory names in it contain spaces --
// "C:\Program Files\..." is in every real PATH there is.
func parseRegPath(out string) (value, kind string, err error) {
	for _, line := range strings.Split(out, "\n") {
		fields := strings.Fields(line)
		if len(fields) < 2 || !strings.EqualFold(fields[0], "Path") ||
			!strings.HasPrefix(fields[1], "REG_") {
			continue
		}
		kind = fields[1]
		rest := line[strings.Index(line, kind)+len(kind):]
		return strings.TrimSpace(rest), kind, nil
	}
	return "", "", fmt.Errorf("no Path value under %s", pathEnvKey)
}

func pathContains(pathValue, dir string) bool {
	for _, e := range strings.Split(pathValue, ";") {
		e = strings.TrimRight(strings.TrimSpace(e), `\`)
		if strings.EqualFold(e, strings.TrimRight(dir, `\`)) {
			return true
		}
	}
	return false
}

func writeSystemPath(value, kind string) error {
	if kind == "" {
		kind = "REG_EXPAND_SZ"
	}
	// A value ending in a backslash would escape the closing quote Windows
	// puts around the argument, and reg.exe would see a mangled PATH.
	value = strings.TrimRight(value, `\`)
	if err := run("reg.exe", "add", pathEnvKey, "/v", "Path", "/t", kind, "/d", value, "/f"); err != nil {
		return err
	}
	broadcastEnvChange()
	return nil
}

// ensureOnPath puts the install directory on the machine PATH, so that
// `mlos-host-utils status` works in a terminal the way it does on Linux --
// where /usr/local/bin has already answered this question.
func ensureOnPath(exe string) ([]string, error) {
	if isPackagedLocation(exe) {
		// winget's own Links directory is on PATH and holds the shim; the
		// package directory this binary actually lives in is not meant to be.
		return nil, nil
	}
	dir := filepath.Dir(exe)
	value, kind, err := readSystemPath()
	if err != nil {
		return nil, err
	}
	if pathContains(value, dir) {
		return nil, nil
	}
	if !strings.HasSuffix(value, ";") {
		value += ";"
	}
	if err := writeSystemPath(value+dir, kind); err != nil {
		return nil, fmt.Errorf("could not add %s to the system PATH: %w", dir, err)
	}
	return []string{
		"added " + dir + " to the system PATH",
		"terminals already open keep the old PATH -- open a new one",
	}, nil
}

func removeFromPath() []string {
	dir := filepath.Dir(installedExePath())
	value, kind, err := readSystemPath()
	if err != nil || !pathContains(value, dir) {
		return nil
	}
	kept := []string{}
	for _, e := range strings.Split(value, ";") {
		trimmed := strings.TrimRight(strings.TrimSpace(e), `\`)
		if trimmed == "" || strings.EqualFold(trimmed, strings.TrimRight(dir, `\`)) {
			continue
		}
		kept = append(kept, e)
	}
	if err := writeSystemPath(strings.Join(kept, ";"), kind); err != nil {
		return nil
	}
	return []string{"removed " + dir + " from the system PATH"}
}

var (
	user32                    = syscall.NewLazyDLL("user32.dll")
	procSendMessageTimeout    = user32.NewProc("SendMessageTimeoutW")
	kernel32                  = syscall.NewLazyDLL("kernel32.dll")
	procGetConsoleProcessList = kernel32.NewProc("GetConsoleProcessList")
)

// broadcastEnvChange is what makes the new PATH reach a terminal opened a
// second from now.  Processes read the environment once, at startup, from
// whatever their parent handed them; Explorer only refreshes its own copy
// when it is told the environment changed.  Without this the PATH edit does
// not appear until the next sign-in, which reads as "it did not work".
func broadcastEnvChange() {
	const (
		hwndBroadcast   = 0xFFFF
		wmSettingChange = 0x001A
		smtoAbortIfHung = 0x0002
	)
	env, err := syscall.UTF16PtrFromString("Environment")
	if err != nil {
		return
	}
	var result uintptr
	procSendMessageTimeout.Call(hwndBroadcast, wmSettingChange, 0,
		uintptr(unsafe.Pointer(env)), smtoAbortIfHung, 5000,
		uintptr(unsafe.Pointer(&result)))
}

// ownsConsole reports whether this process is the only one attached to its
// console, which is the difference between being double-clicked in Explorer
// -- Windows makes a console just for us, and destroys it, and the window,
// the moment we exit -- and being run from a terminal that was already
// there.  Only in the first case does printing usage and exiting show the
// user a window that blinks and is gone.
func ownsConsole() bool {
	var pids [4]uint32
	n, _, _ := procGetConsoleProcessList.Call(
		uintptr(unsafe.Pointer(&pids[0])), uintptr(len(pids)))
	return n == 1
}

// elevate re-runs this executable as administrator.  ShellExecute with the
// runas verb is the only way to raise a UAC prompt, and reaching it without
// a dependency means going through PowerShell's Start-Process, which is the
// same call underneath.
func elevate(args ...string) error {
	quote := func(s string) string { return "'" + strings.ReplaceAll(s, "'", "''") + "'" }
	ps := "Start-Process -FilePath " + quote(exePath())
	if len(args) > 0 {
		quoted := make([]string, len(args))
		for i, a := range args {
			quoted[i] = quote(a)
		}
		ps += " -ArgumentList " + strings.Join(quoted, ",")
	}
	ps += " -Verb RunAs"
	return run("powershell.exe", "-NoProfile", "-NonInteractive", "-Command", ps)
}

// removeLegacyInstall clears out an install made under the old
// moonlight-os-host-utils name.  Left alone it is a second agent on the same
// port at every boot: the new one fails to bind, and the only symptom is
// pairing that works once and then reports the wrong version forever.
func removeLegacyInstall() []string {
	const legacyTask = "MoonlightOSHostUtils"
	acts := []string{}
	if err := run("schtasks.exe", "/query", "/tn", legacyTask); err == nil {
		_ = run("schtasks.exe", "/end", "/tn", legacyTask)
		if err := run("schtasks.exe", "/delete", "/tn", legacyTask, "/f"); err == nil {
			acts = append(acts, "removed the old "+legacyTask+" scheduled task")
		}
	}
	dir := os.Getenv("ProgramFiles")
	if dir == "" {
		dir = filepath.Join(os.Getenv("SystemDrive")+`\`, "Program Files")
	}
	legacyDir := filepath.Join(dir, "moonlight-os-host-utils")
	if _, err := os.Stat(legacyDir); err == nil {
		if err := os.RemoveAll(legacyDir); err == nil {
			acts = append(acts, "removed "+legacyDir)
		}
	}
	// The config moved with the name; carrying it across keeps the pairing
	// code someone has already typed into Moonlight OS.
	if d := os.Getenv("ProgramData"); d != "" {
		acts = append(acts, adoptLegacyConfig(filepath.Join(d, "moonlight-os-host-utils"))...)
	}
	return acts
}

func rebootFlag() string { return filepath.Join(stateDir(), "needs-reboot") }

// needsReboot answers the question the user actually has -- "is it working
// yet?" -- rather than asking Windows about pending operations.  The MSI
// drops a flag; the first successful port query clears it.  A driver that
// answers is installed, whatever the registry thinks.
func needsReboot() bool {
	if _, err := os.Stat(rebootFlag()); err != nil {
		return false
	}
	if t, ok := findTool(); ok {
		if _, err := t.run("port"); err == nil {
			os.Remove(rebootFlag())
			return false
		}
	}
	return true
}

func ensureClient() (InstallResult, error) {
	res := InstallResult{Actions: []string{}}

	if t, ok := findTool(); ok {
		res.Installed = true
		res.ClientTool = ToolInfo{Present: true, Path: t.Path, Kind: t.Kind, Version: t.Version()}
		res.NeedsReboot = needsReboot()
		if res.NeedsReboot {
			res.Message = "usbip-win2 is installed but its driver is not live yet -- reboot the host PC"
		} else {
			res.Message = "USB/IP client ready"
		}
		return res, nil
	}

	if !isPrivileged() {
		res.Message = "usbip-win2 is not installed, and installing it needs Administrator"
		return res, fmt.Errorf("not elevated")
	}

	msi, name, err := downloadUSBIPWin2()
	if err != nil {
		res.Message = "could not fetch usbip-win2: " + err.Error()
		return res, nil
	}
	defer os.Remove(msi)
	res.Actions = append(res.Actions, "downloaded "+name)

	// /qn is silent, /norestart keeps it from rebooting a machine that is
	// very possibly mid-stream.  Installing restarts the USB 3.0 hubs, so
	// anything plugged in blinks out and back -- worth knowing before you
	// run this with a wheel attached.
	logf("installing %s (this restarts USB hubs)", name)
	if err := run("msiexec.exe", "/i", msi, "/qn", "/norestart"); err != nil {
		res.Message = "the usbip-win2 installer failed: " + err.Error()
		return res, nil
	}
	res.Actions = append(res.Actions, "installed usbip-win2")

	os.MkdirAll(stateDir(), 0o755)
	os.WriteFile(rebootFlag(), []byte(time.Now().Format(time.RFC3339)+"\n"), 0o644)

	// The driver is usually usable immediately, but the service and the
	// filter driver can take a moment to settle.
	var t Tool
	ok := false
	for i := 0; i < 10; i++ {
		if t, ok = findTool(); ok {
			break
		}
		time.Sleep(time.Second)
	}
	if !ok {
		res.Message = "usbip-win2 installed but usbip.exe was not found afterwards"
		return res, nil
	}

	res.Installed = true
	res.ClientTool = ToolInfo{Present: true, Path: t.Path, Kind: t.Kind, Version: t.Version()}
	res.NeedsReboot = needsReboot()
	if res.NeedsReboot {
		res.Message = "usbip-win2 installed -- reboot the host PC to load its driver"
	} else {
		res.Message = "usbip-win2 installed and ready"
	}
	return res, nil
}

type ghRelease struct {
	TagName string `json:"tag_name"`
	Assets  []struct {
		Name string `json:"name"`
		URL  string `json:"browser_download_url"`
	} `json:"assets"`
}

// downloadUSBIPWin2 takes the newest release rather than a pinned version.
// The driver is signed per release through the Open Source Codesigning
// Initiative, and pinning would eventually hand people a build that a
// Windows update has stopped accepting.
func downloadUSBIPWin2() (path, name string, err error) {
	req, _ := http.NewRequest("GET", "https://api.github.com/repos/vadimgrn/usbip-win2/releases/latest", nil)
	req.Header.Set("Accept", "application/vnd.github+json")
	req.Header.Set("User-Agent", "mlos-host-utils/"+Version)

	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		return "", "", fmt.Errorf("github returned %s", resp.Status)
	}

	var rel ghRelease
	if err := json.NewDecoder(resp.Body).Decode(&rel); err != nil {
		return "", "", err
	}

	want := "x64"
	if runtime.GOARCH == "arm64" {
		want = "arm64"
	}
	var url string
	for _, a := range rel.Assets {
		n := strings.ToLower(a.Name)
		if strings.HasSuffix(n, ".msi") && strings.Contains(n, want) {
			url, name = a.URL, a.Name
			break
		}
	}
	if url == "" { // single-architecture release
		for _, a := range rel.Assets {
			if strings.HasSuffix(strings.ToLower(a.Name), ".msi") {
				url, name = a.URL, a.Name
				break
			}
		}
	}
	if url == "" {
		return "", "", fmt.Errorf("release %s has no .msi for %s", rel.TagName, want)
	}

	dl, err := client.Get(url)
	if err != nil {
		return "", "", err
	}
	defer dl.Body.Close()
	if dl.StatusCode != 200 {
		return "", "", fmt.Errorf("downloading %s returned %s", name, dl.Status)
	}

	f, err := os.CreateTemp("", "usbip-win2-*.msi")
	if err != nil {
		return "", "", err
	}
	if _, err := io.Copy(f, dl.Body); err != nil {
		f.Close()
		os.Remove(f.Name())
		return "", "", err
	}
	f.Close()
	return f.Name(), name, nil
}

// installService uses a scheduled task rather than a Windows service.
//
// A real service means implementing the service control protocol, which off
// the standard library means golang.org/x/sys/windows/svc and a vendored
// dependency in an appliance build.  A task with /sc onstart /ru SYSTEM
// starts at boot, before login, with the privileges usbip needs -- which is
// the entire list of things the service would have bought.
// taskXML defines the scheduled task, because the command-line form of
// schtasks cannot express three settings whose defaults are all wrong for an
// agent that is supposed to sit there for months:
//
//   - ExecutionTimeLimit defaults to 72 hours.  A task created with
//     `schtasks /create /sc onstart` is killed after three days, and does not
//     come back until the next reboot.  PT0S means no limit.
//   - DisallowStartIfOnBatteries and StopIfGoingOnBatteries default to true.
//     On a laptop that means USB passthrough quietly does not exist
//     until the charger goes in, and stops mid-session when it comes out.
//   - There is no restart-on-failure at all, where the systemd side has
//     Restart=on-failure.
//
// StartWhenAvailable covers a boot the trigger was missed on.
const taskXML = `<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Moonlight OS host utils -- USB passthrough agent. Listens for a paired Moonlight OS client and attaches the USB devices plugged into it.</Description>
    <URI>\%s</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>5</Priority>
    <RestartOnFailure>
      <Interval>PT1M</Interval>
      <Count>10</Count>
    </RestartOnFailure>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>%s</Command>
      <Arguments>run --port %d</Arguments>
    </Exec>
  </Actions>
</Task>
`

// installService registers the agent as a scheduled task rather than a
// service.  A real service means implementing the service control protocol,
// which off the standard library means golang.org/x/sys/windows/svc and a
// vendored dependency in an appliance build.  A boot-triggered task running
// as SYSTEM starts before anyone logs in, keeps running while the session is
// locked, and survives a reboot -- which is the whole list of things the
// service would have bought.
func installService(exe string, port int) ([]string, error) {
	acts := []string{}
	_ = run("schtasks.exe", "/delete", "/tn", taskName, "/f")

	body := fmt.Sprintf(taskXML, taskName, xmlEscape(exe), port)

	// schtasks /xml wants UTF-16LE with a byte order mark; handed UTF-8 it
	// reports a parse error that names no line and explains nothing.
	path := filepath.Join(os.TempDir(), "mlos-host-utils-task.xml")
	if err := os.WriteFile(path, utf16LE(body), 0o600); err != nil {
		return acts, err
	}
	defer os.Remove(path)

	if err := run("schtasks.exe", "/create", "/tn", taskName, "/xml", path, "/f"); err != nil {
		return acts, fmt.Errorf("could not create the scheduled task: %w", err)
	}
	acts = append(acts,
		"created the "+taskName+" scheduled task",
		"runs as SYSTEM at boot, before login and while the session is locked",
		"no execution time limit, and it runs on battery")

	if err := run("schtasks.exe", "/run", "/tn", taskName); err == nil {
		acts = append(acts, "started the agent")
	}
	return acts, nil
}

func xmlEscape(s string) string {
	r := strings.NewReplacer("&", "&amp;", "<", "&lt;", ">", "&gt;", `"`, "&quot;", "'", "&apos;")
	return r.Replace(s)
}

func utf16LE(s string) []byte {
	out := []byte{0xFF, 0xFE} // BOM
	for _, r := range s {
		if r > 0xFFFF { // outside the BMP: surrogate pair
			r -= 0x10000
			hi := 0xD800 + (r >> 10)
			lo := 0xDC00 + (r & 0x3FF)
			out = append(out, byte(hi), byte(hi>>8), byte(lo), byte(lo>>8))
			continue
		}
		out = append(out, byte(r), byte(r>>8))
	}
	return out
}

func uninstallService() []string {
	acts := []string{}
	_ = run("schtasks.exe", "/end", "/tn", taskName)
	if err := run("schtasks.exe", "/delete", "/tn", taskName, "/f"); err == nil {
		acts = append(acts, "removed the scheduled task")
	}
	return acts
}

func openFirewall(port int) []string {
	_ = run("netsh.exe", "advfirewall", "firewall", "delete", "rule",
		"name=Moonlight OS host utils")
	err := run("netsh.exe", "advfirewall", "firewall", "add", "rule",
		"name=Moonlight OS host utils",
		"dir=in", "action=allow", "protocol=TCP",
		fmt.Sprintf("localport=%d", port),
		"profile=private,domain")
	if err != nil {
		return nil
	}
	return []string{fmt.Sprintf("allowed inbound TCP %d on private networks", port)}
}

func closeFirewall(port int) {
	_ = run("netsh.exe", "advfirewall", "firewall", "delete", "rule",
		"name=Moonlight OS host utils")
}

// setTestSigning is reachable from the command line only, never over the
// network.  It changes how the machine boots and weakens driver checking, so
// it is not something a device on the LAN gets to ask for -- even a trusted
// one.  Most people never need it: released usbip-win2 drivers are signed.
func setTestSigning(on bool) error {
	v := "off"
	if on {
		v = "on"
	}
	return run("bcdedit.exe", "/set", "testsigning", v)
}
