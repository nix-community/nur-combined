package org

import (
	"bytes"
	"fmt"
	"strings"
	"text/template"
)

var (
	additionnalTemplate = `{{ if .Highlights }}* New Highlights on [{{ .Date }}]
{{ range $h := .Highlights -}}
** [{{ $h.Date }}] Highlight [[{{ $h.URL }}][{{ $h.ID }}]]{{ if $h.Tags }} {{ orgtags $h.Tags }}{{ end }}
{{ $h.Text }}
{{ if $h.Note }}*** Note
{{ $h.Note }}
{{ end -}}
{{ end }}{{ end }}`

	mainTemplate = `#+title: {{ .Title }}
#+author: {{ .Author }}
#+date: {{ .Date }}
#+identifier: {{ .Identifier }}
#+category: {{ .Category }}
{{ if .FileTags }}#+filetags: {{ orgtags .FileTags }}{{ end }}
#+property: READWISE_URL: {{ .ReadwiseURL }}
{{ if .URL }}#+property: URL: {{ .URL }}{{ end }}

{{ .Summary }}

* Highlights
{{ range $h := .Highlights -}}
** [{{ $h.Date }}] Highlight [[{{ $h.URL }}][{{ $h.ID }}]]{{ if $h.Tags }} {{ orgtags $h.Tags }}{{ end }}
{{ $h.Text }}
{{ if $h.Note }}*** Note
{{ $h.Note }}
{{ end -}}
{{ end -}}
`
)

func orgtags(tags []string) string {
	if len(tags) == 0 {
		return ""
	}
	return fmt.Sprintf(":%s:", strings.Join(tags, ":"))
}

func convertDocument(d Document) ([]byte, error) {
	var err error

	funcMap := template.FuncMap{
		"orgtags": orgtags,
	}

	tmpl, err := template.New("org").Funcs(funcMap).Parse(mainTemplate)
	if err != nil {
		return []byte{}, err
	}
	var buff bytes.Buffer
	if err := tmpl.Execute(&buff, d); err != nil {
		return []byte{}, err
	}
	return buff.Bytes(), nil
}

func convertPartialDocument(d PartialDocument) ([]byte, error) {
	var err error

	funcMap := template.FuncMap{
		"orgtags": orgtags,
	}

	tmpl, err := template.New("org").Funcs(funcMap).Parse(additionnalTemplate)
	if err != nil {
		return []byte{}, err
	}
	var buff bytes.Buffer
	if err := tmpl.Execute(&buff, d); err != nil {
		return []byte{}, err
	}
	return buff.Bytes(), nil
}
