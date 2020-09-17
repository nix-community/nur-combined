{ stdenv, fetchgit }:
stdenv.mkDerivation {
  name = "mailbox";

  src = fetchgit {
    url = "https://github.com/LukeSmithxyz/voidrice";
    rev = "426979aa7250e1d09b1f6044020d3f2b538425a9";
    sha256 = "0pjg3wf4x2r1mzvljjfm42fpc5y6131n0a7wvsikpr9gdhcv9h30";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp .local/bin/statusbar/mailbox $out/bin/mailbox
  '';
}
