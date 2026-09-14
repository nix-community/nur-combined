{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  installShellFiles,
  nix-update-script,
  testers,
  versionCheckHook,
  nixosTests,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cascade";
  version = "0.1.0-beta7";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = "cascade";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lpfx2WS+7Vxa4Pax23qkjyrIen5kZZZAiJvtfLBHYzo=";
  };

  cargoHash = "sha256-8hMCyPi/3sBY1Fz+xRVZNsc2qFwGoAM3tROuMmDz+dk=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildInputs = [ openssl ];

  doInstallCheck = true;

  postInstall = ''
    installManPage ./doc/manual/build/man/*.{1,5}
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version=unstable" ];
    };
    tests.nixos = nixosTests.cascade;
  };

  meta = {
    description = "Friendly DNSSEC signing pipeline";
    mainProgram = "cascade";
    homepage = "https://blog.nlnetlabs.nl/cascade/";
    downloadPage = "https://github.com/NLnetLabs/cascade";
    changelog = "https://github.com/NLnetLabs/cascade/blob/${finalAttrs.src.tag}/Changelog.md";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
