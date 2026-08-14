package hangamod

import "strings"

func ParseCatalog(csv string) []string {
	var out []string
	for _, part := range strings.Split(csv, ",") {
		name := strings.TrimSpace(part)
		if name != "" {
			out = append(out, name)
		}
	}
	return out
}

func CatalogName(entries []string, index int) string {
	if index >= 0 && index < len(entries) {
		return entries[index]
	}
	return "air"
}

func CatalogIndex(entries []string, name string) int {
	for i, entry := range entries {
		if entry == name {
			return i
		}
	}
	return 0
}
