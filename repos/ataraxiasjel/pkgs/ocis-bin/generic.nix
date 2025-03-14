{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
version: hashes:
let
  system = stdenv.hostPlatform.system;
  hash = hashes.${system} or (throw "Unsupported system: ${system}");
  arch =
    {
      i686-linux = "386";
      x86_64-linux = "amd64";
      aarch64-linux = "arm64";
      armv7l-linux = "arm";
      x86_64-darwin = "amd64";
      aarch64-darwin = "arm64";
    }
    .${system} or (throw "Unsupported system: ${system}");
  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "Unsupported OS";
in
stdenv.mkDerivation {
  pname = "ocis";
  inherit version;

  src = fetchurl {
    url = "https://github.com/owncloud/ocis/releases/download/v${version}/ocis-${version}-${os}-${arch}";
    inherit hash;
  };

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -D $src $out/bin/ocis
    runHook postInstall
  '';

  # passthru.updateScript = ./update.py;
  passthru.skipBulkUpdate = true;

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://owncloud.dev/ocis";
    changelog = "https://github.com/owncloud/ocis/releases/tag/v${version}";
    license = licenses.unfree;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    mainProgram = "ocis";
    # Derivations just pulls binary from github
    # It not make any sense to cache all of them
    preferLocalBuild = true;
  };
}
