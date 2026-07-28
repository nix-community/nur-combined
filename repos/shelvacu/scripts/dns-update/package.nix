{
  lib,
  vacuRoot,
  vacuWrappedSops,
  dnsEval,
  makeVacuPythonScript,
  writeText,
  linkFarmFromDrvs,
  runCommand,
  bind,
}:
let
  inherit (dnsEval) config;
  dnsZones = lib.pipe config.vacu.dns [
    (lib.mapAttrsToList (name: zoneConfig: writeText "${name}.zone" (toString zoneConfig)))
    (linkFarmFromDrvs "vacu-dns-zone-files")
  ];
  dnsCheck = runCommand "dns-named-checkzone" { } ''
    set -euo pipefail
    for zonefile in ${dnsZones}/*.zone; do
      zoneName="''${zonefile%.zone}"
      zoneName="$(basename -- "$zoneName")"
      echo "Checking $zoneName ($zonefile)"
      checkzoneOutputFn="$(mktemp)"
      cmd=(
        ${bind}/bin/named-checkzone
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
in
makeVacuPythonScript {
  name = "dns-update";
  src = ./script.py;
  libraries = [ "dnspython" ];
  fakeInputs = [ dnsCheck ];
  data = {
    sops_bin = lib.getExe vacuWrappedSops;
    dns_secrets_file = /${vacuRoot}/secrets/misc/cloudns.json;
    config = config.vacu.dns;
  };
  typeCheckingMode = "standard";
  passthru = { inherit dnsZones dnsCheck; };
}
