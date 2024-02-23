# how to update wikipedia snapshot:
# - browse for later snapshots:
#   - <https://mirror.accum.se/mirror/wikimedia.org/other/kiwix/zim/wikipedia>
# - DL directly, or via rsync (resumable):
#   - `rsync --progress --append-verify rsync://mirror.accum.se/mirror/wikimedia.org/other/kiwix/zim/wikipedia/wikipedia_en_all_maxi_2022-05.zim .`

{ ... }:
{
  sane.persist.sys.byStore.ext = [
    { user = "colin"; group = "users"; path = "/var/lib/kiwix"; method = "bind"; }
  ];

  sane.services.kiwix-serve = {
    enable = true;
    port = 8013;
    zimPaths = [ "/var/lib/kiwix/wikipedia_en_all_maxi_2023-11.zim" ];
  };

  services.nginx.virtualHosts."w.uninsane.org" = {
    forceSSL = true;
    enableACME = true;
    # inherit kTLS;
    locations."/".proxyPass = "http://127.0.0.1:8013";
  };

  sane.dns.zones."uninsane.org".inet.CNAME."w" = "native";
}
