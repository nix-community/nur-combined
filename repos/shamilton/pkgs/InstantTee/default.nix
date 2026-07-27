{ lib
, fetchFromGitHub
, buildRustPackage
}:

buildRustPackage {
  pname = "InstantTee";
  version = "2021-04-30";

  src = fetchFromGitHub {
    owner = "ArniDagur";
    repo = "InstantTee";
    rev = "8e2b2756ac29f06eca97a6a64e0d92c1bd6380ec";
    sha256 = "1lp9jkajjkfwbdd27mrhr8zdiw9k9nh30r0j4053n2ghbyal9mcw";
  };

  cargoHash = "sha256-ty4e3AfJmDIV/aGHtIn3c4aDo9G/SVuugqvHd0W5fEo=";
  verifyCargoDeps = true;

  meta = with lib; {
    description = "Blazing fast Rust implementation of tee";
    longDescription = ''
      Rust implementation of the tee command using splice() and tee()
      Linux system calls. It is 4-5 times faster than GNU.
    '';
    homepage = "https://github.com/ArniDagur/InstantTee";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
