{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "duyhenryer-cloud-ip-ranges";
  version = "0-unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "duyhenryer";
    repo = "cloud-ip-ranges";
    rev = "73ecd6a80b3cf287fa061e9c273c6e1e074e4054";
    hash = "sha256-B1n2quYLAO1vV6fQfQ+nwvhSPt+apbJOGqAQqErRlZE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ./data/* ./all-ipv4.txt ./all-ipv6.txt $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    json =
      runCommand "test-duyhenryer-cloud-ip-ranges-json"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ jq ];
        }
        ''
          readarray -t files < <(find ${finalAttrs.finalPackage} -name '*.json')
          [ "''${#files[@]}" -gt 0 ]
          jq --exit-status . "''${files[@]}" >/dev/null
          touch $out
        '';

    cidrs =
      runCommand "test-duyhenryer-cloud-ip-ranges-cidrs"
        {
          __structuredAttrs = true;
        }
        ''
          for f in all-ipv4.txt all-ipv6.txt aws/ipv4.txt gcp/ipv4.txt github/ipv4.txt; do
            [ -s "${finalAttrs.finalPackage}/$f" ]
          done
          if grep --recursive --include='*.txt' --invert-match --extended-regexp '^([0-9a-f:.]+(/[0-9]+)?|null)$' ${finalAttrs.finalPackage}; then
            exit 1
          fi
          touch $out
        '';
  };

  meta = {
    description = "Raw IP range feeds from AWS, GCP, GitHub, Cloudflare, and other cloud providers";
    homepage = "https://github.com/duyhenryer/cloud-ip-ranges";
    license = lib.licenses.cc0;
    platforms = lib.platforms.all;
  };
})
