{
  fetchFromGitHub,
  buildGoModule,
  writeScript,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = "drone-runner-docker";
    inherit (source) rev sha256;
  };
in
  buildGoModule rec {
    pname = "drone-runner-docker";
    version = source.date;
    inherit src;
    vendorSha256 = builtins.readFile ./goVendor.hash;
    proxyVendor = true;
    meta = {
      description = "Docker executor for drone";
      license = [
        {
          free = false;
          fullName = "PolyForm Small Business License 1.0.0";
          redistributable = true;
          spdxId = "PolyForm-Small-Business-1.0.0";
          url = "https://spdx.org/licenses/PolyForm-Small-Business-1.0.0.html";
        }
        {
          free = false;
          fullName = "PolyForm Free Trial License 1.0.0";
          redistributable = true;
          url = "https://polyformproject.org/licenses/free-trial/1.0.0/";
        }
      ];
    };
    passthru.updateScript = writeScript "update-matrix-media-repo" ''
      ${../../scripts/update-git.sh} "https://github.com/drone-runners/drone-runner-docker" ci/drone-runner-docker/source.json
      SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
      ${../../scripts/update-go.sh} ./ci/drone-runner-docker ci/drone-runner-docker/goVendor.hash  '';
  }
