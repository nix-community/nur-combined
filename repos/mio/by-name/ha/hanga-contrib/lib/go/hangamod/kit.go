package hangamod

import (
	"strconv"
	"strings"
)

// Fields splits `key=value` records on `;` or newlines. Unknown keys stay in the list.
func Fields(text string) [][2]string {
	var out [][2]string
	for _, raw := range strings.FieldsFunc(text, func(r rune) bool {
		return r == ';' || r == '\n'
	}) {
		rec := strings.TrimSpace(raw)
		if rec == "" || strings.HasPrefix(rec, "#") {
			continue
		}
		key, val, ok := strings.Cut(rec, "=")
		if !ok {
			continue
		}
		out = append(out, [2]string{strings.TrimSpace(key), strings.TrimSpace(val)})
	}
	return out
}

func Get(text, key string) (string, bool) {
	for _, pair := range Fields(text) {
		if pair[0] == key {
			return pair[1], true
		}
	}
	return "", false
}

func Flag(value string) bool {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case "1", "true", "yes", "on":
		return true
	default:
		return false
	}
}

func F32(text, key string, def float32) float32 {
	raw, ok := Get(text, key)
	if !ok {
		return def
	}
	n, err := strconv.ParseFloat(raw, 32)
	if err != nil {
		return def
	}
	return float32(n)
}

func Bool(text, key string) bool {
	raw, _ := Get(text, key)
	if raw == "" {
		raw = "0"
	}
	return Flag(raw)
}
