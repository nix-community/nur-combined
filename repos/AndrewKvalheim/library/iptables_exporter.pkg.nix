{ fetchCrate
, jq
, lib
, rustPlatform
, versionCheckHook
}:

let
  inherit (lib) getExe licenses;
in
rustPlatform.buildRustPackage (iptables_exporter: {
  pname = "iptables_exporter";
  version = "0.4.0";
  meta = {
    description = "Prometheus exporter for iptables";
    homepage = "https://github.com/kbknapp/iptables_exporter";
    license = with licenses; [ afl20 mit ];
    mainProgram = "iptables_exporter";
  };

  src = fetchCrate {
    inherit (iptables_exporter) pname version;
    hash = "sha256-hGXBGKVV5Iak0SCon3QlffKDgo2djLLWbfHI06QN+Dc=";
  };

  patches = [ ./assets/iptables_exporter_no-git.patch ];
  postPatch = ''
    git_hash="$(${getExe jq} --raw-output '.git.sha1' '.cargo_vcs_info.json')"
    substituteInPlace 'build.rs' \
      --replace-fail '@git_hash@' "$git_hash"
  '';

  cargoHash = "sha256-emqF0cGyIld6r6G1rL6gou4p8ERYs61kqnxopV2LxL8=";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
