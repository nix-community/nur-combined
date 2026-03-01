---
name: nix-packaging
description: Use this when writing or modifying Nix package definitions (.nix files). Covers stdenv, buildGoModule, buildRustPackage, buildFlutterApplication, and appimageTools patterns.
---

## Use this when

- Creating new packages in `pkgs/`
- Updating existing package versions
- Fixing build issues in Nix derivations
- Adding dependencies to packages

## Builder Patterns

### stdenv.mkDerivation (generic)
```nix
stdenv.mkDerivation {
  pname = "...";
  version = "...";
  src = fetchFromGitHub { ... };
  
  nativeBuildInputs = [ pkg-config ];  # build-time tools
  buildInputs = [ openssl ];            # libraries
  
  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';
  
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install -m755 binary "$out/bin/"
    runHook postInstall
  '';
}
```

### buildGoModule
```nix
buildGoModule rec {
  pname = "...";
  version = "...";
  src = fetchFromGitHub { ... };
  
  vendorHash = "sha256-...";  # or null if vendor/ included
  
  ldflags = [
    "-s" "-w"
    "-X main.version=${version}"
  ];
  
  doCheck = false;  # if tests need network
}
```

### buildRustPackage
```nix
rustPlatform.buildRustPackage rec {
  pname = "...";
  version = "...";
  src = fetchFromGitHub { ... };
  
  cargoLock.lockFile = ./Cargo.lock;
  
  # If Cargo.lock not in source
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';
  
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
}
```

### appimageTools
```nix
let
  src = fetchurl {
    url = "...AppImage";
    hash = "sha256-...";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;
  
  extraPkgs = pkgs: [ pkgs.libxcrypt-legacy ];
  
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${appimageContents}/*.desktop $out/share/applications/
  '';
}
```

### buildFlutterApplication
```nix
flutter.buildFlutterApplication rec {
  pname = "...";
  version = "...";
  src = fetchFromGitHub { ... };
  
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  # OR using yq: importYaml "${src}/pubspec.lock";
  
  gitHashes = {
    some_package = "sha256-...";
  };
}
```

## Hash Techniques

### Get hash from failed build
```nix
hash = lib.fakeHash;  # Placeholder
# Build fails, copy real hash from error
```

### Prefetch methods
```bash
# URL
nix-prefetch-url --unpack <url>

# GitHub
nix-prefetch-github owner repo --rev v1.0.0
```

## Checklist

- [ ] Use `runHook pre/post*` in phases
- [ ] Include complete `meta` block
- [ ] License in list form: `[mit]`
- [ ] Test build: `nix-build -A <pkg>`
- [ ] Verify binary runs (if applicable)
