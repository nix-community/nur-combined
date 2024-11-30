#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

def main [] {
	const output = "./pkgs/lapce-plugins/plugins.json"

	let plugin_count = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=0" | get total
	print --stderr $plugin_count

	let upstream_plugins = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=($plugin_count)"
		| get plugins
		| select ...[author name version description wasm]
		| sort-by --ignore-case author name
	print --stderr $upstream_plugins

	mut collected = [];
	for plugin in $upstream_plugins {
		try {
			let url = http get --raw $"https://plugins.lapce.dev/api/v1/plugins/($plugin.author)/($plugin.name)/($plugin.version)/download"
			print --stderr $url

			let clean_author = $plugin.author | str replace " " "-"
			let clean_name = $plugin.name | str replace " " "-"
			let store_file_name = $"lapce-plugin-($clean_author)-($clean_name)-($plugin.version).volt"
			print --stderr $store_file_name

			let sha256_hash = ^nix-prefetch-url $url --name $store_file_name
			print --stderr $sha256_hash

			let sri_hash = ^nix-hash --type sha256 --to-sri $sha256_hash
			print --stderr $sri_hash

			let hashed_plugin = $plugin | insert hash $sri_hash
			$collected = $collected | append $hashed_plugin
		} catch { |err|
			print --stderr $err.msg
			continue
		}
	}

	$collected | save --force $output
}
