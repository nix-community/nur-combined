{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage rec {
  pname = "json-liquid-rs";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-E5lUdQUZvXyVdBVK/CYiV6DIbgdiOeR+NatZzlQWtrE=";
  };

  cargoHash = "sha256-YDxdFotYYZsdvklaUsVzRp4erzLLvPNVyoaxeMPY8Io=";

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
