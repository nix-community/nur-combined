{
  lib,
  rustPlatform,
  fetchFromGitHub,
  rustc,
}:
rustPlatform.buildRustPackage rec {
  pname = "wild";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "davidlattimore";
    repo = "wild";
    tag = version;
    hash = "sha256-12W7XJklFyFLN9WcZkyYRn29P2dOI0fzncjs93Iz778=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-/xE9hZDxmcqR6D+v5+TmHsoekhnjN98q875uBC8yM+Q=";

  meta = with lib; {
    description = "A very fast linker for Linux";
    homepage = "https://github.com/davidlattimore/wild";
    changelog = "https://github.com/davidlattimore/wild/blob/${version}/CHANGELOG.md";
    license = licenses.mit;
    mainProgram = "wild";
    broken = !versionAtLeast rustc.version "1.85.0";
  };
}
