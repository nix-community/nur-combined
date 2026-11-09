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
  version = "0.1.0-beta8";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = "cascade";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ElZsyriN/STm3zUaLA5iwi8ED5NmfEFHmvzm17I1ukA=";
  };

  cargoHash = "sha256-aMRvvJd5m8yDoylz1vdi0746u8Jx/9vfzhl3L0VHoiQ=";

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
