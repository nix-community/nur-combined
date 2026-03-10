{ lib, stdenv, rustPlatform, fetchFromGitHub, darwinMinVersionHook, pkg-config, dbus, apple-sdk_14, fenixRustPlatform ? null, ... }:
let
  version = "0.9.1";
  useFenix = fenixRustPlatform != null && fenixRustPlatform ? buildRustPackage;
  effectiveRustPlatform = if useFenix then fenixRustPlatform else rustPlatform;
in
effectiveRustPlatform.buildRustPackage {
  pname = "gws";
  inherit version;

  src = fetchFromGitHub {
    owner = "googleworkspace";
    repo = "cli";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-lmYSpFw1woO99KQhcA6hk4iDx/tiYj3vultA31DRfC0=";
  };

  cargoHash = "sha256-yghOARbpsPzvMwDm/tQFFteOJulVO1guQZVhWOAZCT8=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ dbus ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ apple-sdk_14 (darwinMinVersionHook "10.15") ];

  doCheck = false;

  meta = {
    description = "Google Workspace CLI — one command-line tool for Drive, Gmail, Calendar, Sheets, Docs, Chat, Admin, and more";
    homepage = "https://github.com/googleworkspace/cli";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "gws";
  } // lib.optionalAttrs (!useFenix) { broken = true; };
}
