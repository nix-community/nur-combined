{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, wrapGAppsHook4
, openssl
, gtk4
, glib
, webkitgtk_6_0
, libadwaita
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "penguin-mail";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "c9dev";
    repo = "penguin-mail";
    rev = "v${version}";
    hash = "sha256-LUlSoYG56LvokST4c+Yo9tazaF/URMXGyxML1GiR7c8=";
  };

  cargoHash = "sha256-NUh73jijo3FvEMZPmo6RXKvkcIgDqU3q0i+BOOaA0Ok=";

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
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false;

  meta = with lib; {
    description = "Penguin Mail";
    homepage = "https://github.com/c9dev/penguin-mail";
    license = licenses.gpl3Only; # Need to verify exact license
    maintainers = [ ];
    mainProgram = "penguin-mail";
  };
}
