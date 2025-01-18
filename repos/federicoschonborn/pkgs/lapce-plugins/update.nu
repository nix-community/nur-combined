#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

const plugins_file = "./pkgs/lapce-plugins/plugins.json"
const plugins_url = "https://plugins.lapce.dev/api/v1/plugins"

let plugin_count = http get $"($plugins_url)/?limit=0" | get total
print --stderr $plugin_count

let plugins = http get $"($plugins_url)/?limit=($plugin_count)"
| get plugins
| select ...[author name version description wasm]
| sort-by --ignore-case author name
$plugins | save --force $plugins_file

const hashes_file = "./pkgs/lapce-plugins/hashes.json"
let old_hashes = open $hashes_file

mut new_hashes = {};
for plugin in $plugins {
	let clean_author = $plugin.author | str replace " " "-"
	let clean_name = $plugin.name | str replace " " "-"
	let store_file_name = $"lapce-plugin-($clean_author)-($clean_name)-($plugin.version).volt"

	let sri_hash = if not ($store_file_name in $old_hashes) {
		let download_url = http get --raw $"($plugins_url)/($plugin.author)/($plugin.name)/($plugin.version)/download"
		let sha256_hash = try {
			^nix-prefetch-url $download_url --name $store_file_name
		} catch { |err|
			continue
		}

		^nix-hash --type sha256 --to-sri $sha256_hash
	} else {
		$old_hashes | get $store_file_name
	}

	print --stderr $"($store_file_name) = ($sri_hash)"
	$new_hashes = $new_hashes | insert $store_file_name $sri_hash
}

$new_hashes | save --force $hashes_file
