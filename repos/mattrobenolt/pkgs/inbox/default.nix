{ lib
, stdenv
, fetchurl
,
}:

let
  version = "0.0.3";

  # Map Nix system to goreleaser's target naming
  targets = {
    "x86_64-linux" = "linux_amd64";
    "aarch64-linux" = "linux_arm64";
    "x86_64-darwin" = "darwin_amd64";
    "aarch64-darwin" = "darwin_arm64";
  };

  target =
    targets.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  # SHA256 hashes for each platform
  hashes = {
    "linux_amd64" = "sha256-mGQdFlZJbeV0TMKca9zi9d1dE4LxYVCjHhfbVzMtXXc=";
    "linux_arm64" = "sha256-wUHX6w3T9xTWzmZchwJyFrXOKysoRFzguLNJuSwuTo0=";
    "darwin_amd64" = "sha256-Zl02kXcrygIlLOkKEIq7S5iOyOl662EpgDAx4ImkNoo=";
    "darwin_arm64" = "sha256-y4ZwvJmnSF2I5TF729EChvljOoyHwfLZ0bhoFJ1KNEs=";
  };

in
stdenv.mkDerivation {
  pname = "inbox";
  inherit version;

  src = fetchurl {
    url = "https://github.com/mattrobenolt/inbox/releases/download/v${version}/inbox_${version}_${target}.tar.gz";
    hash = hashes.${target};
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D -m755 inbox $out/bin/inbox

    runHook postInstall
  '';

  meta = with lib; {
    description = "A fast, beautiful, and distraction-free Gmail client for your terminal";
    homepage = "https://github.com/mattrobenolt/inbox";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = [ ];
    mainProgram = "inbox";
  };
}
