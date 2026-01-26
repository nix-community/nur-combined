package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"text/template"
	"time"
)

type Schema struct {
	Ref   string               `json:"$ref"`
	Defs  map[string]any       `json:"$defs"`
	Props map[string]*Property `json:"properties"`
}

type Property struct {
	Type                 string               `json:"type"`
	Description          string               `json:"description"`
	Default              any                  `json:"default"`
	Enum                 []string             `json:"enum"`
	Ref                  string               `json:"$ref"`
	Properties           map[string]*Property `json:"properties"`
	Items                *Property            `json:"items"`
	AdditionalProperties *Property            `json:"additionalProperties"`
}

type OptionData struct {
	Name        string
	Type        string
	Default     string
	Description string
	EnumValues  []string
	Children    []OptionData
	Indent      string
}

const templates = `
{{- define "root" -}}
{ lib }:

lib.mkOption {
  type = lib.types.submodule {
    options = {
{{- range .Options}}
{{template "option" .}}
{{- end}}
    };
  };
  default = { };
}
{{end}}

{{- define "option" -}}
{{if .Children}}{{template "submodule" .}}
{{- else if .EnumValues}}{{template "enum" .}}
{{- else}}{{template "simple" .}}
{{- end}}
{{- end}}

{{- define "simple" -}}
{{.Indent}}{{.Name}} = lib.mkOption {
{{.Indent}}  type = lib.types.nullOr {{.Type}};
{{.Indent}}  default = {{if .Default}}{{.Default}}{{else}}null{{end}};
{{.Indent}}  description = "{{.Description}}";
{{.Indent}}};
{{end}}

{{- define "enum" -}}
{{.Indent}}{{.Name}} = lib.mkOption {
{{.Indent}}  type = lib.types.nullOr (lib.types.enum [
{{- range .EnumValues}}
{{$.Indent}}    "{{.}}"
{{- end}}
{{.Indent}}  ]);
{{.Indent}}  default = {{if .Default}}{{.Default}}{{else}}null{{end}};
{{.Indent}}  description = "{{.Description}}";
{{.Indent}}};
{{end}}

{{- define "submodule" -}}
{{.Indent}}{{.Name}} = lib.mkOption {
{{- if eq .Type "lib.types.submodule"}}
{{.Indent}}  type = lib.types.submodule {
{{.Indent}}    options = {
{{- range .Children}}
{{template "option" .}}
{{- end}}
{{.Indent}}    };
{{.Indent}}  };
{{- else}}
{{.Indent}}  type = {{.Type}} {
{{.Indent}}    options = {
{{- range .Children}}
{{template "option" .}}
{{- end}}
{{.Indent}}    };
{{.Indent}}  });
{{- end}}
{{.Indent}}  default = {{if .Default}}{{.Default}}{{else}}{ }{{end}};
{{.Indent}}  description = "{{.Description}}";
{{.Indent}}};
{{end}}
`

var tmpl *template.Template

func init() {
	tmpl = template.Must(template.New("nix").Parse(templates))
}

func main() {
	schemaURL := flag.String("url", "", "Schema URL to fetch (defaults to version from pkgs/crush/default.nix)")
	output := flag.String("output", "modules/crush/options/settings.nix", "Output file (defaults to modules/crush/options/settings.nix)")
	flag.Parse()

	// Get version from crush package if URL not provided
	url := *schemaURL
	if url == "" {
		version, err := getCrushVersion()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error getting crush version: %v\n", err)
			os.Exit(1)
		}
		url = fmt.Sprintf("https://raw.githubusercontent.com/charmbracelet/crush/refs/tags/v%s/schema.json", version)
	}

	schema, err := fetchSchema(url)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error fetching schema: %v\n", err)
		os.Exit(1)
	}

	rootDef := resolveRootDef(schema)
	options := generateOptions(rootDef.Properties, schema, "      ")

	outputPath := *output

	var w io.Writer = os.Stdout
	if outputPath != "-" {
		f, err := os.Create(outputPath)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error creating output file: %v\n", err)
			os.Exit(1)
		}
		defer f.Close()
		w = f
		fmt.Fprintf(os.Stderr, "Generated %s\n", outputPath)
	}

	if err := tmpl.ExecuteTemplate(w, "root", map[string]any{
		"Options": options,
	}); err != nil {
		fmt.Fprintf(os.Stderr, "Error executing template: %v\n", err)
		os.Exit(1)
	}
}

func getCrushVersion() (string, error) {
	// Try finding from script directory
	scriptDir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err == nil {
		nixFile := filepath.Join(scriptDir, "..", "pkgs", "crush", "default.nix")
		if version, err := extractVersion(nixFile); err == nil {
			return version, nil
		}
	}

	// Try from current working directory
	nixFile := filepath.Join("pkgs", "crush", "default.nix")
	return extractVersion(nixFile)
}

func extractVersion(nixFile string) (string, error) {
	data, err := os.ReadFile(nixFile)
	if err != nil {
		return "", err
	}

	re := regexp.MustCompile(`version = "([^"]+)"`)
	matches := re.FindSubmatch(data)
	if len(matches) < 2 {
		return "", fmt.Errorf("version not found in %s", nixFile)
	}

	return string(matches[1]), nil
}

func fetchSchema(url string) (*Schema, error) {
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var schema Schema
	if err := json.Unmarshal(body, &schema); err != nil {
		return nil, err
	}

	return &schema, nil
}

func resolveRootDef(schema *Schema) *Property {
	if schema.Ref != "" {
		return resolveRef(schema.Ref, schema)
	}
	return &Property{Properties: schema.Props}
}

func resolveRef(ref string, schema *Schema) *Property {
	if !strings.HasPrefix(ref, "#/$defs/") {
		return &Property{}
	}
	defName := strings.TrimPrefix(ref, "#/$defs/")

	if def, ok := schema.Defs[defName]; ok {
		data, _ := json.Marshal(def)
		var prop Property
		json.Unmarshal(data, &prop)
		return &prop
	}
	return &Property{}
}

func isValidNixIdentifier(name string) bool {
	if name == "" {
		return false
	}
	if name[0] >= '0' && name[0] <= '9' || name[0] == '$' {
		return false
	}
	validChars := regexp.MustCompile(`^[a-zA-Z0-9_-]+$`)
	return validChars.MatchString(name)
}

func escapeNixString(s string) string {
	s = strings.ReplaceAll(s, `\`, `\\`)
	s = strings.ReplaceAll(s, `"`, `\"`)
	s = strings.ReplaceAll(s, "\n", `\n`)
	return s
}

func humanizeName(name string) string {
	name = strings.ReplaceAll(name, "_", " ")
	name = strings.ReplaceAll(name, "-", " ")
	if len(name) > 0 {
		name = strings.ToUpper(string(name[0])) + name[1:]
	}
	return name
}

func nixDefault(val any) string {
	if val == nil {
		return "null"
	}
	switch v := val.(type) {
	case bool:
		if v {
			return "true"
		}
		return "false"
	case float64, int, int64:
		return fmt.Sprintf("%v", v)
	case string:
		return fmt.Sprintf(`"%s"`, escapeNixString(v))
	case []any:
		return "[ ]"
	case map[string]any:
		return "{ }"
	default:
		return fmt.Sprintf("%v", v)
	}
}

func nixType(jsonType string) string {
	switch jsonType {
	case "string":
		return "lib.types.str"
	case "number":
		return "lib.types.number"
	case "integer":
		return "lib.types.int"
	case "boolean":
		return "lib.types.bool"
	case "array":
		return "(lib.types.listOf lib.types.str)"
	case "object":
		return "(lib.types.attrsOf lib.types.anything)"
	default:
		return "lib.types.anything"
	}
}

func generateOptions(props map[string]*Property, schema *Schema, indent string) []OptionData {
	if props == nil {
		return nil
	}

	// Sort keys for deterministic output
	names := make([]string, 0, len(props))
	for name := range props {
		names = append(names, name)
	}
	sort.Strings(names)

	var options []OptionData
	for _, name := range names {
		prop := props[name]
		if !isValidNixIdentifier(name) {
			continue
		}

		// Preserve description before resolving ref (description is on the property, not the ref target)
		originalDescription := prop.Description
		originalDefault := prop.Default

		if prop.Ref != "" {
			prop = resolveRef(prop.Ref, schema)
		}

		// Use original description/default if the ref target doesn't have one
		description := prop.Description
		if originalDescription != "" {
			description = originalDescription
		}
		if description == "" {
			description = humanizeName(name)
		}
		defaultVal := prop.Default
		if originalDefault != nil {
			defaultVal = originalDefault
		}

		opt := OptionData{
			Name:        name,
			Description: escapeNixString(description),
			Indent:      indent,
		}

		// Enums
		if len(prop.Enum) > 0 {
			opt.EnumValues = prop.Enum
			if defaultVal != nil {
				opt.Default = fmt.Sprintf(`"%v"`, defaultVal)
			}
			options = append(options, opt)
			continue
		}

		// Nested objects with properties
		if prop.Type == "object" && len(prop.Properties) > 0 {
			opt.Type = "lib.types.submodule"
			opt.Children = generateOptions(prop.Properties, schema, indent+"      ")
			if defaultVal != nil {
				opt.Default = "{ }"
			}
			options = append(options, opt)
			continue
		}

		// Arrays of objects
		if prop.Type == "array" && prop.Items != nil {
			items := prop.Items
			if items.Ref != "" {
				items = resolveRef(items.Ref, schema)
			}

			if items.Type == "object" && len(items.Properties) > 0 {
				opt.Type = "lib.types.listOf (lib.types.submodule"
				opt.Children = generateOptions(items.Properties, schema, indent+"      ")
				if defaultVal != nil {
					opt.Default = "[ ]"
				}
				options = append(options, opt)
				continue
			}

			opt.Type = "lib.types.listOf lib.types.str"
			if defaultVal != nil {
				opt.Default = "[ ]"
			}
			options = append(options, opt)
			continue
		}

		// AdditionalProperties (attrs of objects)
		if prop.Type == "object" && prop.AdditionalProperties != nil {
			additionalProps := prop.AdditionalProperties
			if additionalProps.Ref != "" {
				additionalProps = resolveRef(additionalProps.Ref, schema)
			}

			if additionalProps.Type == "object" && len(additionalProps.Properties) > 0 {
				opt.Type = "lib.types.attrsOf (lib.types.submodule"
				opt.Children = generateOptions(additionalProps.Properties, schema, indent+"      ")
				if defaultVal != nil {
					opt.Default = "{ }"
				}
				options = append(options, opt)
				continue
			}

			opt.Type = "lib.types.attrsOf lib.types.anything"
			if defaultVal != nil {
				opt.Default = "{ }"
			}
			options = append(options, opt)
			continue
		}

		// Simple types
		opt.Type = nixType(prop.Type)
		if defaultVal != nil {
			opt.Default = nixDefault(defaultVal)
		}
		options = append(options, opt)
	}

	return options
}
