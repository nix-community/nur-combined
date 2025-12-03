# TODO: migrate to nixpkgs `config.ids.uids`
# - note that nixpkgs' `config.ids.uids` is strictly a database: it doesn't set anything by default
#   whereas our impl sets the gid/uid of the user/group specified if they exist.
{ ... }:

{
  # partially supported in nixpkgs  <repo:nixos/nixpkgs:nixos/modules/misc/ids.nix>
  sane.ids.networkmanager.uid = 57;  #< nixpkgs unofficially reserves this, to match networkmanager's gid
  sane.ids.mediatomb.uid = 187;  # <repo:nixos/nixpkgs:nixos/modules/misc/ids.nix>

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

  # greetd (legacy)
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
  sane.ids.pict-rs.uid = 2409;
  sane.ids.pict-rs.gid = 2409;
  sane.ids.sftpgo.uid = 2410;
  sane.ids.sftpgo.gid = 2410;
  sane.ids.hickory-dns.uid = 2411;  #< previously "trust-dns"
  sane.ids.hickory-dns.gid = 2411;  #< previously "trust-dns"
  sane.ids.export.gid = 2412;
  sane.ids.nfsuser.uid = 2413;
  sane.ids.media.gid = 2414;
  sane.ids.ntfy-sh.uid = 2415;
  sane.ids.ntfy-sh.gid = 2415;
  sane.ids.monero.uid = 2416;
  sane.ids.monero.gid = 2416;
  sane.ids.slskd.uid = 2417;
  sane.ids.slskd.gid = 2417;
  sane.ids.bitcoind-mainnet.uid = 2418;
  sane.ids.bitcoind-mainnet.gid = 2418;
  sane.ids.clightning.uid = 2419;
  sane.ids.clightning.gid = 2419;
  sane.ids.nix-serve.uid = 2420;
  sane.ids.nix-serve.gid = 2420;
  sane.ids.plugdev.gid = 2421;
  sane.ids.ollama.uid = 2422;
  sane.ids.ollama.gid = 2422;
  sane.ids.bitmagnet.uid = 2423;
  sane.ids.bitmagnet.gid = 2423;
  sane.ids.anubis.uid = 2424;
  sane.ids.anubis.gid = 2424;
  sane.ids.shelvacu.uid = 5431;

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
  sane.ids.nixremote.uid = 2007;
  sane.ids.nixremote.gid = 2007;
  sane.ids.unbound.uid = 2008;
  sane.ids.unbound.gid = 2008;
  sane.ids.resolvconf.gid = 2009;
  sane.ids.smartd.uid = 2010;
  sane.ids.smartd.gid = 2010;
  sane.ids.radicale.uid = 2011;
  sane.ids.radicale.gid = 2011;
  sane.ids.named.uid = 2012;
  sane.ids.named.gid = 2012;
  sane.ids.lpadmin.gid = 2013;
  sane.ids.knot-resolver.uid = 2014;
  sane.ids.knot-resolver.gid = 2014;

  # found on graphical hosts
  sane.ids.nm-iodine.uid = 2101;  # desko/moby/lappy
  sane.ids.seat.gid = 2102;

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

  # new moby users
  sane.ids.eg25-control.uid = 2309;
  sane.ids.eg25-control.gid = 2309;
}
