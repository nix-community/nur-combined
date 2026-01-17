{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ncurses,
  dmd,
  ldc,
  dtools,
  readline,
}:
stdenv.mkDerivation {
  pname = "shed";
  version = "0-unstable-2025-03-29";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "shed";
    rev = "3bdcfdc0be50bcf4ca10deedea36203f4fdc4df5";
    hash = "sha256-rhtcueNDQnzHpw26b0YbIkPWCRHU6oRQ2lBkKeJdv9E=";
  };

  patches = [ ./dynamic-linking.patch ];

  nativeBuildInputs = [
    dmd
    ldc
    dtools
  ];
  buildInputs = [
    readline
    ncurses
  ];

  buildPhase = "rdmd build.d";
  installPhase = "mkdir -p $out/bin; cp shed $out/bin";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Shell in D";
    license = "free"; # unspecified, but as Tsoding always uses MIT and this package doesn't really matter a whole lot I'd just mark it as free
    homepage = "https://github.com/tsoding/shed";
    broken =
      lib.versionOlder dmd.version "2.112.0"
      && stdenv.cc.isGNU
      && lib.versionAtLeast stdenv.cc.cc.version "15";
    mainProgram = "shed";
  };
}
