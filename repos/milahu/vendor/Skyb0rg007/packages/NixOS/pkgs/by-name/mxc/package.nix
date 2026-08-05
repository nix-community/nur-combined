{
  lib,
  rustPlatform,
  fetchzip,
  runCommand,
  lxc,
  bubblewrap,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  withHyperlight ? true,
  withMicrovm ? true,
}:
let
  lxcPackages = lib.map (p: "--package=${p}") [
    "lxc"
    "lxc_common"
    "wxc_common"
    "bwrap_common"
    "linux_test_proxy"
  ];
  buildFeatures = lib.optional withHyperlight "hyperlight" ++ lib.optional withMicrovm "microvm";

  # Taken from ./src/backends/nanvix/binaries/versions.json
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  nanvixVersions = versions.nanvix_python;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mxc";
  version = "0.7.0-unstable-2026-07-08";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mxc";
    rev = "25e504e08f297b52c8aa2ca4966560a6ebb8b48f";
    hash = "sha256-1PP0P3JoCCwaKRNQEqqH8Rf2N0PQABTAnoE8ILwQGns=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  cargoHash = "sha256-noSmQB4ZvCBbJ63XAf1wKibVR6WIw+5omTNUvN3nFYw=";

  env = {
    RUST_BACKTRACE = "full";
    NANVIX_BIN = fetchzip {
      url = "https://github.com/nanvix/nanvix-python/releases/download/${nanvixVersions.tag}/${nanvixVersions.asset_linux}";
      hash = "sha256-ud2quBPm8rP4AUV0edu0sbvgWpF6bLCxhJJvTkNm+wk=";
      postFetch = ''
        mv $out/bin/nanvixd.elf $out
      '';
    };
  };

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ bubblewrap ];
  buildInputs = [ lxc ];

  cargoBuildFlags = lxcPackages ++ [
    "--features=${lib.concatStringsSep "," buildFeatures}"
  ];
  cargoTestFlags = lxcPackages;

  postInstall = ''
    wrapProgram $out/bin/lxc-exec \
      --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
  '';

  meta = {
    description = "Sandboxed code execution system for running untrusted code";
    homepage = "https://github.com/microsoft/mxc";
    license = lib.licenses.mit;
    mainProgram = if stdenv.hostPlatform.isLinux then "lxc-exec" else null;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    badPlatforms = [ "aarch64-darwin" ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
