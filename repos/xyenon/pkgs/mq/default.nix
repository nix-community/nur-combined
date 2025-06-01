{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.2.0-unstable-2025-06-01";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "3deb9721daf33c53b6e4b0f67aef7a82b01b6baf";
    hash = "sha256-V5amqmBiCxaqUO93e10LryjZ7IT9s6+fMr0GdE2ZGI8=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-+0T0MTGeqdBj23nc6A+XqWEw1I+nZeJgiiOlu+RVjtE=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Jq like markdown processing tool";
    homepage = "https://github.com/harehare/mq";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
    mainProgram = "mq";
    broken = versionOlder rustc.version "1.85.0";
  };
}
