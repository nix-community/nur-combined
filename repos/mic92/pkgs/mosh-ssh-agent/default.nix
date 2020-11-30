{ stdenv, mosh, fetchFromGitHub, fetchpatch }:

mosh.overrideAttrs (old: {
  name = "mosh-ssh-agent-2020-07-22";

  # TODO: incoperate https://github.com/mobile-shell/mosh/pull/1104
  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "mosh";
    rev = "48d106f832d207cce2f7ef6238204fc073dac02e";
    sha256 = "0nyfz23nsk5pgmypwpyx35bc6j6b4ymxv7wwmrfzdrkml73n2c0m";
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
