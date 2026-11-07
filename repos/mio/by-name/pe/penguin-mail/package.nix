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
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "c9dev";
    repo = "penguin-mail";
    rev = "v${version}";
    hash = "sha256-F6bBphfyMHTH79cscaRkeV/j4oRTyhiRPltUgKqTAhU=";
  };

  cargoHash = "sha256-+8Dvr/eHTYDJst9/MQ1MS0GLWqmkiVGuRe+cLh2MZOs=";

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
