{ stdenv, pkgs, lib }:
with lib;
let
  name = "microvm-rebuild";
  pname = "microvm-rebuild";
  version = "0.0.1";
  meta = {
    description =
      "A simple shell wrapper to make rebuilding of microvms easier";
    platforms = platforms.unix;
  };

  microvm-rebuild-wrapped = pkgs.writeShellScriptBin "microvm-rebuild" ''

    if ! [[ $SEVERITY_TOLERANCE =~ ^[0-9]+(\.[0-9]+)?$ ]]; 
       then echo "ERROR: First parameter is not a number!" >&2; exit 1 
    fi

    # Assume default is correctly set - TODO: resolve clear issues with this.
    nix build

    # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-store-diff-closures.html
    # https://discourse.nixos.org/t/viewing-differences-between-flake-revisions/18768


    # THIS MIGHT BE BETTER: nix show-derivation -r . | jq -r '.[] | select(.inputDrvs) | .inputDrvs | to_entries | .[].key' | sort | uniq | xargs vulnix -R --json 

    # The below is a work in progress to correct some bad patterns.
    VULNS=$(vulnix -w ./.vulnix/allowlist.toml -R result --json)
    VULN_COUNT=$(echo $VULNS | jq --arg sev $SEVERITY_TOLERANCE '[.[] | select(.cvssv3_basescore | to_entries | .[].value | . >= ($sev | tonumber))] | length')

    if [ $VULN_COUNT -eq 0 ]; then
        echo "Detected no significant vulnerabilities. Heck yeah!"
        exit 0
    else
        echo ""
        echo "Detected $VULN_COUNT derivations with a possible CVE greater than or equal to severity $1!"
        echo "Note that these should be checked for reachability and/or build-time ephemerality and allowlisted if determined to be low/incorrect risk"
        echo ""

        echo "Run the following command to identify and remediate vulnerabilities:"
        echo ""
        echo "vulnix -w ./.vulnix/allowlist.toml -R result --json | jq -C --arg sev $SEVERITY_TOLERANCE '[.[] | select(.cvssv3_basescore | to_entries | .[].value | . >= (\$sev | tonumber))] | length' | less -R"
        echo "OR to write to a local file to review:"
        echo "vulnix -w ./.vulnix/allowlist.toml -R result --json | jq --arg sev $SEVERITY_TOLERANCE '[.[] | select(.cvssv3_basescore | to_entries | .[].value | . >= (\$sev | tonumber))]' > vulns.json"
        exit 1
    fi;
  '';

  phases = [ "installPhase" "fixupPhase" ];

in stdenv.mkDerivation {
  inherit name pname version meta phases;

  buildInputs = [ microvm-rebuild-wrapped ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${microvm-rebuild-wrapped}/bin/microvm-rebuild $out/bin
  '';
}
