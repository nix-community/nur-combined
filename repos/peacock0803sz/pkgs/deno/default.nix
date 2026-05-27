{ lib
, stdenv
, stdenvNoCC
, fetchurl
, unzip
, autoPatchelfHook
}:

let
  version = "2.8.0";

  targets = {
    "x86_64-linux" = "x86_64-unknown-linux-gnu";
    "aarch64-linux" = "aarch64-unknown-linux-gnu";
    "aarch64-darwin" = "aarch64-apple-darwin";
  };

  hashes = {
    "x86_64-linux" = "sha256-viyLU8jKHWa+dv65saUkQZ2nCLANTKB0z1xjPIHBYns=";
    "aarch64-linux" = "sha256-kzpqfSmFlXJxzSCFpaWhgyOYqiIaNU2qtWNRls8su64=";
    "aarch64-darwin" = "sha256-26gTuLadYhjP+xElK55OYDbKLJ15hDzeNntLNpqvljQ=";
  };

  system = stdenv.hostPlatform.system;
  target = targets.${system}
    or (throw "deno: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "deno";
  inherit version;

  src = fetchurl {
    url = "https://github.com/denoland/deno/releases/download/v${version}/deno-${target}.zip";
    hash = hashes.${system};
  };

  nativeBuildInputs = [ unzip ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 deno $out/bin/deno
    runHook postInstall
  '';

  meta = {
    description = "A modern runtime for JavaScript and TypeScript";
    homepage = "https://deno.com/";
    license = lib.licenses.mit;
    mainProgram = "deno";
    platforms = lib.attrNames targets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
