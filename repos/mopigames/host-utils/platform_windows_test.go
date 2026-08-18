//go:build windows

package main

import "testing"

// The machine PATH is a thing that, edited wrongly, breaks the whole PC and
// not just this program -- so the parsing and the membership test get pinned
// rather than trusted.
func TestParseRegPath(t *testing.T) {
	out := "\r\n" +
		`HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment` + "\r\n" +
		"    Path    REG_EXPAND_SZ    %SystemRoot%\\system32;C:\\Program Files\\Git\\cmd\r\n" +
		"    PATHEXT    REG_SZ    .COM;.EXE;.BAT\r\n"

	value, kind, err := parseRegPath(out)
	if err != nil {
		t.Fatal(err)
	}
	if kind != "REG_EXPAND_SZ" {
		// Rewriting an expandable PATH as REG_SZ turns %SystemRoot% into a
		// literal, and then nothing in system32 is on the PATH any more.
		t.Errorf("kind = %q, want REG_EXPAND_SZ", kind)
	}
	if want := `%SystemRoot%\system32;C:\Program Files\Git\cmd`; value != want {
		t.Errorf("value = %q, want %q", value, want)
	}
}

func TestParseRegPathNoValue(t *testing.T) {
	if _, _, err := parseRegPath("ERROR: The system was unable to find the specified registry key.\r\n"); err == nil {
		t.Error("want an error when there is no Path value, got none")
	}
}

func TestPathContains(t *testing.T) {
	const p = `%SystemRoot%\system32;C:\Program Files\mlos-host-utils\;C:\tools`
	cases := []struct {
		dir  string
		want bool
	}{
		{`C:\Program Files\mlos-host-utils`, true},  // trailing slash in the entry
		{`c:\program files\mlos-host-utils`, true},  // Windows paths are case-insensitive
		{`C:\Program Files\mlos-host-utils\`, true}, // both have one
		{`C:\tools`, true},
		{`C:\Program Files\mlos-host-util`, false}, // a prefix is not a match
		{`C:\Program Files`, false},
	}
	for _, c := range cases {
		if got := pathContains(p, c.dir); got != c.want {
			t.Errorf("pathContains(_, %q) = %v, want %v", c.dir, got, c.want)
		}
	}
}
