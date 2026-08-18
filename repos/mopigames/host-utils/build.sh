#!/bin/sh
# Build mlos-host-utils for every machine someone might be streaming
# from.  Static, no cgo, no dependencies outside the standard library -- the
# output is one file you copy to the host PC and run.
set -e

cd "$(dirname "$0")"

VERSION="${VERSION:-$(date +%Y.%m.%d)}"
OUT="${OUT:-dist}"

mkdir -p "$OUT"
rm -f "$OUT"/mlos-host-utils-*

echo "mlos-host-utils $VERSION"

go vet ./...
go test ./...

for target in \
	linux/amd64 \
	linux/arm64 \
	windows/amd64 \
	windows/arm64
do
	os="${target%/*}"
	arch="${target#*/}"
	name="mlos-host-utils-$os-$arch"
	[ "$os" = "windows" ] && name="$name.exe"

	echo "  $target"
	CGO_ENABLED=0 GOOS="$os" GOARCH="$arch" \
		go build -trimpath \
		-ldflags "-s -w -X main.Version=$VERSION" \
		-o "$OUT/$name" .
done

echo
ls -lh "$OUT"
