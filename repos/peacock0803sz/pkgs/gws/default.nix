{ lib, stdenv, rustPlatform, fetchFromGitHub, darwinMinVersionHook, pkg-config, dbus, apple-sdk_14, ... }:
let
  version = "0.4.4";
in
rustPlatform.buildRustPackage (final: {
  pname = "gws";
  inherit version;

  src = fetchFromGitHub {
    owner = "googleworkspace";
    repo = "cli";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-M1Xy9nLfS+U7dDpbVhlNCGGp+K4//CJ5l10R3VVc5qo=";
  };

  cargoHash = "sha256-vK77ay23TFrT0e9G1ml3BJTh0teOsyLnd9HpESePdYo=";

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
    broken = true; # requires rustc >= 1.88.0, nixpkgs has 1.86.0
  };
})
