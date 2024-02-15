{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage rec {
  pname = "json-liquid-rs";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Ti6drcczUsoKDjUStXJraY0si6g95VeYf6tL/Tv3TXM=";
  };

  cargoHash = "sha256-7NiERuEq5TJuZy7Yj7qgLlAD9JuuEIOw53534ObIVd8=";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Process structured JSON values for Liquid templates";
    homepage = "https://github.com/AtaraxiaSjel/json-liquid-rs";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
