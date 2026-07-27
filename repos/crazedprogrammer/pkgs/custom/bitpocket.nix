{ lib, stdenv, fetchFromGitHub, makeWrapper, locale, hostname, mount, openssh, rsync }:

stdenv.mkDerivation rec {
  pname = "bitpocket";
  version = "latest-2021-02-23";

  src = fetchFromGitHub {
    owner = "sickill";
    repo = "bitpocket";
    rev = "a868b35f9830be6afce2c9a887236652e843793b";
    sha256 = "084jwk6rka7q4406gzvlyrg9cspf4gj5djz9l0rs06d79v4mn7ry";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 ./bin/bitpocket $out/bin/bitpocket
  '';

  postFixup = ''
    wrapProgram $out/bin/bitpocket --prefix PATH : \
      ${lib.makeBinPath [ locale hostname mount openssh rsync ]}
  '';

  meta = {
    description = "Small but smart script that does 2-way directory synchronization";
    home = https://github.com/sickill/bitpocket;
    license = lib.licenses.mit;
  };
}
