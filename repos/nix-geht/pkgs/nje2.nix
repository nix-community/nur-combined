{
  lib,
  stdenv,
  fetchFromGitHub,
  sendmailPath ? "/run/wrappers/bin/sendmail",
  ...
}:
stdenv.mkDerivation rec {
  pname = "nje-2";
  version = "unstable-2401012317";

  src = fetchFromGitHub {
    owner = "vifino";
    repo = "NJE-II";
    rev = "b1399fabe709aea91ed8a915a8489c8fd6ce630d";
    hash = "sha256-2/XK/I5qPZ+pcBdRf8dbx8gX6S1f3Cyp9xoOxaPAlOQ=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "/usr/local/nje/etc/nje.cf" "/etc/nje.cf" \
      --replace-fail "/usr/local/nje/etc/nje.pid" "/run/nje2/nje.pid" \
      --replace-fail "/usr/local/nje/var/spool/bitnet/" "/var/spool/bitnet/"

    substituteInPlace mailify.c mailify.sh \
      --replace-fail "/usr/lib/sendmail" "${sendmailPath}"

    substituteInPlace mailify.sh bmail.sh \
      --replace-fail "/usr/tmp" "/var/tmp"
  '';

  makeFlags = ["PREFIX=$(out)"];
  installTargets = "install_nouid";

  env.NIX_CFLAGS_COMPILE = "-Wno-int-conversion";

  meta = with lib; {
    description = "'RSCS emulator' for UNIX";
    homepage = "https://github.com/vifino/NJE-2";
    license = licenses.publicDomain; # Is this right?
    platforms = platforms.unix;
    maintainers = with maintainers; [vifino];
  };
}
