package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
)

func TestNormalizeFixtures(t *testing.T) {
	goBin, err := exec.LookPath("go")
	if err != nil {
		t.Fatal(err)
	}
	root := t.TempDir()
	tools := filepath.Join(root, "tools")
	if err := os.Mkdir(tools, 0o755); err != nil {
		t.Fatal(err)
	}
	sh, err := exec.LookPath("sh")
	if err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(sh, filepath.Join(tools, "sh")); err != nil {
		t.Fatal(err)
	}
	for name, output := range map[string]string{"cat": "basic-tool", "nix_fixture_tool": "path-tool"} {
		if err := os.WriteFile(filepath.Join(tools, name), []byte("#!"+sh+"\necho "+output+"\n"), 0o755); err != nil {
			t.Fatal(err)
		}
	}
	source := `package fixture
import (
 "os"
 "os/exec"
 "path/filepath"
 "strings"
 "testing"
)
func TestPaths(t *testing.T) {
 tools := os.Getenv("FIXTURE_TOOLS")
 fake := t.TempDir()
 os.WriteFile(filepath.Join(fake, "cat"), []byte("#!/bin/sh\necho fake-tool\n"), 0755)
 t.Setenv("PATH", fake)
 script := "#!/bin/sh\n/bin/cat ignored\n" + "cat ignored\n"
 path := filepath.Join(t.TempDir(), "script")
 os.WriteFile(path, []byte(script), 0755)
 out, err := exec.Command(path).CombinedOutput()
 if err != nil || string(out) != "basic-tool\nfake-tool\n" { t.Fatalf("script: %q %v", out, err) }
 // Path data and deliberately empty/isolated PATHs must retain their meaning.
 data := "/usr/bin/python3"
 if data != "/" + "usr/bin/python3" { t.Fatal(data) }
 t.Setenv("PATH", "")
 if _, err := exec.LookPath("cat"); err == nil { t.Fatal("empty PATH gained cat") }
 t.Setenv("PATH", fake)
 if _, err := exec.LookPath("nix_fixture_tool"); err == nil { t.Fatal("isolated PATH gained tools") }
 t.Setenv("PATH", fake + ":/usr/bin:/bin")
 if !strings.HasPrefix(os.Getenv("PATH"), fake + ":/usr/bin:/bin:") || !strings.HasSuffix(os.Getenv("PATH"), ":" + tools) { t.Fatal(os.Getenv("PATH")) }
 cmd := exec.Command(filepath.Join(tools, "sh"), "-c", "nix_fixture_tool")
 cmd.Env = []string{"PATH=" + fake + ":/usr/bin:/bin"}
 out, err = cmd.CombinedOutput()
 if err != nil || string(out) != "path-tool\n" { t.Fatalf("cmd.Env: %q %v", out, err) }
 cmd = &exec.Cmd{Path: filepath.Join(tools, "sh"), Args: []string{"sh", "-c", "nix_fixture_tool"}, Env: []string{"PATH=/usr/bin:/bin"}}
 out, err = cmd.CombinedOutput()
 if err != nil || string(out) != "path-tool\n" { t.Fatalf("Cmd literal: %q %v", out, err) }
 preserved := []string{"PATH=/bin"}
 if preserved[0] != "PATH=" + "/bin" { t.Fatal(preserved) }
}
`
	fixture := filepath.Join(root, "fixture_test.go")
	if err := os.WriteFile(fixture, []byte(source), 0o444); err != nil {
		t.Fatal(err)
	}
	// These invalid files must never be parsed or patched.
	for _, dir := range []string{"vendor", "node_modules"} {
		if err := os.Mkdir(filepath.Join(root, dir), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(filepath.Join(root, dir, "ignored_test.go"), []byte("not Go"), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	helper := os.Getenv("PATCH_TESTS_SOURCE")
	if helper == "" {
		_, file, _, _ := runtime.Caller(0)
		helper = filepath.Join(filepath.Dir(file), "patch-tests.go")
	}
	build := exec.Command(goBin, "build", "-o", filepath.Join(root, "patch-tests"), helper)
	if out, err := build.CombinedOutput(); err != nil {
		t.Fatalf("build helper: %v\n%s", err, out)
	}
	patch := exec.Command(filepath.Join(root, "patch-tests"), tools)
	patch.Dir = root
	if out, err := patch.CombinedOutput(); err != nil {
		t.Fatalf("patch: %v\n%s", err, out)
	}
	check := exec.Command(goBin, "test", fixture)
	check.Env = append(os.Environ(), "FIXTURE_TOOLS="+tools)
	if out, err := check.CombinedOutput(); err != nil {
		t.Fatalf("fixture: %v\n%s", err, strings.TrimSpace(string(out)))
	}
}
