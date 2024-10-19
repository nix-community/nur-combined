#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

const COLUMNS = [author name version description wasm]

mut plugins = []

let probe = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=0"
let total = $probe.total

let object = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=($total)"
print --stderr $object

let remote_plugins = $object.plugins | select ...$COLUMNS
print --stderr $remote_plugins

mut hashed_plugins = []
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

$plugins = $plugins | append $hashed_plugins
print --stderr $plugins

$plugins | to json
