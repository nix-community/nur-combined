{
  buildGo118Module,
  git,
  fetchFromGitHub,
  lib,
  writeScript,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  buildGo118Module rec {
    pname = "matrix-media-repo";
    version = source.date;
    src = fetchFromGitHub {
      owner = "turt2live";
      repo = "matrix-media-repo";
      inherit (source) rev sha256;
    };
    patches = [./async-media.patch];
    vendorSha256 = builtins.readFile ./vendor.sha256;
    nativeBuildInputs = [
      git
    ];
    proxyVendor = true;
    CGO_ENABLED = "1";
    buildPhase = ''
      GOBIN=$PWD/bin go install -v ./cmd/compile_assets
      $PWD/bin/compile_assets
      GOBIN=$PWD/bin go install -ldflags "-X github.com/turt2live/matrix-media-repo/common/version.GitCommit=$(git rev-list -1 HEAD) -X github.com/turt2live/matrix-media-repo/common/version.Version=${version}" -v ./cmd/...
    '';
    installPhase = ''
      mkdir $out
      cp -rv bin $out
    '';
    meta = {
      description = "Matrix media repository with multi-domain in mind.";
      license = lib.licenses.mit;
    };
    passthru.updateScript = writeScript "update-matrix-media-repo" ''
      ${../../scripts/update-git.sh} "https://github.com/turt2live/matrix-media-repo" matrix/matrix-media-repo/source.json
      SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
      ${../../scripts/update-go.sh} ./matrix/matrix-media-repo matrix/matrix-media-repo/vendor.sha256
    '';
  }
