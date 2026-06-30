{
  lib,
  stdenvNoCC,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  libgcc,
}:

stdenvNoCC.mkDerivation rec {
  pname = "teamspeak6-server";
  version = "6.0.0-beta11";

  src = fetchzip {
    url = "https://github.com/teamspeak/teamspeak6-server/releases/download/v${version}/teamspeak6-server-linux-arm64.tar.xz";
    stripRoot = false;
    hash = "sha256-Xt1VNJqKRCsSrBzPk6ojYkOrCNYzX45sN63jhkCKzd8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libgcc.lib
  ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    installDir="$out/lib/teamspeak"
    docDir="$out/share/doc/${pname}"
    licenseDir="$out/share/licenses/${pname}"
    mkdir -p "$installDir" "$out/bin" "$docDir" "$licenseDir"

    cp -r . "$installDir"

    mv "$installDir/CHANGELOG" "$docDir/"
    mv "$installDir/doc" "$docDir/"
    mv "$installDir/serverquerydocs" "$docDir/"
    mv "$installDir/LICENSE" "$licenseDir/"
    mv "$installDir/THIRD_PARTY_LICENSES" "$licenseDir/"

    makeWrapper "$installDir/tsserver" "$out/bin/tsserver" \
      --prefix LD_LIBRARY_PATH : "$installDir" \
      --set-default TSSERVER_LICENSE_PATH "$licenseDir/LICENSE" \
      --set-default TSSERVER_DATABASE_SQL_PATH "$installDir/sql" \
      --set-default TSSERVER_QUERY_DOCUMENTATION_PATH "$docDir/serverquerydocs"

    runHook postInstall
  '';

  meta = with lib; {
    description = "TeamSpeak voice communication server";
    homepage = "https://teamspeak.com/";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    license = licenses.teamspeak;
    platforms = [ "aarch64-linux" ];
    mainProgram = "tsserver";
  };
}
