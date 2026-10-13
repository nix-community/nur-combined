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
  version = "0.1.3-unstable-2026-10-11";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "cade";
    rev = "22dbb03f55f083656e830307018bec7b848e40b0";
    hash = "sha256-wkrtAIafzERrG+xbrLaNLzvfcpBePukHTt209ij0RjU=";
  };

  cargoHash = "sha256-8Bwtj7hmN2omS964i9X/rTJbv6SJJf4+iZZm5LjNUUs=";

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
