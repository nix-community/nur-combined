#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

const COLUMNS = [author name version description wasm]

mut plugins = []

let total = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=0" | get total
print --stderr $total

let remote_plugins = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=($total)" | get plugins | select ...$COLUMNS
print --stderr $remote_plugins

for plugin in $remote_plugins {
	try {
		let url = http get --raw $"https://plugins.lapce.dev/api/v1/plugins/($plugin.author)/($plugin.name)/($plugin.version)/download"
		print --stderr $url
		let sha256 = ^nix-prefetch-url $url --name $"lapce-plugin-($plugin.author)-($plugin.name)-($plugin.version).volt"
		print --stderr $sha256
		let hash = ^nix-hash --type sha256 --to-sri $sha256
		print --stderr $hash

		let hashed_plugin = $plugin | insert hash $hash
		$plugins = $plugins | append $hashed_plugin
	} catch {
		continue
	}
}

print --stderr $plugins
$plugins | to json
