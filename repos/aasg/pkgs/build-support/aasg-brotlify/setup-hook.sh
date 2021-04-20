postInstallHooks+=(aasg-brotlify)

aasg-brotlify() {
	if [[ -n "${dontBrotlify:-}" ]]; then return; fi
	fd "" "$out" -t f -e html -e css -e js -e css.map -e js.map -X brotli --best
}
