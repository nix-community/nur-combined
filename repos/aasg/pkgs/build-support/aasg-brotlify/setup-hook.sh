# Setup hook to compress files in $out with Brotli while keeping the
# originals.
#
# `brotlifyExtensions` is an array of file extensions to compress,
# defaulting to CSS, HTML, and JS files, and their source maps;
# `extraBrotlifyExtensions` can be set to append (instead of
# overwrite) to the defaults.
#
# To disable this setup hook, set `dontBrotlify`.

declare -a brotlifyExtensions extraBrotlifyExtensions

aasgBrotlifyPhase() {
	local ext

	if [[ ! -v brotlifyExtensions ]]; then
		brotlifyExtensions=(html css js html.map css.map js.map)
	fi
	brotlifyExtensions+=("${extraBrotlifyExtensions[@]}")
	for ext in "${brotlifyExtensions[@]}"; do
		args+=("-e" "$ext")
	done

	echo "compressing with Brotli files ending in: ${brotlifyExtensions[@]}"
	fd "" "$out" -t f "${args[@]}" -X brotli --best
}

if [[ -z "${dontBrotlify:-}" ]]; then
	preDistPhases+=" aasgBrotlifyPhase"
fi
