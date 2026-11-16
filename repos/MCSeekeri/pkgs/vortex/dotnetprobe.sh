#!/bin/sh
if [ "$#" -ne 1 ]; then
  echo "Error: expected one argument, got $#" >&2
  exit 1
fi

if [ -n "${DOTNET_ROOT:-}" ] && [ -x "$DOTNET_ROOT/dotnet" ]; then
  dotnet="$DOTNET_ROOT/dotnet"
else
  dotnet="$(command -v dotnet)" || {
    echo "Error: .NET runtime not found" >&2
    exit 1
  }
fi

runtimes="$("$dotnet" --list-runtimes 2>/dev/null)" || {
  echo "Error: failed to list .NET runtimes" >&2
  exit 1
}

version=""
while read -r name candidate _; do
  if [ "$name" = "Microsoft.NETCore.App" ]; then
    version="$candidate"
    break
  fi
done <<RUNTIMES
$runtimes
RUNTIMES

if [ -z "$version" ]; then
  echo "Error: .NET runtime not found" >&2
  exit 1
fi

major="${version%%.*}"
if [ "$major" -lt "$1" ]; then
  echo "Error: Requires .NET $1 or higher but found .NET $version" >&2
  exit 1
fi

echo "Success: Found .NET $version"
