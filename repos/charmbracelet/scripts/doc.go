// Package main generates Nix module options from Crush schema.
//
//go:generate sh -c "cd .. && go run scripts/generate-crush-settings.go -output modules/crush/options/settings.nix && nixfmt modules/crush/options/settings.nix"
package main
