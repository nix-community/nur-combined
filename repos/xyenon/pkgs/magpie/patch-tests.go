package main

import (
	"bytes"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

var systemDir = regexp.MustCompile(`(^|:)/(usr/)?bin(:|$)`)
var absoluteTool = regexp.MustCompile(`(^|[^\w/.-])/(usr/)?bin/([\w.-]+)\b`)

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

func usesSystemPath(expr ast.Expr) bool {
	found := false
	ast.Inspect(expr, func(node ast.Node) bool {
		if literal, ok := node.(*ast.BasicLit); ok && literal.Kind == token.STRING {
			value, _ := strconv.Unquote(literal.Value)
			found = found || systemDir.MatchString(strings.TrimPrefix(value, "PATH="))
		}
		return true
	})
	return found
}

// Keep edits at token offsets so unrelated source and build tags stay untouched.
func patchTests(source []byte, tools string) ([]byte, error) {
	fset := token.NewFileSet()
	file, err := parser.ParseFile(fset, "test.go", source, 0)
	if err != nil {
		return nil, err
	}
	type edit struct {
		start, end int
		text       string
	}
	var edits []edit
	scripts := map[*ast.BasicLit]bool{}
	patchEnv := func(expr ast.Expr) {
		if values, ok := expr.(*ast.CompositeLit); ok {
			for _, value := range values.Elts {
				if strings.HasPrefix(firstString(value), "PATH=") && usesSystemPath(value) {
					edits = append(edits, edit{fset.Position(value.End()).Offset, fset.Position(value.End()).Offset, " + " + strconv.Quote(":"+tools)})
				}
			}
		}
	}
	ast.Inspect(file, func(node ast.Node) bool {
		switch node := node.(type) {
		case *ast.CallExpr:
			if selector, ok := node.Fun.(*ast.SelectorExpr); ok && selector.Sel.Name == "Setenv" && len(node.Args) == 2 && firstString(node.Args[0]) == "PATH" && usesSystemPath(node.Args[1]) {
				edits = append(edits, edit{fset.Position(node.Args[1].End()).Offset, fset.Position(node.Args[1].End()).Offset, " + " + strconv.Quote(":"+tools)})
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
					// Fake commands still win; never inherit agents or package managers.
					patched = header + "\nexport PATH=\"${PATH:+$PATH:}" + tools + "\"\n" + body
				} else if len(interpreter) == 2 && name == "env" && interpreter[1] == "python3" {
					patched = "#!" + filepath.Join(tools, "python3") + "\n" + body
				}
			}
		}
		if patched != value {
			edits = append(edits, edit{fset.Position(literal.Pos()).Offset, fset.Position(literal.End()).Offset, strconv.Quote(patched)})
		}
	}
	sort.Slice(edits, func(i, j int) bool { return edits[i].start > edits[j].start })
	for _, edit := range edits {
		source = append(append(append([]byte{}, source[:edit.start]...), edit.text...), source[edit.end:]...)
	}
	return source, nil
}

func main() {
	if len(os.Args) != 2 {
		panic("usage: patch-tests <basic-tools-bin>")
	}
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
		if !strings.HasSuffix(path, "_test.go") {
			return nil
		}
		source, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		patched, err := patchTests(source, os.Args[1])
		if err != nil {
			return fmt.Errorf("%s: %w", path, err)
		}
		if bytes.Equal(source, patched) {
			return nil
		}
		if err := os.Chmod(path, 0o644); err != nil {
			return err
		}
		return os.WriteFile(path, patched, 0o644)
	})
	if err != nil {
		panic(err)
	}
}
