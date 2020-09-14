{ stdenv, callPackage, buildEnv, neomutt, isync, pass, msmtp, notmuch, libnotify }:
with stdenv.lib;
let
  mutt-wizard = callPackage ../mutt-wizard { };
in
buildEnv {
  name = "larbs-mail";
  paths = [
    neomutt
    isync
    pass
    msmtp
    notmuch
    libnotify
  ];

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/mutt-wizard";
    description = "A system for automatically configuring mutt and isync with a simple interface and safe passwords";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
