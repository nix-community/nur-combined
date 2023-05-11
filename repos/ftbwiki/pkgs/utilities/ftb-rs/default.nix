{ lib, fetchFromGitHub, rustPlatform, pkg-config, openssl, optipng }:

rustPlatform.buildRustPackage rec {
  pname = "ftb-rs";
  version = "2023-02-08";

  src = fetchFromGitHub {
    owner = "FTB-Gamepedia";
    repo = pname;
    rev = "a251ae78b98a42360298256c3f55c7e686ba68d9";
    sha256 = "sha256-V8zbfRIxacubyrNI25HosJkXhz4a2rG6Z+tuq4fzA7c=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    # allowBuiltinFetchGit = true;
    outputHashes = {
      "mediawiki-0.0.1" = "sha256-waGHh75+tOoDIXUiTOIzcH64hhLwLdhkavJCW/CL/ig=";
    };
    # TODO: find better workaround for this
  };

  buildInputs = [ openssl ];

  nativeBuildInputs = [ pkg-config ];

  patchPhase = ''
    substituteInPlace src/tilesheets.rs --replace 'Command::new("optipng")' 'Command::new("${optipng}/bin/optipng")'
  '';

  meta = with lib; {
    description = "A tool to upload tilesheets to the Official FTB Wiki";
    homepage =
      "https://ftb.fandom.com/wiki/Feed_The_Beast_Wiki:Tilesheet_update_guide";
    license = licenses.bsd3;
    mainProgram = "ftb";
  };
}
