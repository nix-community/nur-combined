{
  fetchFromGitHub,
  rustPlatform,
  libseccomp,
  makeWrapper,

  python3,
  gcc,
}:
let
  pname = "task-maker-rust";
  version = "0.6.4";
  src = fetchFromGitHub {
    owner = "olimpiadi-informatica";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-DmiQghZ/Kjz9ln0P6B3JLJXsIPa0GFcSQTkAjjgSQcI=";
  };
in
rustPlatform.buildRustPackage {
  inherit pname version src;
  patches = [
    ./mount-nix-store.patch
    ./do-not-canonicalize.patch
  ];
  doCheck = false;
  buildInputs = [
    libseccomp
    makeWrapper
  ];
  cargoLock.lockFile = ./Cargo.lock;
  cargoLock.outputHashes = {
    "typescript-definitions-0.1.10" = "sha256-6jYmi5yn4RWtkjktApgojaN31YPg1At3v6O6KZfAp3U=";
  };
  postInstall = ''
    wrapProgram $out/bin/task-maker --prefix PATH : ${python3}/bin:${gcc}/bin
    ln -sr $out/bin/task-maker $out/bin/task-maker-rust
  '';
}
