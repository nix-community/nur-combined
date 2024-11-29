#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell

def main [
	--output (-o): string
] {
	let plugin_count = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=0" | get total
	print --stderr $plugin_count

	let upstream_plugins = http get $"https://plugins.lapce.dev/api/v1/plugins/?limit=($plugin_count)"
		| get plugins
		| select ...[author name version description wasm]
		| sort-by --ignore-case author name
	print --stderr $upstream_plugins

	"{ lib, mkLapcePlugin }:\n\n{" | save --force $output
	$upstream_plugins | group-by author | items { |$author, $plugins|
		let clean_author = $author | str replace " " "-"
		let attr_author = $clean_author | str downcase

		mut collected = [];
		for plugin in $plugins {
			try {
				let clean_name = $plugin.name | str replace " " "-"
				let attr_name = $clean_name | str downcase

				let url = http get --raw $"https://plugins.lapce.dev/api/v1/plugins/($author)/($plugin.name)/($plugin.version)/download"
				print --stderr $url

				let store_file_name = $"lapce-plugin-($clean_author)-($clean_name)-($plugin.version).volt"
				print --stderr $store_file_name

				let sha256_hash = ^nix-prefetch-url $url --name $store_file_name
				print --stderr $sha256_hash

				let sri_hash = ^nix-hash --type sha256 --to-sri $sha256_hash
				print --stderr $sri_hash

				$collected = $collected | append $'"($attr_name)" = mkLapcePlugin { author = "($author)"; name = "($plugin.name)"; version = "($plugin.version)"; hash = "($sri_hash)"; wasm = ($plugin.wasm); };'
			} catch { |err|
				print --stderr $err.msg
				return
			}
		}
		$'"($attr_author)" = lib.recurseIntoAttrs {' | save --append $output
		$collected | save --append $output
		"};\n" | save --append $output
	}
	"}" | save --append $output

	^nix fmt $output
}
