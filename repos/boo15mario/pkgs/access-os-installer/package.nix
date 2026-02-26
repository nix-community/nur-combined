{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, gtk4
}:

rustPlatform.buildRustPackage rec {
  pname = "access-os-installer";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Boo15mario";
    repo = "access-os-installer";
    rev = "main";
    sha256 = "0ndvddw5s0qjcrzlccyj99a2c53j7iaf7iy8jdbkhn3lv5lg2m0s";
  };

  cargoHash = "sha256-f3wQYppd/rNAhnv2cvEUvd5vmzGXPkJSebRLnAX++/k=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk4
  ];

  meta = with lib; {
    description = "An accessible GTK4 based installer for access-OS";
    homepage = "https://github.com/Boo15mario/access-os-installer";
    license = licenses.mit;
    mainProgram = "access-os-installer";
  };
}
