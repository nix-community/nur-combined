package main

import (
	"crypto/rand"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
)

type Config struct {
	Token string `json:"token"`
	Port  int    `json:"port"`
}

// stateDir is configDir() unless overridden.  The override exists for tests
// and for the rare packaging that cannot write to the system location; it is
// read from the environment, so the service and the CLI have to agree on it
// or they will look at two different pairing codes.
func stateDir() string {
	if d := os.Getenv("MLOS_HOST_UTILS_DIR"); d != "" {
		return d
	}
	return configDir()
}

func configPath() string { return filepath.Join(stateDir(), "config.json") }

// loadConfig reads the config, creating it with a fresh token on first use.
//
// The token is the whole of the security model, so it is worth being clear
// about what it is for.  Anything that can reach this port can ask the agent
// to plug a USB device from *its own* machine into this one -- it cannot
// read devices off this machine, and it cannot run arbitrary commands.  The
// realistic threat is a housemate on the same Wi-Fi getting cute, not a
// remote attacker, and a 128-bit shared secret closes that without dragging
// TLS and a certificate story into an appliance.
func loadConfig() (*Config, error) {
	c := &Config{Port: DefaultPort}
	data, err := os.ReadFile(configPath())
	if err == nil {
		if err := json.Unmarshal(data, c); err != nil {
			return nil, err
		}
		if c.Token != "" {
			if c.Port == 0 {
				c.Port = DefaultPort
			}
			return c, nil
		}
	} else if !os.IsNotExist(err) {
		return nil, err
	}

	tok, err := newToken()
	if err != nil {
		return nil, err
	}
	c.Token = tok
	if err := saveConfig(c); err != nil {
		return nil, err
	}
	return c, nil
}

// Crockford's base32: no I, L, O or U, so nothing in a printed code can be
// misread as a 1, a 0, or the start of a word nobody wants on screen.
const tokenAlphabet = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

// newToken returns 16 characters, 80 bits.
//
// Not 128, because this gets typed by hand from a television, on a couch,
// possibly with a controller.  80 bits is far past what an online guesser
// can reach against a service that pauses a second on every wrong answer,
// and the difference between 16 characters and 26 is the difference between
// people using the feature and people giving up on it.
func newToken() (string, error) {
	buf := make([]byte, 16)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	out := make([]byte, len(buf))
	for i, b := range buf {
		out[i] = tokenAlphabet[int(b)%len(tokenAlphabet)]
	}
	return string(out), nil
}

// NormaliseToken makes what someone typed comparable to what was stored.
// People type the dashes the code is printed with, and lowercase, and both
// are fine.
func NormaliseToken(s string) string {
	var b strings.Builder
	for _, r := range strings.ToUpper(s) {
		if strings.ContainsRune(tokenAlphabet, r) {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// FormatToken groups the code for display: XXXX-XXXX-XXXX-XXXX.
func FormatToken(s string) string {
	var parts []string
	for i := 0; i < len(s); i += 4 {
		end := i + 4
		if end > len(s) {
			end = len(s)
		}
		parts = append(parts, s[i:end])
	}
	return strings.Join(parts, "-")
}

// adoptLegacyConfig moves a config left behind by an install under the old
// name, so that renaming the program does not silently issue a new pairing
// code and invalidate the one already typed into Moonlight OS.
func adoptLegacyConfig(legacyDir string) []string {
	old := filepath.Join(legacyDir, "config.json")
	data, err := os.ReadFile(old)
	if err != nil {
		return nil
	}
	if _, err := os.Stat(configPath()); err == nil {
		return nil // this install already has one; leave both alone
	}
	if err := os.MkdirAll(stateDir(), 0o755); err != nil {
		return nil
	}
	if err := os.WriteFile(configPath(), data, 0o600); err != nil {
		return nil
	}
	os.RemoveAll(legacyDir)
	return []string{"kept the pairing code from " + old}
}

func saveConfig(c *Config) error {
	if err := os.MkdirAll(stateDir(), 0o755); err != nil {
		return err
	}
	data, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return err
	}
	// 0600: the token is the credential.  On Windows the ProgramData ACL
	// already limits writes to administrators, and the mode is advisory
	// there, which is why the directory is created restricted too.
	return os.WriteFile(configPath(), append(data, '\n'), 0o600)
}
