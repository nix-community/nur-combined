{ stdenv, callPackage, buildEnv, makeDesktopItem, isync, pass, msmtp, notmuch, libnotify }:
with stdenv.lib;

let
  pname = "larbs-mail";

  mutt-wizard = callPackage ./mutt-wizard.nix { };
  neomutt = callPackage ./neomutt_wrapped.nix { };
  icon = ./icon.png;

  desktopItem = makeDesktopItem {
    name = pname;
    genericName = "Mail Client";
    comment = "Neomutt configuration by Luke Smith";
    exec = "${neomutt}/bin/neomutt";
    icon = icon;
    desktopName = pname;
    mimeType = "x-scheme-handler/mailto;message/rfc822";
    categories = "Network;Email";
    terminal = "true";
  };
in
buildEnv {
  name = pname;

  paths = [
    neomutt
    isync
    pass
    msmtp
    notmuch
    libnotify
    mutt-wizard
  ];

  postBuild = ''
    mkdir -p $out/opt/larbs-mail
    mkdir -p $out/share/pixmaps
    mv * $out/opt/larbs-mail

    ln -s "${desktopItem}/share/applications" $out/share
  '';

  meta = {
    homepage = "https://github.com/LukeSmithXYZ/mutt-wizard";
    description = "Neomutt + Mutt-Wizard: A system for automatically configuring mutt and isync with a simple interface and safe passwords";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
