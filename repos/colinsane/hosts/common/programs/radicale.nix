# radicale is a CalDAV/CardDAV server.
# it receives http queries from calendar or contacts managers
# and translates that into reads/writes of vcard .vcf files in some persisted folder
#
# admin interface: <http://localhost:5232>
# enter username: "colin", password: (empty)
#
# settings: <https://radicale.org/v3.html#configuration>
#
# TODO: this setup allows access to *anything* on the machine with net access;
#   but i don't really want e.g. my web browser to know all my personal contacts:
#   maybe run this in a net namespace? `JoinsNamespaceOf=evolution` (or vice versa)?
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.radicale;
in
{
  sane.programs.radicale = {
    # sane.programs.radicale is a sentinel for the nixpkgs' radicale service,
    # which is well-sandboxed, and there's no benefit to having it on PATH
    packageUnwrapped = null;
  };

  services.radicale = lib.mkIf cfg.enabled {
    enable = true;
    package = pkgs.radicale.overrideAttrs (upstream: {
      version = lib.warnIf (lib.versionOlder "3.3.1" upstream.version) "radicale outdated: remove src override" "3.3.1-unstable-2024-12-14";
      src = pkgs.fetchFromGitHub {
        owner = "Kozea";
        repo = "Radicale";
        rev = "778f56cc4d7b828af6e2e472f2e7898db72dca22";
        hash = "sha256-Oy6LDI+gvAqwR5XRz7JmRWI7KrAUYTOzHfvJsBRyVmU=";
      };
    });
    settings.storage.type = "multifilesystem_nolock";
    settings.storage.use_cache_subfolder_for_history = true;  #< requires radicale > 3.3.1
    settings.storage.use_cache_subfolder_for_item = true;
    settings.storage.use_cache_subfolder_for_synctoken = true;
    # settings.storage.filesystem_cache_folder = "/var/lib/radicale/cache";
    # settings.storage.filesystem_folder = "/path/to/storage"
    # settings.auth.type = "none";  # default: none
  };

  # TODO: service is considered 'up' too early: we should wait, and notify once the http port is bound/listening
  systemd.services.radicale = lib.mkIf cfg.enabled {
    serviceConfig.User = lib.mkForce "colin";
    # serviceConfig.Group = "users";
    serviceConfig.ReadWritePaths = [
      "/mnt/persist/private/home/colin/knowledge/social/contacts/db"
    ];
    unitConfig.RequiresMountsFor = [
      "/mnt/persist/private/home/colin/knowledge/social/contacts/db"
    ];
  };

  sane.fs = lib.optionals cfg.enabled {
    "/var/lib/radicale/collections/collection-root/colin/pkm".symlink.target = "/mnt/persist/private/home/colin/knowledge/social/contacts/db";
  };
}
