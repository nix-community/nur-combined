{ lib, pkgs, config, ... }:
{
  options.secrets = {
    keys = lib.mkOption {
      type = lib.types.listOf lib.types.unspecified;
      default = [];
      description = "Keys to upload to server";
    };
    location = lib.mkOption {
      type = lib.types.path;
      default = "/var/secrets";
      description = "Location where to put the keys";
    };
    # Read-only variables
    fullPaths = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = builtins.listToAttrs
        (map (v: { name = v.dest; value = "${config.secrets.location}/${v.dest}"; }) config.secrets.keys);
      readOnly = true;
      description = "set of full paths to secrets";
    };
  };

  config = let
    location = config.secrets.location;
    keys = config.secrets.keys;
    empty = pkgs.runCommand "empty" { preferLocalBuild = true; } "mkdir -p $out && touch $out/done";
    dumpKey = v: ''
        mkdir -p secrets/$(dirname ${v.dest})
        echo -n ${lib.strings.escapeShellArg v.text} > secrets/${v.dest}
        cat >> mods <<EOF
        ${v.user or "root"} ${v.group or "root"} ${v.permissions or "0600"} secrets/${v.dest}
        EOF
        '';
    secrets = pkgs.runCommand "secrets.tar" {} ''
      touch mods
      tar --format=ustar --mtime='1970-01-01' -P --transform="s@${empty}@secrets@" -cf $out ${empty}/done
      ${builtins.concatStringsSep "\n" (map dumpKey keys)}
      cat mods | while read u g p k; do
      tar --format=ustar --mtime='1970-01-01' --owner="$u" --group="$g" --mode="$p" --append -f $out "$k"
      done
      '';
  in lib.mkIf (builtins.length keys > 0) {
    system.activationScripts.secrets = {
      deps = [ "users" "wrappers" ];
      text = ''
        install -m0750 -o root -g keys -d ${location}
        if [ -f /run/keys/secrets.tar ]; then
          if [ ! -f ${location}/currentSecrets ] || ! sha512sum -c --status "${location}/currentSecrets"; then
            echo "rebuilding secrets"
            TMP=$(${pkgs.coreutils}/bin/mktemp -d)
            if [ -n "$TMP" ]; then
              install -m0750 -o root -g keys -d $TMP
              ${pkgs.gnutar}/bin/tar --strip-components 1 -C $TMP -xf /run/keys/secrets.tar
              sha512sum /run/keys/secrets.tar > $TMP/currentSecrets
              find $TMP -type d -exec chown root:keys {} \; -exec chmod o-rx {} \;
              ${pkgs.rsync}/bin/rsync -O -c -av --delete $TMP/ ${location}
              rm -rf $TMP
            fi
          fi
        fi
        '';
    };
    deployment.keys."secrets.tar" = {
      permissions = "0400";
      # keyFile below is not evaluated at build time by nixops, so the
      # `secrets` path doesn’t necessarily exist when uploading the
      # keys, and nixops is unhappy.
      user = "root${builtins.substring 10000 1 secrets}";
      group = "root";
      keyFile = "${secrets}";
    };
  };
}
