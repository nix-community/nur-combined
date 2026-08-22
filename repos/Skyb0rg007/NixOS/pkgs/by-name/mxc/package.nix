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
  linuxPackages = [
    "--package=lxc"
    "--package=lxc_common"
    "--package=wxc_common"
    "--package=bwrap_common"
    "--package=unix_test_proxy"
  ];
  darwinPackages = [
    "--package=mxc_darwin"
    "--package=unix_test_proxy"
  ];
  buildFeatures = lib.optional withHyperlight "hyperlight" ++ lib.optional withMicrovm "microvm";

  # Taken from ./src/backends/nanvix/binaries/versions.json
  versions = builtins.fromJSON (builtins.readFile ./versions.json);
  nanvixVersions = versions.nanvix_python;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mxc";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "mxc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z5xrkN5MWPtTGgh5G1V4RMSkgFcJtQq5nRqHRY5C7pE=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  cargoHash = "sha256-CSZv4dgjlgiguA7Ghz8I+yhjajk3upRpHElrIog2PbE=";

  env = {
    RUST_BACKTRACE = "1";
    NANVIX_BIN =
      if stdenv.hostPlatform.isLinux then
        fetchzip {
          url = "https://github.com/nanvix/nanvix-python/releases/download/${nanvixVersions.tag}/${nanvixVersions.asset_linux}";
          hash = "sha256-ud2quBPm8rP4AUV0edu0sbvgWpF6bLCxhJJvTkNm+wk=";
          postFetch = ''
            mv $out/bin/nanvixd.elf $out
          '';
        }
      else
        null;
  };

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ bubblewrap ];
  buildInputs = [ lxc ];

  cargoBuildFlags = [
    "--features=${lib.concatStringsSep "," buildFeatures}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux linuxPackages
  ++ lib.optionals stdenv.hostPlatform.isDarwin darwinPackages;
  cargoTestFlags =
    lib.optionals stdenv.hostPlatform.isLinux linuxPackages
    ++ lib.optionals stdenv.hostPlatform.isDarwin darwinPackages;
  checkFlags = [
    "--skip=signal_cleanup::tests::the_watchdogs_view_of_a_container_is_built_and_reset_as_a_single_unit"
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/lxc-exec \
      --prefix PATH : ${lib.makeBinPath [ bubblewrap ]}
  '';

  meta = {
    description = "Sandboxed code execution system for running untrusted code";
    longDescription = ''
      MXC is a sandboxed code execution system for running untrusted code
      (model output, plugins, tools) on Windows, Linux, and macOS. It provides
      multiple containment backends — from OS-native process sandboxes to full
      VMs — behind a unified JSON configuration schema and TypeScript SDK.
    '';
    homepage = "https://github.com/microsoft/mxc";
    license = lib.licenses.mit;
    mainProgram =
      if stdenv.hostPlatform.isLinux then
        "lxc-exec"
      else if stdenv.hostPlatform.isDarwin then
        "mxc-exec-mac"
      else
        null;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    badPlatforms = [ "aarch64-darwin" ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
