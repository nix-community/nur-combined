{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  pkg-config,
  sqlite,
}:
rustPlatform.buildRustPackage {
  pname = "cade";
  version = "0.1.3-unstable-2026-10-23";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "2cd50bdd6901ab61c65fc22cab834527a439899a";
    hash = "sha256-tQdJkyme27yMAOLq4rVu7uvATSHIfNTELmzO3c2eSzk=";
  };

  cargoHash = "sha256-xT0+aQ025NlCfUlyXxC/Vptp8iqitjZeQTdv41Lcn+w=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ sqlite ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Intelligent, cascading environment manager";
    homepage = "https://github.com/manic-systems/cade";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "cade";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
