{ stdenv, callPackage, buildEnv, isync, pass, msmtp, notmuch, libnotify }:
with stdenv.lib;

let
  mutt-wizard = callPackage ./mutt-wizard.nix { };
  neomutt = callPackage ./neomutt_wrapped.nix { };
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
    mutt-wizard
  ];

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/mutt-wizard";
    description = "Neomutt + Mutt-Wizard: A system for automatically configuring mutt and isync with a simple interface and safe passwords";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
