{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rezmoss-cloud-provider-ip-addresses";
  version = "2026.09.14-unstable-2026-09-14";

  outputs = [
    "out"
    "json"
    "merged"
    "txt"
  ];

  src = fetchFromGitHub {
    owner = "rezmoss";
    repo = "cloud-provider-ip-addresses";
    rev = "6d60934c5afda33a853d94b0da5bc47044df2ac4";
    hash = "sha256-4VwL6vmv1Z69Iyq40nKnrIl1+LnWglQEe9w3xYFliZE=";
  };

  installPhase = ''
    runHook preInstall

    rm -r ./changes
    mkdir $out
    cp -r ./*/ ./summary.json $out/

    mkdir $json $merged $txt
    find . -mindepth 2 -maxdepth 2 \( -name '*_ips.json' -o -name '*_meta.json' \) -not -path './all_providers/*' -exec cp --parents --target-directory=$json {} +
    cp ./summary.json $json/
    find . -mindepth 2 -name '*_merged_v[46].txt' -exec cp --parents --target-directory=$merged {} +
    find . -mindepth 2 -name '*.txt' -exec cp --parents --target-directory=$txt {} +

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    json =
      runCommand "test-rezmoss-cloud-provider-ip-addresses-json"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ jq ];
        }
        ''
          readarray -t files < <(find ${finalAttrs.finalPackage.json} -name '*_meta.json')
          [ "''${#files[@]}" -gt 0 ]
          jq --exit-status . "''${files[@]}" ${finalAttrs.finalPackage.json}/summary.json >/dev/null
          jq --exit-status '.[0].ip_address' ${finalAttrs.finalPackage.json}/github/github_ips.json >/dev/null
          touch $out
        '';

    cidrs =
      runCommand "test-rezmoss-cloud-provider-ip-addresses-cidrs"
        {
          __structuredAttrs = true;
        }
        ''
          for f in aws/aws_ips.txt github/github_ips.txt googlecloud/googlecloud_ips.txt; do
            [ -s "${finalAttrs.finalPackage.txt}/$f" ]
          done
          [ -s "${finalAttrs.finalPackage.merged}/github/services/hooks/github_hooks_ips_merged_v4.txt" ]
          if grep --recursive --invert-match --extended-regexp '^[0-9a-f:.]+(/[0-9]+)?$' ${finalAttrs.finalPackage.txt}; then
            exit 1
          fi
          touch $out
        '';
  };

  meta = {
    description = "Daily IP ranges for 60+ cloud providers, CDNs, and crawlers";
    homepage = "https://github.com/rezmoss/cloud-provider-ip-addresses";
    license = lib.licenses.cc0;
    platforms = lib.platforms.all;
  };
})
