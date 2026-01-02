{
  pkgs,
  config,
  vaculib,
  vacuModules,
  ...
}:
let
  mainDir = "/propdata/copyparty-share";
  rootPkg = pkgs.callPackage ./root-derivation.nix { };
  cfg = config.vacu.copyparties.two_e14;
in
{
  imports = [ vacuModules.copyparty ];
  system.activationScripts.migrate-copyparty = {
    deps = [
      "users"
      "groups"
      "createPersistentStorageDirs"
    ];
    text = ''
      if [[ -d /var/lib/copyparty-share && ! -e ${cfg.stateDir} ]]; then
        chown -R ${cfg.mainUser}:${cfg.mainGroup} /var/lib/copyparty-share
        mv --no-clobber -T /var/lib/copyparty-share ${cfg.stateDir}
      fi
    '';
  };
  vacu.copyparties.two_e14 = {
    enable = true;
    domain = "2e14.sv.mt";
    oauthInstance = "two_e14";
    globalConfig = ''
      df: 1T
      ipu: 10.78.76.0/22=lan
      name: 2e14
      shr: /s
      shr-adm: shelvacu
    '';
    extraConfig = ''
      [accounts]
        # shelvacu: +7GvyoieOAbzXd3guJru24uAxHzZ4tHYL
        shelvacu-fw-obsidian: +AC4eJ9Ztd3Tb2sO6zi9KvfhUeE-UhrWf
        shelvacu-pixel9pro-obsidian: +_68si1x8KkbAumjZMekTg6G7mDkvnCZX
        # lan is added to the list as a workaround until https://github.com/9001/copyparty/issues/959 is fixed
        lan: +aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

      [groups]
        shelvacu-obsidian: shelvacu-fw-obsidian, shelvacu-pixel9pro-obsidian
        not-people: lan, shelvacu-fw-obsidian, shelvacu-pixel9pro-obsidian
        general_access:
    '';
    volumes = {
      "/" = {
        hostPath = rootPkg;
        access = "r: @acct";
      };
      "/archive" = {
        hostPath = "/propdata/archive";
        access = "r: shelvacu";
        bind.readOnly = true;
      };
      "/chaosbox" = {
        hostPath = "${mainDir}/chaosbox";
        access = ''
          rwm: @general_access,lan
          A: shelvacu
        '';
        flags.dots = true;
      };
      "/media" = {
        hostPath = "/propdata/media";
        access = "r: @general_access,lan";
        flags.xdev = false;
        flags.xvol = true;
        bind.readOnly = true;
      };
      "/ppl" = {
        hostPath = vaculib.path ./ppl-folder;
        access = "r: @acct";
      };
      "/ppl/\${u%-not-people}" = {
        hostPath = "${mainDir}/ppl/\${u}";
        access = "rwmd.: \${u}";
      };
      "/ppl/shelvacu/obsidian" = {
        hostPath = "${mainDir}/ppl/shelvacu/obsidian";
        access = ''
          rwmd.: @shelvacu-obsidian
          A: shelvacu
        '';
      };
      "/general_access" = {
        hostPath = pkgs.emptyDirectory;
        access = "r: @general_access";
      };
    };
  };
  users.groups.media.members = [ "copyparty-two_e14" ];
  systemd.tmpfiles.settings."10-whatever" =
    let
      userOnly = vaculib.accessModeStr { user = "all"; };
    in
    {
      "${mainDir}/root".d = {
        user = "copyparty-share";
        group = "copyparty-share";
        mode = userOnly;
      };
      "${mainDir}/chaosbox".d = {
        user = "copyparty-share";
        group = "copyparty-share";
        mode = userOnly;
      };

      "/propdata/media/readme.md"."L".argument = vaculib.path ./media-readme.md;
    };
  services.caddy.virtualHosts."2e14.t2d.lan" = {
    vacu.hsts = false;
    extraConfig = ''
      tls /var/lib/caddy/2e14.t2d.lan.crt /var/lib/caddy/2e14.t2d.lan.key
      reverse_proxy unix/${cfg.socketPath} {
        header_up -X-Client-Auth-Fingerprint
        header_up -X-Forwarded-User
        header_up -X-Forwarded-Groups
        header_up -X-Forwarded-Email
        header_up -X-Forwarded-Preferred-Username
        header_up -X-Auth-*
      }
    '';
  };
  vacu.oauthProxy.instances.two_e14 = {
    displayName = "2e14 (copyparty)";
    kanidmMembers = [ "general_access" ];
  };
  services.kanidm.provision.systems.oauth2.two_e14 = {
    imageFile = "${pkgs.srcOnly cfg.package}/docs/logo.svg";
    supplementaryScopeMaps.general_access = [ "general_access" ];
  };
  services.caddy.virtualHosts."2e14.sv.mt".vacu.hsts = "preload";
  services.caddy.virtualHosts."copyparty.sv.mt" = {
    vacu.hsts = "preload";
    serverAliases = [
      "copy.sv.mt"
      "copyparty.sv.mt"
      "files.sv.mt"
      "f.sv.mt"
      "copy.shelvacu.com"
      "copyparty.shelvacu.com"
      "files.shelvacu.com"
    ];
    extraConfig = ''redir * https://2e14.sv.mt{uri}'';
  };
}
