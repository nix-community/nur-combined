{ lib, stdenv, rustPlatform, fetchFromGitHub, darwinMinVersionHook, pkg-config, dbus, apple-sdk_14, fenixRustPlatform ? null, ... }:
let
  version = "0.8.0";
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
    sha256 = "sha256-0G40XB6d+ST2O64KuXZrgnm1mxvEtXUM3XCqKuKjfhQ=";
  };

  cargoHash = "sha256-ndosxV+wd1wpKu18fKLl+TWn/uA3j2kte6C+vcQ5jdg=";

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
