{ stdenv, fetchgit }:
stdenv.mkDerivation {
  name = "mailbox";

  src = fetchgit {
    url = "https://github.com/LukeSmithxyz/voidrice";
    rev = "3936ffe5e2b494e65fc5a44927fe67311c8c51ae";
    sha256 = "1casynk0fvjfz9jv8hdgi7dpmq26cz6hmsr028w65rj993m33cfx";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp .local/bin/statusbar/mailbox $out/bin/mailbox
  '';
}
