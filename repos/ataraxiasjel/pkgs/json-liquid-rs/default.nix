{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage rec {
  pname = "json-liquid-rs";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ehLytkiQnCk9JXnVzzsSWut8fTKGDOhy2SvOlvgJ3Dg=";
  };

  cargoHash = "sha256-dxg8LtHV7MqZaYTU0lhl7l3p+FBaUqqCRt/szcf85BI=";

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
    mainProgram = "json-liquid-rs";
  };
}
