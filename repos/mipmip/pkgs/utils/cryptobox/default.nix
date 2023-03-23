{ lib, stdenv, fetchFromGitHub, cryptsetup, substituteAll }:

stdenv.mkDerivation rec {
  name = "cryptobox";

  buildCommand = ''
      install -Dm755 $script $out/bin/cryptobox
  '';

  script = substituteAll {
    src = ./cryptobox;
    isExecutable = true;
    inherit cryptsetup;
    inherit (stdenv) shell;
  };

  meta = with lib; {
    description = "A script to create, mount and umount LUKS encrypted disk image files. ";
    homepage = "https://github.com/prurigro/cryptobox";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
