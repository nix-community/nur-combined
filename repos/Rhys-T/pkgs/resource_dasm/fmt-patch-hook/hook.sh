fmtPatchHook() {
	shopt -s globstar
	for file in src/**/*.{cc,hh}; do
		substituteInPlace "$file" \
			--replace-quiet '#include <format>' $'#include <fmt/format.h>\nusing fmt::format;' \
			--replace-quiet 'std::format' 'fmt::format'
	done
	shopt -u globstar
}
postPatchHooks+=(fmtPatchHook)
fmtLinkHook() {
	export NIX_LDFLAGS+=' -lfmt'
}
preBuildHooks+=(fmtLinkHook)
