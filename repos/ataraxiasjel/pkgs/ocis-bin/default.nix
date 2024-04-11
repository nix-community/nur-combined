{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "ocis-bin";
  version = "4.0.6";

  src = let
    inherit (stdenv.hostPlatform) system;
    selectSystem = attrs:
      attrs.${system} or (throw "Unsupported system: ${system}");
    suffix = selectSystem {
      x86_64-linux = "linux-amd64";
      aarch64-linux = "linux-arm64";
      i686-linux = "linux-386";
      x86_64-darwin = "darwin-amd64";
      aarch64-darwin = "darwin-arm64";
    };
    sha256 = selectSystem {
      x86_64-linux = "sha256-wz4gVTWdmMNt+pU7VqelVtkRFp2yfw+CnJ60HPN/9hU=";
      aarch64-linux = "sha256-y4cnI/NGVhlXdTJoH8WneRFxM1WMYAFKjVQ/tI7g27Q=";
      i686-linux = "sha256-wtwtur+OJ2VtDQM0MJKGLbikX6Lwo46+uGddVKjaOG8=";
      x86_64-darwin = "sha256-/pSXmJzHltmXIHuyUXCczyABBHPjALO5jKcxqXHHFpg=";
      aarch64-darwin = "sha256-tEr5hi4DTWQ72GGxcglI7YjL+QgYt0VjKON2KkVXK4s=";
    };
  in fetchurl {
    url =
      "https://github.com/owncloud/ocis/releases/download/v${version}/ocis-${version}-${suffix}";
    inherit sha256;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = stdenv.isDarwin;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -D $src $out/bin/ocis
    runHook postInstall
  '';

  # passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://doc.owncloud.com/ocis/next";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
