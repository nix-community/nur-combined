{ stdenv, mosh, fetchFromGitHub, fetchpatch }:

mosh.overrideAttrs (old: {
  name = "mosh-ssh-agent-2020-04-29";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mosh";
    rev = "89b08b4ce160d20e2a7f72e5b6995865ff920014";
    sha256 = "0a11059r5030az086p5c3gilfm6cswsssjgz2xlv9sb7z2sblb7y";
  };

  patches = [
    ./ssh_path.patch
  ];

  meta = with stdenv.lib; {
    description = "Mosh fork with ssh-agent support";
    homepage = https://github.com/Mic92/mosh;
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.unix;
  };
})
