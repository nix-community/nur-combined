// This command adapts upstream Magpie sources for the Nix package in two phases.
// Runtime patches run before compilation; check patches run afterwards and affect only tests.
// Complete helper sources live in template files; inline fragments reuse upstream names,
// import aliases or Nix paths and therefore remain next to their AST adaptations.
//
// Runtime patches (GUI builds only):
//   - Linux: replace scheme registration with cleanup of legacy Nix wrapper entries.
//   - Linux: use the public autostart launcher while preserving AppImage handling.
//   - Linux: refresh existing Nix autostart paths, preserving disabled and custom entries.
//   - Darwin: set the packaged Bun path in the native application entry point.
//
// Check patches:
//   - Use Nix interpreters and tools in fixture scripts and explicit system PATHs.
//   - Settle plugin work before removing temporary directories in plugin-using test packages.
//   - Advance parent-directory timestamps after fixture writes and Zed fixture symlinks.
//   - Calibrate successful davsync fixture saves against the wall clock, preserving explicit mtimes.
//   - Wait before Codex cache rewrites that restore mtime, excluding mocked-clock tests.
//   - Make gateway route writes synchronous during tests.
//   - Enable upstream offline setup before testenv.Main.
//   - Exclude vendor dependencies from source-policy tests.
//   - Linux: give private D-Bus test sessions the packaged session configuration.
//   - Linux GUI: replace upstream scheme expectations with tests of the Nix policies.
//   - Darwin GUI: skip native window tests requiring a graphical session.
//   - Darwin: read the autostart bundle identifier with Python instead of xcbuild's plutil.
//   - Darwin: skip unavailable AppleScript execution after checking script generation.
package main

import (
	"bytes"
	"flag"
	"fmt"
	"go/ast"
	"go/build"
	"go/format"
	"go/parser"
	"go/token"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

type options struct {
	phase, platform, arch, tools, launcher, bun, dbus, templates string
	gui                                                          bool
}

type edit struct {
	start, end int
	text       string
}

type sourceFile struct {
	path     string
	source   []byte
	original []byte
	fset     *token.FileSet
	file     *ast.File
	edits    []edit
}

// text preserves the original spelling of upstream expressions reused in generated code.
func (f *sourceFile) text(n ast.Node) string {
	return string(f.source[f.fset.Position(n.Pos()).Offset:f.fset.Position(n.End()).Offset])
}

// replace queues a changed node's replacement without invalidating the parsed source offsets.
func (f *sourceFile) replace(n ast.Node, text string) {
	if f.text(n) != text {
		f.edits = append(f.edits, edit{f.fset.Position(n.Pos()).Offset, f.fset.Position(n.End()).Offset, text})
	}
}

// insert queues new code at a token position for the same deferred edit pass as replace.
func (f *sourceFile) insert(pos token.Pos, text string) {
	offset := f.fset.Position(pos).Offset
	f.edits = append(f.edits, edit{offset, offset, text})
}

// importName resolves imports by path so patch matching tolerates upstream import aliases.
func (f *sourceFile) importName(path string) string {
	for _, spec := range f.file.Imports {
		if firstString(spec.Path) == path {
			if spec.Name != nil {
				return spec.Name.Name
			}
			return filepath.Base(path)
		}
	}
	return ""
}

// qualify builds a reference using the upstream import alias, adding a missing import once.
func (f *sourceFile) qualify(path, name string) string {
	alias := f.importName(path)
	if alias == "" {
		alias = filepath.Base(path)
		f.insert(f.file.Name.End(), "\nimport "+strconv.Quote(path)+"\n")
		// Record it too so later edits reuse the same import.
		f.file.Imports = append(f.file.Imports, &ast.ImportSpec{Path: &ast.BasicLit{Kind: token.STRING, Value: strconv.Quote(path)}})
	}
	if alias == "." {
		return name
	}
	return alias + "." + name
}

// call matches a function through its import path, including aliases and dot imports.
// An empty path matches a bare function name such as saveRoute or codexFiles.
func (f *sourceFile) call(call *ast.CallExpr, path, name string) bool {
	if path == "" {
		ident, ok := call.Fun.(*ast.Ident)
		return ok && ident.Name == name
	}
	alias := f.importName(path)
	if selector, ok := call.Fun.(*ast.SelectorExpr); ok {
		receiver, ok := selector.X.(*ast.Ident)
		return ok && alias != "" && receiver.Name == alias && selector.Sel.Name == name
	}
	ident, ok := call.Fun.(*ast.Ident)
	return ok && alias == "." && ident.Name == name
}

// hasCall finds matching calls, including guards for adaptations already present in a function.
func (f *sourceFile) hasCall(node ast.Node, path, name string) bool {
	found := false
	ast.Inspect(node, func(n ast.Node) bool {
		if call, ok := n.(*ast.CallExpr); ok && f.call(call, path, name) {
			found = true
		}
		return true
	})
	return found
}

// commandName identifies exec.Command tools from literals or a local exec.LookPath result.
// This keeps D-Bus, plutil and osascript patches independent of the executable variable's name.
func (f *sourceFile) commandName(call *ast.CallExpr) string {
	if !f.call(call, "os/exec", "Command") || len(call.Args) == 0 {
		return ""
	}
	if literal := firstString(call.Args[0]); literal != "" {
		return literal
	}
	if ident, ok := call.Args[0].(*ast.Ident); ok && ident.Obj != nil {
		if assignment, ok := ident.Obj.Decl.(*ast.AssignStmt); ok && len(assignment.Rhs) == 1 {
			if lookup, ok := assignment.Rhs[0].(*ast.CallExpr); ok && f.call(lookup, "os/exec", "LookPath") && len(lookup.Args) == 1 {
				return firstString(lookup.Args[0])
			}
		}
	}
	return ""
}

// testingParams identifies testing.T/TB parameters by their bound objects rather than
// assuming a name like t, so cleanup and skip patches can follow renamed parameters.
func (f *sourceFile) testingParams() map[*ast.Object]string {
	params := map[*ast.Object]string{}
	alias := f.importName("testing")
	ast.Inspect(f.file, func(n ast.Node) bool {
		field, ok := n.(*ast.Field)
		if !ok {
			return true
		}
		typ := field.Type
		if star, ok := typ.(*ast.StarExpr); ok {
			typ = star.X
		}
		selector, ok := typ.(*ast.SelectorExpr)
		if !ok || selector.Sel.Name != "T" && selector.Sel.Name != "TB" {
			return true
		}
		if receiver, ok := selector.X.(*ast.Ident); ok && receiver.Name == alias {
			for _, name := range field.Names {
				if name.Obj != nil {
					params[name.Obj] = name.Name
				}
			}
		}
		return true
	})
	return params
}

// applyEdits works backwards to preserve earlier offsets and rejects overlapping rewrites.
func applyEdits(source []byte, edits []edit) ([]byte, error) {
	sort.SliceStable(edits, func(i, j int) bool { return edits[i].start > edits[j].start })
	limit := len(source)
	for _, edit := range edits {
		if edit.end > limit {
			return nil, fmt.Errorf("overlapping source edits at offset %d", edit.start)
		}
		source = append(append(append([]byte{}, source[:edit.start]...), edit.text...), source[edit.end:]...)
		limit = edit.start
	}
	return source, nil
}

var systemDir = regexp.MustCompile(`(^|:)/(usr/)?bin(:|$)`)
var absoluteTool = regexp.MustCompile(`(^|[^\w/.-])/(usr/)?bin/([\w.-]+)\b`)

// firstString reads the leading literal of a concatenation without evaluating dynamic parts.
func firstString(expr ast.Expr) string {
	if binary, ok := expr.(*ast.BinaryExpr); ok && binary.Op == token.ADD {
		return firstString(binary.X)
	}
	if literal, ok := expr.(*ast.BasicLit); ok && literal.Kind == token.STRING {
		value, _ := strconv.Unquote(literal.Value)
		return value
	}
	return ""
}

// needsTools limits PATH expansion to /bin or /usr/bin paths missing the fixture tools.
// Preserve deliberately empty or isolated search paths and avoid duplicating tools on reruns.
func needsTools(expr ast.Expr, tools string) bool {
	system, present := false, false
	ast.Inspect(expr, func(n ast.Node) bool {
		if literal, ok := n.(*ast.BasicLit); ok && literal.Kind == token.STRING {
			value := strings.TrimPrefix(firstString(literal), "PATH=")
			system = system || systemDir.MatchString(value)
			for _, part := range strings.Split(value, ":") {
				present = present || part == tools
			}
		}
		return true
	})
	return system && !present
}

// fixtures adapts script interpreters, executable paths and system PATHs to Nix tools,
// and redirects selected packages' temporary directories through plugin cleanup.
// Token-offset edits preserve unrelated expressions and build tags.
func (f *sourceFile) fixtures(tools string, cleanup bool) {
	params := f.testingParams()
	scripts := map[*ast.BasicLit]bool{}
	// Nix sandboxes have no tool set in /bin or /usr/bin. Extend explicit system PATHs
	// with store tools while preserving empty or isolated PATHs used to test discovery.
	patchEnv := func(expr ast.Expr) {
		if values, ok := expr.(*ast.CompositeLit); ok {
			for _, value := range values.Elts {
				if strings.HasPrefix(firstString(value), "PATH=") && needsTools(value, tools) {
					f.insert(value.End(), " + "+strconv.Quote(":"+tools))
				}
			}
		}
	}
	ast.Inspect(f.file, func(node ast.Node) bool {
		switch node := node.(type) {
		case *ast.CallExpr:
			// Background plugin writes can race TempDir removal and recreate directories;
			// settle that work before testing removes its temporary directories.
			if selector, ok := node.Fun.(*ast.SelectorExpr); ok && selector.Sel.Name == "TempDir" && len(node.Args) == 0 && cleanup {
				if receiver, ok := selector.X.(*ast.Ident); ok && params[receiver.Obj] != "" {
					f.replace(node, "nixTempDir("+receiver.Name+")")
				}
			}
			// Setenv needs the same system-PATH adaptation as command environment slices.
			if selector, ok := node.Fun.(*ast.SelectorExpr); ok && selector.Sel.Name == "Setenv" && len(node.Args) == 2 && firstString(node.Args[0]) == "PATH" && needsTools(node.Args[1], tools) {
				f.insert(node.Args[1].End(), " + "+strconv.Quote(":"+tools))
			}
		case *ast.AssignStmt:
			// Environment slices can bypass os.Setenv, e.g. a WSL probe's cmd.Env.
			for i, lhs := range node.Lhs {
				if selector, ok := lhs.(*ast.SelectorExpr); ok && selector.Sel.Name == "Env" && i < len(node.Rhs) {
					patchEnv(node.Rhs[i])
				}
			}
		case *ast.KeyValueExpr:
			if key, ok := node.Key.(*ast.Ident); ok && key.Name == "Env" {
				patchEnv(node.Value)
			}
		}
		if expr, ok := node.(ast.Expr); ok && strings.HasPrefix(firstString(expr), "#!") {
			// Include fragments of concatenated scripts, but not path test data.
			ast.Inspect(expr, func(child ast.Node) bool {
				if literal, ok := child.(*ast.BasicLit); ok && literal.Kind == token.STRING {
					scripts[literal] = true
				}
				return true
			})
		}
		return true
	})
	for literal := range scripts {
		value, _ := strconv.Unquote(literal.Value)
		// Nix provides interpreters and commands under /nix/store rather than /bin or
		// /usr/bin. Rewrite executable script paths, leaving unrelated path data intact.
		patched := absoluteTool.ReplaceAllStringFunc(value, func(match string) string {
			parts := absoluteTool.FindStringSubmatch(match)
			tool := filepath.Join(tools, parts[3])
			if info, err := os.Stat(tool); err == nil && info.Mode()&0o111 != 0 {
				return parts[1] + tool
			}
			return match
		})
		if strings.HasPrefix(patched, "#!") {
			header, body, ok := strings.Cut(patched, "\n")
			interpreter := strings.Fields(strings.TrimPrefix(header, "#!"))
			if ok && len(interpreter) > 0 {
				name := filepath.Base(interpreter[0])
				if name == "sh" || name == "bash" || name == "zsh" {
					// Tests can give scripts an isolated PATH that hides basic utilities.
					// Append only fixture tools so fake commands still win and real agents stay hidden.
					prefix := "export PATH=\"${PATH:+$PATH:}" + tools + "\"\n"
					if !strings.HasPrefix(body, prefix) {
						patched = header + "\n" + prefix + body
					}
				} else if len(interpreter) == 2 && name == "env" && interpreter[1] == "python3" {
					// Pin Python even when the test launches the script with an isolated PATH.
					patched = "#!" + filepath.Join(tools, "python3") + "\n" + body
				}
			}
		}
		if patched != value {
			f.replace(literal, strconv.Quote(patched))
		}
	}
}

// The packaged desktop file owns Linux scheme registration. A user entry targeting
// .magpie-wrapped overrides it and bypasses the GTK/Bun environment set by the public launcher.
// Remove only those legacy Nix entries; preserve custom and Flatpak entries.
const schemeBody = `{
 if os.Getenv("FLATPAK_ID") != "" { return nil }
 data := appdir.Getenv("XDG_DATA_HOME")
 if data == "" { home, _ := os.UserHomeDir(); data = filepath.Join(home, ".local", "share") }
 path := filepath.Join(data, "applications", "magpie.desktop")
 old, err := os.ReadFile(path)
 if os.IsNotExist(err) { return nil }
 if err != nil { return err }
 if strings.Contains(string(old), "MimeType=x-scheme-handler/magpie;") {
  for _, line := range strings.Split(string(old), "\n") {
   if strings.HasPrefix(line, "Exec=/nix/store/") && strings.HasSuffix(line, "/bin/.magpie-wrapped %u") { return os.Remove(path) }
  }
 }
 return nil
}`

// Existing autostart entries can retain an obsolete store path after a package upgrade.
// Upgrade Nix launchers without enabling missing or disabled entries.
// Keep custom commands, extra arguments and all fields other than the matching Exec line.
const refreshBody = `{
 body, err := os.ReadFile(record())
 if os.IsNotExist(err) { return nil }
 if err != nil { return err }
 lines := strings.Split(string(body), "\n")
 for _, line := range lines {
  key, value, ok := strings.Cut(line, "=")
  if !ok { continue }
  key, value = strings.TrimSpace(key), strings.TrimSpace(value)
  if key == "Hidden" && value == "true" || key == "X-GNOME-Autostart-enabled" && value == "false" { return nil }
 }
 for i, line := range lines {
  key, value, ok := strings.Cut(line, "=")
  if !ok || strings.TrimSpace(key) != "Exec" { continue }
  value = strings.TrimSpace(value)
  if !strings.HasSuffix(value, " " + Arg) { return nil }
  exe := strings.Trim(strings.TrimSuffix(value, " " + Arg), "\"")
  if !strings.HasPrefix(exe, "/nix/store/") || !strings.HasSuffix(exe, "/bin/.magpie-wrapped") && !strings.HasSuffix(exe, "/bin/magpie") { return nil }
  replacement := "Exec=" + @launcher@ + " " + Arg
  if line == replacement { return nil }
  lines[i] = replacement
  return os.WriteFile(record(), []byte(strings.Join(lines, "\n")), 0o644)
 }
 return nil
}`

// policyBody replaces Linux scheme registration or autostart refresh with Nix-owned policy,
// adapting imports to upstream aliases and checking the replacement's syntax first.
func (f *sourceFile) policyBody(fn *ast.FuncDecl, body string) error {
	// These two implementations are owned by Nix; other runtime edits retain upstream logic.
	for _, path := range []string{"os", "path/filepath", "strings", "github.com/yetone/magpie/internal/appdir"} {
		prefix := filepath.Base(path) + "."
		if strings.Contains(body, prefix) {
			body = strings.ReplaceAll(body, prefix, f.qualify(path, ""))
		}
	}
	parsed, err := parser.ParseFile(token.NewFileSet(), "policy.go", "package p\nfunc f() "+body, 0)
	if err != nil {
		return err
	}
	var buf bytes.Buffer
	if err := format.Node(&buf, token.NewFileSet(), parsed.Decls[0].(*ast.FuncDecl).Body); err != nil {
		return err
	}
	f.replace(fn.Body, buf.String())
	return nil
}

// patchRuntime applies Linux scheme/autostart policies and sets Bun's path in Darwin GUI builds.
// These edits enter the installed binary; only active platform and build-tag sources are patched.
func patchRuntime(files []*sourceFile, o options) error {
	if !o.gui {
		return nil
	}
	found := map[string]bool{}
	context := build.Default
	context.GOOS, context.CgoEnabled = o.platform, o.gui
	if o.arch != "" {
		context.GOARCH = o.arch
	}
	context.BuildTags = []string{"production"}
	if o.platform == "linux" {
		context.BuildTags = append(context.BuildTags, "gtk3")
	}
	for _, f := range files {
		if strings.HasSuffix(f.path, "_test.go") {
			continue
		}
		active, err := context.MatchFile(filepath.Dir(f.path), filepath.Base(f.path))
		if err != nil {
			return err
		}
		if !active {
			continue
		}
		dir := filepath.ToSlash(filepath.Dir(f.path))
		for _, decl := range f.file.Decls {
			fn, ok := decl.(*ast.FuncDecl)
			if !ok || fn.Body == nil {
				continue
			}
			// Finder launches the native macOS bundle without a shell wrapper to set Bun's path.
			// Set it here because wrapping the bundle executable disrupts Launch Services tracking.
			if o.platform == "darwin" && dir == "." && f.file.Name.Name == "main" && fn.Name.Name == "main" {
				found["main"] = true
				set := false
				ast.Inspect(fn.Body, func(n ast.Node) bool {
					if call, ok := n.(*ast.CallExpr); ok && f.call(call, "os", "Setenv") && len(call.Args) == 2 && firstString(call.Args[0]) == "MAGPIE_BUN" {
						f.replace(call.Args[1], strconv.Quote(o.bun))
						set = true
					}
					return true
				})
				if !set {
					f.insert(fn.Body.Lbrace+1, "\n"+f.qualify("os", "Setenv")+"(\"MAGPIE_BUN\", "+strconv.Quote(o.bun)+");\n")
				}
			}
			if o.platform != "linux" {
				continue
			}
			switch {
			case dir == "internal/gui" && fn.Name.Name == "registerScheme":
				found["registerScheme"] = true
				if err := f.policyBody(fn, schemeBody); err != nil {
					return err
				}
			case dir == "internal/autostart" && fn.Name.Name == "refresh":
				found["refresh"] = true
				body := strings.ReplaceAll(refreshBody, "@launcher@", strconv.Quote(strconv.Quote(o.launcher)))
				if err := f.policyBody(fn, body); err != nil {
					return err
				}
			case dir == "internal/autostart" && fn.Name.Name == "self":
				// os.Executable can expose .magpie-wrapped, bypassing the environment needed
				// by GTK and Bun on autostart. Use the public launcher while retaining AppImage handling.
				found["self"] = true
				adapted := strings.Contains(f.text(fn.Body), strconv.Quote(o.launcher))
				ast.Inspect(fn.Body, func(n ast.Node) bool {
					if call, ok := n.(*ast.CallExpr); ok && f.call(call, "os", "Executable") {
						f.replace(call, "func() (string, error) { return "+strconv.Quote(o.launcher)+", nil }()")
						adapted = true
					}
					return true
				})
				if !adapted {
					return fmt.Errorf("%s: cannot identify autostart executable source in self", f.path)
				}
			}
		}
	}
	wanted := []string{"main"}
	if o.platform == "linux" {
		wanted = []string{"registerScheme", "self", "refresh"}
	}
	for _, name := range wanted {
		if !found[name] {
			return fmt.Errorf("cannot locate %s runtime responsibility; inspect upstream entry points", name)
		}
	}
	return nil
}

// beforeCalls inserts offline setup, cache-clock waits or conditional skips immediately
// before the statement containing a matched call, including calls in if initializers.
// It handles nested blocks separately and recognizes existing preceding insertions.
func (f *sourceFile) beforeCalls(body *ast.BlockStmt, match func(*ast.CallExpr) bool, code func(*ast.BlockStmt) string) {
	ast.Inspect(body, func(n ast.Node) bool {
		block, ok := n.(*ast.BlockStmt)
		if !ok {
			return true
		}
		for i, stmt := range block.List {
			found := false
			ast.Inspect(stmt, func(child ast.Node) bool {
				switch child.(type) {
				case *ast.BlockStmt, *ast.FuncLit:
					return false
				}
				if call, ok := child.(*ast.CallExpr); ok && match(call) {
					found = true
				}
				return true
			})
			if !found {
				continue
			}
			text := code(block)
			if text == "" {
				continue
			}
			if i > 0 {
				prior := f.text(block.List[i-1])
				// Compare formatted syntax for insertions already normalized by gofmt.
				if strings.Contains(prior, strings.TrimSpace(text)) ||
					strings.Join(strings.Fields(prior), "") == strings.Join(strings.Fields(text), "") {
					continue
				}
			}
			f.insert(stmt.Pos(), text+"\n")
		}
		return true
	})
}

// testReceiver finds the testing parameter referenced in a node for generated Skip calls.
func (f *sourceFile) testReceiver(node ast.Node) string {
	params := f.testingParams()
	name := ""
	ast.Inspect(node, func(n ast.Node) bool {
		if name != "" {
			return false
		}
		if ident, ok := n.(*ast.Ident); ok && params[ident.Obj] != "" {
			name = ident.Name
		}
		return true
	})
	return name
}

// cleanupPackage restricts plugin-settling TempDir replacements to the internal
// agent, cli, gateway, gui and provider packages, excluding external test packages.
func cleanupPackage(f *sourceFile) bool {
	switch name := f.file.Name.Name; name {
	case "agent", "cli", "gateway", "gui", "provider":
		return filepath.ToSlash(filepath.Dir(f.path)) == "internal/"+name
	default:
		return false
	}
}

// fixtureWrites recognizes writes through string parameters in testing helpers, including
// simple local aliases and joined paths. Helpers that control mtimes retain that control.
// Discovery caches use directory mtimes: same-tick installs and same-name overwrites can
// otherwise leave a cached miss or stale fixture even though the write succeeded.
func (f *sourceFile) fixtureWrites(fn *ast.FuncDecl) {
	if f.testReceiver(fn.Type.Params) == "" || f.hasCall(fn.Body, "os", "Chtimes") {
		return
	}
	params := map[*ast.Object]bool{}
	for _, field := range fn.Type.Params.List {
		if typ, ok := field.Type.(*ast.Ident); ok && typ.Name == "string" {
			for _, name := range field.Names {
				params[name.Obj] = true
			}
		}
	}
	var parameterPath func(ast.Expr) bool
	parameterPath = func(expr ast.Expr) bool {
		if ident, ok := expr.(*ast.Ident); ok && ident.Obj != nil {
			if params[ident.Obj] {
				return true
			}
			if assign, ok := ident.Obj.Decl.(*ast.AssignStmt); ok && len(assign.Lhs) == len(assign.Rhs) {
				for i, lhs := range assign.Lhs {
					if name, ok := lhs.(*ast.Ident); ok && name.Obj == ident.Obj {
						return parameterPath(assign.Rhs[i])
					}
				}
			}
		}
		if call, ok := expr.(*ast.CallExpr); ok && f.call(call, "path/filepath", "Join") && len(call.Args) > 0 {
			return parameterPath(call.Args[0])
		}
		return false
	}
	ast.Inspect(fn.Body, func(n ast.Node) bool {
		if call, ok := n.(*ast.CallExpr); ok && f.call(call, "os", "WriteFile") && len(call.Args) == 3 && parameterPath(call.Args[0]) {
			f.replace(call.Fun, f.qualify("github.com/yetone/magpie/internal/testenv", "NixWriteFile"))
		}
		return true
	})
}

// patchChecks adapts fixture tools/PATHs, plugin cleanup, discovery timestamps, Codex cache
// timing, sync fixture file clocks, route writes, offline setup and vendor exclusions. Platform rules cover Linux
// D-Bus/scheme tests and Darwin window/plist/AppleScript tests.
// Nix runs this after the application build, so non-test source edits also affect only tests.
func patchChecks(files []*sourceFile, o options) error {
	for _, f := range files {
		dir := filepath.ToSlash(filepath.Dir(f.path))
		test := strings.HasSuffix(f.path, "_test.go")
		for _, decl := range f.file.Decls {
			fn, ok := decl.(*ast.FuncDecl)
			if !ok || fn.Body == nil {
				continue
			}
			program := !test && dir == "internal/testenv" && fn.Name.Name == "WriteProgram"
			// Wrap the whole installer, including Darwin's warmed executable rewrite.
			// Snapshot the parent clock before writing so a same-tick install invalidates discovery.
			if program && !f.hasCall(fn.Body, "", "NixWriteFixture") {
				if len(fn.Type.Params.List) == 0 || len(fn.Type.Params.List[0].Names) == 0 || fn.Type.Results == nil || len(fn.Type.Results.List) != 1 || f.text(fn.Type.Results.List[0].Type) != "error" {
					return fmt.Errorf("%s: cannot wrap WriteProgram's path and error result", f.path)
				}
				f.replace(fn.Body, "{ return NixWriteFixture("+fn.Type.Params.List[0].Names[0].Name+", func() "+f.text(fn.Type.Results)+" "+f.text(fn.Body)+") }")
			}
			// Follow fixture behavior rather than helper names added or renamed upstream.
			if test && (dir == "internal/agent" || dir == "internal/library") {
				f.fixtureWrites(fn)
			}
			// Kernel mtimes can lag backup.Created's wall clock, making a newer test edit
			// lose a sync conflict. Calibrate explicit saves only; later Chtimes still wins.
			// Production Save and sync's internal restores keep their original time semantics.
			if test && dir == "internal/davsync" {
				name := f.testReceiver(fn.Type.Params)
				ast.Inspect(fn.Body, func(n ast.Node) bool {
					call, ok := n.(*ast.CallExpr)
					if !ok {
						return true
					}
					if f.call(call, "github.com/yetone/magpie/internal/testenv", "NixSave") {
						return false
					}
					for _, pkg := range []string{"settings", "provider"} {
						path := "github.com/yetone/magpie/internal/" + pkg
						if name != "" && f.call(call, path, "Save") {
							f.replace(call, f.qualify("github.com/yetone/magpie/internal/testenv", "NixSave")+"("+name+", "+f.qualify(path, "Path")+"(), func() error { return "+f.text(call)+" })")
							return false
						}
					}
					return true
				})
			}
			if !test {
				if dir == "internal/gateway" {
					// Asynchronous route writes can outlive request tests and recreate storage
					// during teardown. Finish them before tests remove their directories.
					// The installed application keeps its original asynchronous writes.
					ast.Inspect(fn.Body, func(n ast.Node) bool {
						if goStmt, ok := n.(*ast.GoStmt); ok && f.call(goStmt.Call, "", "saveRoute") {
							f.replace(goStmt, f.text(goStmt.Call))
						}
						return true
					})
				}
				continue
			}
			// Nix checks have no external network access. Upstream's offline setup makes
			// network-dependent tests use their intended offline behavior instead of timing out.
			if fn.Name.Name == "TestMain" && !f.hasCall(fn.Body, "github.com/yetone/magpie/internal/testenv", "Offline") {
				f.beforeCalls(fn.Body, func(call *ast.CallExpr) bool {
					return f.call(call, "github.com/yetone/magpie/internal/testenv", "Main")
				}, func(_ *ast.BlockStmt) string {
					return f.qualify("github.com/yetone/magpie/internal/testenv", "Offline") + "()"
				})
			}
			// Nix build users have no graphical macOS session; skip the shared window
			// entry points while allowing ordinary GUI logic tests to run.
			if dir == "internal/gui" && o.gui && o.platform == "darwin" && (fn.Name.Name == "runAppKit" || fn.Name.Name == "runAppKitSDK") && !strings.Contains(f.text(fn.Body), "Native AppKit/WebKit windows require") {
				name := f.testReceiver(fn.Type.Params)
				if name == "" {
					return fmt.Errorf("%s: %s no longer exposes a testing parameter", f.path, fn.Name.Name)
				}
				f.insert(fn.Body.Lbrace+1, "\n"+name+".Skip(\"Native AppKit/WebKit windows require a graphical session unavailable to Nix build users\");\n")
			}
			// Upstream expects runtime desktop-file creation; Nix installs that file with
			// the package and only cleans legacy entries, so those assertions no longer apply.
			// Keep Flatpak coverage and use the injected Nix tests for other registrations.
			if dir == "internal/gui" && o.gui && o.platform == "linux" && strings.HasPrefix(fn.Name.Name, "Test") && strings.Contains(f.text(fn.Body), "x-scheme-handler/magpie") {
				f.beforeCalls(fn.Body, func(call *ast.CallExpr) bool {
					name, ok := call.Fun.(*ast.Ident)
					return ok && name.Name == "registerScheme"
				}, func(block *ast.BlockStmt) string {
					name := f.testReceiver(block)
					if name == "" {
						return ""
					}
					return "if " + f.qualify("os", "Getenv") + "(\"FLATPAK_ID\") == \"\" { " + name + ".Skip(\"Nix registration is covered by TestNixSchemeCleanup\") }"
				})
			}
			// Zed discovery caches its search directories; fixture symlink creation
			// must advance the directory timestamp even within one filesystem tick.
			if dir == "internal/agent" && f.hasCall(fn.Body, "", "zedAppPath") && !f.hasCall(fn.Body, "github.com/yetone/magpie/internal/testenv", "NixTouchDir") {
				ast.Inspect(fn.Body, func(n ast.Node) bool {
					if call, ok := n.(*ast.CallExpr); ok && f.call(call, "os", "Symlink") && len(call.Args) == 2 {
						f.replace(call, "func() error { nixTarget := "+f.text(call.Args[1])+"; if err := "+f.qualify("os", "Symlink")+"("+f.text(call.Args[0])+", nixTarget); err != nil { return err }; return "+f.qualify("github.com/yetone/magpie/internal/testenv", "NixTouchDir")+"("+f.qualify("path/filepath", "Dir")+"(nixTarget)) }()")
					}
					return true
				})
			}
			// Same-size rewrites with restored mtime rely on ctime to invalidate the cache.
			// Kernel ctime can stay unchanged within a tick, so wait before real-clock rewrites
			// while preserving the same-size and restored-mtime assertions.
			if dir == "internal/sessions" && f.hasCall(fn.Body, "", "codexFiles") && f.hasCall(fn.Body, "os", "Chtimes") {
				// A mocked stat clock deliberately tests same-tick rewrites and must not gain a wait.
				mocked := false
				var primed token.Pos
				paths := map[string]bool{}
				ast.Inspect(fn.Body, func(n ast.Node) bool {
					if assignment, ok := n.(*ast.AssignStmt); ok {
						for _, lhs := range assignment.Lhs {
							if name, ok := lhs.(*ast.Ident); ok && name.Name == "codexDiscoveryStat" {
								mocked = true
							}
						}
					}
					if call, ok := n.(*ast.CallExpr); ok && f.call(call, "os", "Chtimes") && len(call.Args) == 3 {
						paths[f.text(call.Args[0])] = true
					}
					if call, ok := n.(*ast.CallExpr); ok && f.call(call, "", "codexFiles") && !primed.IsValid() {
						primed = call.Pos()
					}
					return true
				})
				if !mocked {
					f.beforeCalls(fn.Body, func(call *ast.CallExpr) bool {
						return f.call(call, "", "writeLines") && len(call.Args) >= 2 && paths[f.text(call.Args[1])] && call.Pos() > primed
					}, func(_ *ast.BlockStmt) string {
						return f.qualify("time", "Sleep") + "(20 * " + f.qualify("time", "Millisecond") + ")"
					})
				}
			}
			// buildGoModule adds vendor sources that are absent from the upstream checkout.
			// Magpie's source-policy rules apply to its own code, not those dependencies.
			if (dir == "internal/proc" || dir == "internal/sqlitedb") && f.hasCall(fn.Body, "path/filepath", "WalkDir") && !strings.Contains(f.text(fn.Body), `"vendor"`) {
				ast.Inspect(fn.Body, func(n ast.Node) bool {
					if binary, ok := n.(*ast.BinaryExpr); ok && binary.Op == token.EQL && firstString(binary.Y) == "node_modules" {
						f.replace(binary, "("+f.text(binary)+" || "+f.text(binary.X)+" == \"vendor\")")
					}
					return true
				})
			}
			ast.Inspect(fn.Body, func(n ast.Node) bool {
				call, ok := n.(*ast.CallExpr)
				if !ok {
					return true
				}
				program := f.commandName(call)
				// The sandbox lacks the system installation layout expected by --session.
				// Point private test buses directly at the packaged session configuration.
				if o.platform == "linux" && o.dbus != "" && program == "dbus-daemon" {
					for _, arg := range call.Args[1:] {
						if firstString(arg) == "--session" {
							f.replace(arg, strconv.Quote("--config-file="+o.dbus))
						}
					}
				}
				// xcbuild's plutil lacks Apple's raw extraction; read the same plist
				// array element with Python without replacing other plutil operations.
				if o.platform == "darwin" && program == "plutil" && len(call.Args) == 5 &&
					firstString(call.Args[1]) == "-extract" && firstString(call.Args[2]) == "AssociatedBundleIdentifiers.0" &&
					firstString(call.Args[3]) == "raw" {
					f.replace(call, f.qualify("os/exec", "Command")+"("+strconv.Quote(filepath.Join(o.tools, "python3"))+", \"-c\", `import plistlib, sys; print(plistlib.load(open(sys.argv[1], \"rb\"))[\"AssociatedBundleIdentifiers\"][0])`, "+f.text(call.Args[4])+")")
				}
				return true
			})
			if o.platform == "darwin" {
				// Apple's osascript is unavailable in the Darwin build sandbox. Keep the
				// script-generation assertions and skip only execution when the tool is absent.
				f.beforeCalls(fn.Body, func(call *ast.CallExpr) bool {
					return f.commandName(call) == "osascript"
				}, func(block *ast.BlockStmt) string {
					name := f.testReceiver(block)
					if name == "" {
						return ""
					}
					return "if _, err := " + f.qualify("os/exec", "LookPath") + "(\"osascript\"); err != nil { " + name + ".Skip(\"AppleScript interpreter is unavailable in the build sandbox\") }"
				})
			}
		}
		if test && o.tools != "" {
			// Reparse structural adaptations before changing their nested fixture expressions.
			var err error
			f.source, err = applyEdits(f.source, f.edits)
			if err != nil {
				return fmt.Errorf("%s: %w", f.path, err)
			}
			f.edits = nil
			f.fset = token.NewFileSet()
			f.file, err = parser.ParseFile(f.fset, f.path, f.source, parser.ParseComments)
			if err != nil {
				return fmt.Errorf("%s: %w", f.path, err)
			}
			f.fixtures(o.tools, cleanupPackage(f))
		}
	}
	return nil
}

// installHelper fills template placeholders and formats the injected source.
// Package names let cleanup share one template; the launcher follows the current Nix output.
// Rewrite only changed contents, making existing read-only helpers writable when needed.
func installHelper(dir, name string, o options) error {
	source, err := os.ReadFile(filepath.Join(o.templates, name))
	if err != nil {
		return err
	}
	source = bytes.Replace(source, []byte("package fixture"), []byte("package "+filepath.Base(dir)), 1)
	source = bytes.ReplaceAll(source, []byte("@magpie@"), []byte(o.launcher))
	formatted, err := format.Source(source)
	if err != nil {
		return err
	}
	path := filepath.Join(dir, "nix_"+name)
	old, err := os.ReadFile(path)
	if err == nil && bytes.Equal(old, formatted) {
		return nil
	}
	if err == nil {
		if err := os.Chmod(path, 0o644); err != nil {
			return err
		}
	} else if !os.IsNotExist(err) {
		return err
	}
	return os.WriteFile(path, formatted, 0o644)
}

// installHelpers adds the directory-clock helper, plugin cleanup wrappers and Linux
// scheme/autostart policy tests to real upstream packages. Generated nix_ files are
// excluded from later source scans so they are not patched like upstream fixtures.
func installHelpers(files []*sourceFile, o options) error {
	dirs := map[string]bool{}
	testenv := false
	for _, f := range files {
		if cleanupPackage(f) {
			dirs[filepath.Dir(f.path)] = true
		}
		if filepath.ToSlash(filepath.Dir(f.path)) == "internal/testenv" && f.file.Name.Name == "testenv" {
			testenv = true
		}
	}
	if testenv {
		// Shared fixture clocks must be importable by other packages' tests, so
		// install this template as ordinary Go source only during the check phase.
		if err := installHelper("internal/testenv", "fixture.go", o); err != nil {
			return err
		}
	}
	if o.templates == "" {
		return nil
	}
	for dir := range dirs {
		if err := installHelper(dir, "tempdir_test.go", o); err != nil {
			return err
		}
	}
	if o.gui && o.platform == "linux" {
		// Exercise the Nix scheme and launcher policies against the real upstream packages.
		for _, item := range []struct{ name, dir string }{{"scheme_linux_test.go", "internal/gui"}, {"launcher_linux_test.go", "internal/autostart"}} {
			if err := installHelper(item.dir, item.name, o); err != nil {
				return err
			}
		}
	}
	return nil
}

// adapt scans upstream Go sources outside dependency and hidden directories, runs the
// selected patch phase, formats changed files and fixes imports with goimports.
// The check phase also installs the helper sources needed by the adapted tests.
func adapt(o options) error {
	var files []*sourceFile
	err := filepath.WalkDir(".", func(path string, entry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() {
			if entry.Name() == "vendor" || entry.Name() == "node_modules" || strings.HasPrefix(entry.Name(), ".") && path != "." {
				return filepath.SkipDir
			}
			return nil
		}
		if !strings.HasSuffix(path, ".go") || strings.HasPrefix(entry.Name(), "nix_") {
			return nil
		}
		source, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		fset := token.NewFileSet()
		file, err := parser.ParseFile(fset, path, source, parser.ParseComments)
		if err != nil {
			return fmt.Errorf("%s: %w", path, err)
		}
		files = append(files, &sourceFile{path: path, source: source, original: source, fset: fset, file: file})
		return nil
	})
	if err != nil {
		return err
	}
	if o.phase == "runtime" {
		err = patchRuntime(files, o)
	} else {
		err = patchChecks(files, o)
	}
	if err != nil {
		return err
	}
	var changed []string
	for _, f := range files {
		patched, err := applyEdits(f.source, f.edits)
		if err != nil {
			return fmt.Errorf("%s: %w", f.path, err)
		}
		if bytes.Equal(f.original, patched) {
			continue
		}
		patched, err = format.Source(patched)
		if err != nil {
			return fmt.Errorf("%s after adaptation: %w", f.path, err)
		}
		if err := os.Chmod(f.path, 0o644); err != nil {
			return err
		}
		if err := os.WriteFile(f.path, patched, 0o644); err != nil {
			return err
		}
		changed = append(changed, f.path)
	}
	if len(changed) > 0 {
		cmd := exec.Command("goimports", append([]string{"-w"}, changed...)...)
		if out, err := cmd.CombinedOutput(); err != nil {
			return fmt.Errorf("goimports: %w\n%s", err, out)
		}
	}
	if o.phase == "check" {
		if err := installHelpers(files, o); err != nil {
			return err
		}
	}
	fmt.Printf("magpie %s: adapted %d source files\n", o.phase, len(changed))
	return nil
}

// main selects the patch phase and Nix-provided paths, failing the build on adaptation errors.
func main() {
	var o options
	flag.StringVar(&o.phase, "phase", "", "runtime or check")
	flag.StringVar(&o.platform, "platform", "", "host OS")
	flag.StringVar(&o.arch, "arch", "", "host Go architecture")
	flag.BoolVar(&o.gui, "gui", false, "GUI build")
	flag.StringVar(&o.tools, "tools", "", "basic fixture tools directory")
	flag.StringVar(&o.launcher, "launcher", "", "packaged launcher")
	flag.StringVar(&o.bun, "bun", "", "packaged Bun")
	flag.StringVar(&o.dbus, "dbus", "", "D-Bus session configuration")
	flag.StringVar(&o.templates, "templates", "", "Nix test templates directory")
	flag.Parse()
	if o.phase != "runtime" && o.phase != "check" {
		fmt.Fprintln(os.Stderr, "-phase must be runtime or check")
		os.Exit(1)
	}
	if err := adapt(o); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
