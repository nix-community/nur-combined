{ fetchCrate
, jq
, lib
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "iptables_exporter";
  version = "0.4.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-hGXBGKVV5Iak0SCon3QlffKDgo2djLLWbfHI06QN+Dc=";
  };
  cargoHash = "sha256-6MdOzHLPt6KJe3KuwKvsO4FuONjYFxQYu6VDQuC44DA=";

  patches = [ ./resources/iptables_exporter_no-git.patch ];

  postPatch = ''
    git_hash=$(${jq}/bin/jq --raw-output '.git.sha1' '.cargo_vcs_info.json')
    substituteInPlace build.rs --replace-fail '@git_hash@' "$git_hash"
  '';

  meta = {
    description = "Prometheus exporter for iptables";
    homepage = "https://github.com/kbknapp/iptables_exporter";
    license = with lib.licenses; [ afl20 mit ];
    mainProgram = "iptables_exporter";
  };
}
