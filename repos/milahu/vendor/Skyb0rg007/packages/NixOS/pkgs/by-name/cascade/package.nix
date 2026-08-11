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
  version = "0.1.0-beta5";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = "cascade";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fgGXX1HRt70ihxcn8SLK6aQatQvN45mQyEcW9qJ6920=";
  };

  cargoHash = "sha256-ywxblOTG+xT+NzslOhwVe/CmJPplgq8nrjzYoACKYp8=";

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
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
