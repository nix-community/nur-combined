{ allInputs, lib, vacuRoot, ... }:
{
  perSystem = { config, plainConfig, pkgs, ... }:
  let
    dnsEval = plainConfig.extendModules { modules = [ /${vacuRoot}/dns ]; };
  in
  rec {
    packages = {
      dns = (import /${vacuRoot}/scripts/dns {
        inherit pkgs lib vacuRoot;
        inputs = allInputs;
        inherit (dnsEval) config;
        inherit (config.packages) wrappedSops;
      }).overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ checks.dns ];
      });
      dnsZones = lib.pipe dnsEval.config.vacu.dns [
        (lib.mapAttrsToList (name: config: pkgs.writeText "${name}.zone" (toString config)))
        (pkgs.linkFarmFromDrvs "vacu-dns-zone-files")
      ];
    };

    checks.dns = pkgs.runCommand "dns-named-checkzone" { } ''
      set -euo pipefail
      for zonefile in ${packages.dnsZones}/*.zone; do
        zoneName="''${zonefile%.zone}"
        zoneName="$(basename -- "$zoneName")"
        echo "Checking $zoneName ($zonefile)"
        checkzoneOutputFn="$(mktemp)"
        cmd=(
          ${pkgs.bind}/bin/named-checkzone
          # "performs post-load zone integrity checks"; tries to network if left as default
          -i local
          # "performs check-names checks"
          -k fail
          # "whether MX records should be checked to see if they are addresses"
          -m fail
          # "checks whether a MX record refers to a CNAME."
          -M fail
          # "whether NS records should be checked to see if they are addresses."
          -n fail
          # "checks for records that are treated as different by DNSSEC but are semantically equal in plain DNS"
          -r fail
          # "checks whether an SRV record refers to a CNAME."
          -S fail
          "$zoneName"
          "$zonefile"
        )
        "''${cmd[@]}" 2>&1 | tee "$checkzoneOutputFn"
        # no matter how much you tell named to fail instead of warn, it will still warn sometimes
        printf -v checkzoneExpectedOutput 'zone %s/IN: loaded serial 1970010101\nOK' "$zoneName"
        checkzoneOutput="$(<"$checkzoneOutputFn")"
        if [[ $checkzoneOutput != "$checkzoneExpectedOutput" ]]; then
          echo "output was not as expected" >&2
          exit 1
        fi
      done
      touch $out
    '';
  };
}
