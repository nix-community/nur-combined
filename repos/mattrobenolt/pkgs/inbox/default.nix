{ lib
, stdenv
, fetchurl
,
}:

let
  version = "0.0.4";

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
    "linux_amd64" = "sha256-Zl9EcJxzbuXAmnhAWnqbkwqyPGVvBC4Uz8aDp03QmcM=";
    "linux_arm64" = "sha256-l5XCTv6j7slrzKHC9OXv0JPmFXnVn4Vm84kX9BL7olA=";
    "darwin_amd64" = "sha256-Ygbloeh8dHOfCEc5rvjT6Q6Y8bLzovCgaqwEVUgQ8iM=";
    "darwin_arm64" = "sha256-JDFwCY4/b5F0Yp/GIuN2P4Pc9YccCdLEaoZd1SY/9Ok=";
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
