{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.0.14";
  releases = {
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-n1z7rBco//3cLV2HTR9/6NNPF54byG+y5npudQdOU/M=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-cxwZFPwtSXoQWD9EFvg4LBkuSJfWoLT3E9YZRFWoVIs=";
    };
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-YZxtzPTozWKQ7EoFLSnIcksqSxUNiTQ1s96QhsIft7E=";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      hash = "sha256-ZzUQH5SxITJ4reYQmYjxckk7hj6AYLUVKQPSFGe5UhM=";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "fx";
  inherit version;

  src = fetchurl {
    url = "https://github.com/vercel-labs/fx/releases/download/v${version}/fx-${release.platform}.tar.gz";
    inherit (release) hash;
  };

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/licenses/fx"
    tar -xzf "$src"
    install -m755 fx "$out/bin/fx"
    install -m644 LICENSE THIRD_PARTY_NOTICES.md "$out/share/licenses/fx/"
    runHook postInstall
  '';

  meta = {
    description = "Tiny, open, native coding agent";
    homepage = "https://fx.sh/";
    license = lib.licenses.asl20;
    mainProgram = "fx";
    platforms = builtins.attrNames releases;
  };
}
