{
  writers,
  config,
  lib,
  vacuRoot,
  wrappedSops,
  dnsCheck,
}:
let
  pythEscape = x: builtins.replaceStrings [ ''"'' "\n" "\\" ] [ ''\"'' "\\n" "\\\\" ] (toString x);
  pythonScript = builtins.replaceStrings [ "@sops@" "@dns_secrets_file@" "@data@" ] (map pythEscape [
    (lib.getExe wrappedSops)
    /${vacuRoot}/secrets/misc/cloudns.json
    (builtins.toJSON config.vacu.dns)
  ]) (builtins.readFile ./script.py);
  libraries = pyPkgs: with pyPkgs; [
    httpx
    dnspython
  ];
in
writers.writePython3Bin "dns-update" {
  inherit libraries;
  check = "# this comment serves to create an artificial build dependency on ${dnsCheck}";
} pythonScript
