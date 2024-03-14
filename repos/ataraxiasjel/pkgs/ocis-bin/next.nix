{ stdenv, lib, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "ocis-next-bin";
  version = "5.0.0-rc.6";

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
      x86_64-linux = "sha256-srAPyuJv0DILTiD2w/gkA5nN3TriEm2ZGKgtEku41M8=";
      aarch64-linux = "sha256-GG9d+zCk8mwHw0iBV864zGR6sEPTQHBy9nH19UtXhL4=";
      i686-linux = "sha256-DxmBJpUaaYumaDQXWvzAJscLgyNm0FTD41YRmNdWk7s=";
      x86_64-darwin = "sha256-m+27XwEIcDaOUd0xTOTTtClEgQaMzECX52EhTzxIKBs=";
      aarch64-darwin = "sha256-rxHNlbW5vHtEeQqI9FT8FXTio7WUnppxHmBziDZ+PY8=";
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

  passthru.updateScript = ./update-next.sh;

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://doc.owncloud.com/ocis/next";
    license = licenses.asl20;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
