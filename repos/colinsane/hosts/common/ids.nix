# TODO: migrate to nixpkgs `config.ids.uids`
# - note that nixpkgs' `config.ids.uids` is strictly a database: it doesn't set anything by default
#   whereas our impl sets the gid/uid of the user/group specified if they exist.
{ ... }:

{
  # legacy servo users, some are inconvenient to migrate
  sane.ids.dhcpcd.gid = 991;
  sane.ids.dhcpcd.uid = 992;
  sane.ids.gitea.gid = 993;
  sane.ids.git.uid = 994;
  sane.ids.jellyfin.gid = 994;
  sane.ids.pleroma.gid = 995;
  sane.ids.jellyfin.uid = 996;
  sane.ids.acme.gid = 996;
  sane.ids.pleroma.uid = 997;
  sane.ids.acme.uid = 998;
  sane.ids.matrix-appservice-irc.uid = 993;
  sane.ids.matrix-appservice-irc.gid = 992;

  # greetd (used by sway)
  sane.ids.greeter.uid = 999;
  sane.ids.greeter.gid = 999;

  # new servo users
  sane.ids.freshrss.uid = 2401;
  sane.ids.freshrss.gid = 2401;
  sane.ids.mediawiki.uid = 2402;
  sane.ids.signald.uid = 2403;
  sane.ids.signald.gid = 2403;
  sane.ids.mautrix-signal.uid = 2404;
  sane.ids.mautrix-signal.gid = 2404;
  sane.ids.navidrome.uid = 2405;
  sane.ids.navidrome.gid = 2405;
  sane.ids.calibre-web.uid = 2406;
  sane.ids.calibre-web.gid = 2406;
  sane.ids.komga.uid = 2407;
  sane.ids.komga.gid = 2407;
  sane.ids.lemmy.uid = 2408;
  sane.ids.lemmy.gid = 2408;

  sane.ids.colin.uid = 1000;
  sane.ids.guest.uid = 1100;

  # found on all hosts
  sane.ids.sshd.uid = 2001;  # 997
  sane.ids.sshd.gid = 2001;  # 997
  sane.ids.polkituser.gid = 2002;  # 998
  sane.ids.systemd-coredump.gid = 2003;  # 996  # 2023/02/12-2023/02/28: upstream temporarily specified this as 151
  sane.ids.nscd.uid = 2004;
  sane.ids.nscd.gid = 2004;
  sane.ids.systemd-oom.uid = 2005;
  sane.ids.systemd-oom.gid = 2005;
  sane.ids.wireshark.gid = 2006;

  # found on graphical hosts
  sane.ids.nm-iodine.uid = 2101;  # desko/moby/lappy

  # found on desko host
  # from services.usbmuxd
  sane.ids.usbmux.uid = 2204;
  sane.ids.usbmux.gid = 2204;


  # originally found on moby host
  # gnome core-shell
  sane.ids.avahi.uid = 2304;
  sane.ids.avahi.gid = 2304;
  sane.ids.colord.uid = 2305;
  sane.ids.colord.gid = 2305;
  sane.ids.geoclue.uid = 2306;
  sane.ids.geoclue.gid = 2306;
  # gnome core-os-services
  sane.ids.rtkit.uid = 2307;
  sane.ids.rtkit.gid = 2307;
  # phosh
  sane.ids.feedbackd.gid = 2308;
}
