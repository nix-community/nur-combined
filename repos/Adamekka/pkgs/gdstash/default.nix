{ jre
, lib
, makeWrapper
, maintainer
, stdenvNoCC
, unzip
,
}:

let
  nexusFileHash = "sha256-7+c5/eEXGmyDWIMdla6uexlkgiqKhRL65RDBFgmg1K4=";
  nexusFileId = "3158";
in
stdenvNoCC.mkDerivation rec {
  pname = "gdstash";
  version = "1.8.2a";

  src = ./GDStash.zip;

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    runHook preUnpack

    unzip "$src"

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/bin" "$out/share/gdstash"
    cp -R . "$out/share/gdstash"

    jarFile="$(find "$out/share/gdstash" -type f -iname "GDStash.jar" -print -quit)"
    if [ -z "$jarFile" ]; then
      echo "Could not find GDStash.jar in the GD Stash archive" >&2
      exit 1
    fi

    makeWrapper ${jre}/bin/java "$out/bin/gdstash" \
      --chdir "$out/share/gdstash" \
      --add-flags "-jar" \
      --add-flags "$jarFile"

    runHook postInstall
  '';

  passthru = {
    inherit nexusFileHash nexusFileId;
  };

  meta = {
    description = "External stash manager for Grim Dawn";
    homepage = "https://www.nexusmods.com/grimdawn/mods/2";
    license = lib.licenses.unfree;
    mainProgram = "gdstash";
    maintainers = [ maintainer ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
