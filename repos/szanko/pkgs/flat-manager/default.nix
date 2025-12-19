{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, glib
, openssl
, postgresql
, stdenv
, darwin
, ostree-full
}:

rustPlatform.buildRustPackage rec {
  pname = "flat-manager";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = "flat-manager";
    rev = version;
    hash = "sha256-xPEVYR4y95NtTJB42LZE5R5lDE6HcBhmxYvC0nHWIDo=";
  };

  cargoHash = "sha256-zvMlYbxpbM/8OEC7s/XSuzOG+BpgyHd6D+gvUFPxMGk=";

  nativeBuildInputs = [
    pkg-config
  ];


  buildInputs = [
    glib
    openssl
    postgresql
    ostree-full
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  meta = {
    description = "Manager for flatpak repositories";
    homepage = "https://github.com/flatpak/flat-manager";
    license = with lib.licenses; [ asl20 mit ];
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "flat-manager";
  };
}
