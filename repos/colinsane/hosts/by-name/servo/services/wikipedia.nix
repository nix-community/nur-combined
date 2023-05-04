# docs: <https://nixos.wiki/wiki/MediaWiki>
{ config, lib, ... }:

# XXX: working to host wikipedia with kiwix instead of mediawiki
# mediawiki does more than i need and isn't obviously superior in any way
# except that the dumps are more frequent/up-to-date.
lib.mkIf false
{
  sops.secrets."mediawiki_pw" = {
    owner = config.users.users.mediawiki.name;
  };

  services.mediawiki.enable = true;
  services.mediawiki.name = "Uninsane Wiki";
  services.mediawiki.passwordFile = config.sops.secrets.mediawiki_pw.path;
  services.mediawiki.extraConfig = ''
    # Disable anonymous editing
    $wgGroupPermissions['*']['edit'] = false;
  '';
  services.mediawiki.virtualHost.listen = [
    {
      ip = "127.0.0.1";
      port = 8013;
      ssl = false;
    }
  ];
  services.mediawiki.virtualHost.hostName = "w.uninsane.org";
  services.mediawiki.virtualHost.adminAddr = "admin+mediawiki@uninsane.org";
  # services.mediawiki.extensions = TODO: wikipedia sync extension?
}
