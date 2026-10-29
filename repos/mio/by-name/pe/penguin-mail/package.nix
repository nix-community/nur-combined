{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  openssl,
  gtk4,
  glib,
  webkitgtk_6_0,
  libadwaita,
  writeShellApplication,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "penguin-mail";
  version = "1.0.11";

  src = fetchFromGitHub {
    owner = "c9dev";
    repo = "penguin-mail";
    rev = "v${version}";
    hash = "sha256-jSfUHKId7TYnnaToOZhN7yHKR+fk/KQSgnlUlyEZvW8=";
  };

  cargoHash = "sha256-Dv3XtMe/5LYrAZ1cwenjOFm2FytI63cZA3fg9uQTTx8=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    openssl
    gtk4
    glib
    webkitgtk_6_0
    libadwaita
  ];

  doCheck = false;

  passthru.updateScript = writeShellApplication {
    name = "update-penguin-mail";
    text = ''
      export UPDATE_NIX_ATTR_PATH="penguin-mail"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = with lib; {
    description = "Penguin Mail";
    homepage = "https://github.com/c9dev/penguin-mail";
    license = licenses.gpl3Only; # Need to verify exact license
    maintainers = [ ];
    mainProgram = "penguin-mail";
  };
}
