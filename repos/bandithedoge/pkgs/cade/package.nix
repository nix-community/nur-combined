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
  version = "0.1.3-unstable-2026-10-28";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "ee902c44750567241c3969703945c924a97bc9c4";
    hash = "sha256-YTWz7Tqd8zJPfLRiAmcOPHHhq6xBJCKrjwdjFhRUyRA=";
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
