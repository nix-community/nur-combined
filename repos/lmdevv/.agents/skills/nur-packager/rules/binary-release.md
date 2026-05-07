# Binary Release Packaging

Package pre-built binaries from GitHub releases, download pages, or API endpoints.

## When to Use

- GitHub releases with pre-compiled binaries
- Vendor download pages (e.g., `downloads.example.com/cli/v1.0.0/...`)
- npm packages that ship standalone binaries
- curl-based install scripts that download binaries

## Pattern A: Multi-Platform Binary with Per-System Hashes

For CLI tools with per-platform downloads (most common pattern in this NUR):

```nix
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  ...
}:

let
  version = "1.2.3";

  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "my-tool: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if lib.hasPrefix "x86_64" stdenv.hostPlatform.system then
      "x64"
    else if
      lib.hasPrefix "aarch64" stdenv.hostPlatform.system
      || lib.hasPrefix "arm64" stdenv.hostPlatform.system
    then
      "arm64"
    else
      throw "my-tool: unsupported arch ${stdenv.hostPlatform.system}";

  sha256BySystem = {
    "x86_64-linux" = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    "aarch64-linux" = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    "x86_64-darwin" = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";
    "aarch64-darwin" = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=";
  };

  srcUrl = "https://github.com/owner/repo/releases/download/v${version}/my-tool-v${version}-${os}-${arch}.tar.gz";
  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "my-tool: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "my-tool";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    sha256 = srcHash;
  };

  sourceRoot = ".";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp my-tool $out/bin/my-tool
    chmod +x $out/bin/my-tool

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "A CLI tool that does something";
    homepage = "https://github.com/owner/repo";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "my-tool";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
```

### Key Points

- `sha256BySystem` maps every supported Nix system to its hash
- `srcHash` uses `or (throw ...)` to catch missing platforms early
- `autoPatchelfHook` is only needed on Linux (macOS SIP handles linking)
- `stdenv.cc.cc.lib` provides `libstdc++.so.6` on Linux
- `sourceProvenance = with sourceTypes; [ binaryNativeCode ]` marks it as a binary package

## Pattern B: Single Binary Download (No Per-Platform)

For tools that ship a single universal binary:

```nix
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.2.3";

  src = fetchurl {
    url = "https://example.com/downloads/my-tool-${version}.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp my-tool $out/bin/
    chmod +x $out/bin/my-tool
    runHook postInstall
  '';

  meta = with lib; {
    description = "A CLI tool";
    homepage = "https://example.com";
    license = licenses.unfree;
    mainProgram = "my-tool";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
```

## Pattern C: AppImage + DMG

For desktop applications distributed as AppImage (Linux) and DMG (macOS):

```nix
{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  undmg,
  makeWrapper,
  steam-run,
  ...
}:

let
  version = "1.2.3";
  pname = "my-app";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://example.com/releases/v${version}/MyApp-${version}-x86_64.AppImage";
      hash = "sha256-AAA...";
    };
    x86_64-darwin = fetchurl {
      url = "https://example.com/releases/v${version}/MyApp-${version}-macos-x64.dmg";
      hash = "sha256-BBB...";
    };
    aarch64-darwin = fetchurl {
      url = "https://example.com/releases/v${version}/MyApp-${version}-macos-arm64.dmg";
      hash = "sha256-CCC...";
    };
  };
  source = sources.${stdenv.hostPlatform.system}
    or (throw "my-app: unsupported system ${stdenv.hostPlatform.system}");

  linux = appimageTools.wrapType2 {
    inherit pname version;
    src = source;

    extraInstallCommands = ''
      . $out/bin/${pname}-appimage
      desktop-file-install --dir=$out/share/applications \
        ${pname}.desktop 2>/dev/null || true
      install -Dm644 ${pname}.png -t $out/share/pixicons 2>/dev/null || true
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version;
    src = source;

    nativeBuildInputs = [ undmg ];

    sourceRoot = "MyApp.app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r *.app $out/Applications/
      runHook postInstall
    '';

    dontFixup = true;
  };
in
(if stdenv.hostPlatform.isDarwin then darwin else linux).overrideAttrs (_: {
  passthru = {
    inherit sources;
    updateScript = ./update.sh;
  };
  meta = with lib; {
    description = "My desktop application";
    homepage = "https://example.com";
    license = licenses.unfree;
    platforms = builtins.attrNames sources;
    mainProgram = pname;
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
})
```

## Pattern D: Extracting Binary from curl Install Script

Many projects use `curl -fsSL https://example.com/install.sh | sh` patterns. To package these:

1. **Download and read the install script**: `curl -fsSL https://example.com/install.sh`
2. **Find the actual download URL**: Look for `curl`, `wget`, or URL construction in the script
3. **Determine the platform mapping**: Find how the script maps OS/arch to URLs
4. **Determine the version API**: Look for version resolution logic
5. **Extract per-platform hashes**: Use `nix store prefetch-file --json <url>` for each platform

```bash
# Step 1: Read the install script
curl -fsSL https://example.com/install.sh | head -200

# Step 2: Find the download URL pattern
# Look for lines like:
#   URL="https://releases.example.com/${VERSION}/${OS}/${ARCH}/binary"
#   curl -fsSL "$URL" -o /usr/local/bin/tool

# Step 3: Prefetch hashes for each platform
nix store prefetch-file --json "https://releases.example.com/v1.2.3/linux/x64/binary"
```

### Common Install Script Patterns

| Pattern | How to extract |
|---|---|
| `uname -s` / `uname -m` | Map to Nix platform: `x86_64-linux`, `aarch64-linux`, etc. |
| GitHub releases API | `https://api.github.com/repos/OWNER/REPO/releases/latest` |
| Version file/route | `https://example.com/latest-version` or `https://example.com/VERSION` |
| Redirect URL | `curl -fsSLI <url> \| grep Location` |
| Checksum in script | Extract and convert to SRI: `nix hash to-sri --type sha256 <hex>` |

## Prefetching Hashes

```bash
# For a single file
nix store prefetch-file --json "https://example.com/download/v1.2.3/tool-linux-x64.tar.gz"
# Parse the "hash" field from the JSON output

# For all platforms (script)
for sys in x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin; do
  url=$(construct_url "$sys")
  hash=$(nix store prefetch-file --json "$url" | python3 -c 'import sys, json; d=json.load(sys.stdin); print(d.get("hash") or d["narHash"])')
  echo "$sys: $hash"
done
```

## URL Template Patterns

Common release URL patterns and how to map them:

| Upstream Pattern | Nix Template |
|---|---|
| `owner-repo-v1.0.0-linux-amd64.tar.gz` | `${pname}-${version}-${os}-${arch}.tar.gz` |
| `v1.0.0/repo_linux_x64.tar.gz` | `v${version}/${pname}_${os}_${arch}.tar.gz` |
| `releases/download/v1.0.0/repo-1.0.0.tar.gz` | `releases/download/v${version}/${pname}-${version}.tar.gz` |

Always use `${version}` and `${os}`/`${arch}` variables in the URL template so the update script can bump versions automatically.