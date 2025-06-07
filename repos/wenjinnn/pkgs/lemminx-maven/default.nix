{
  stdenv,
  lib,
  fetchurl,
  jre_headless,
  unzip,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "lemminx-maven";
  version = "0.12.0";

  src = fetchurl {
    url = "https://repo.eclipse.org/content/repositories/lemminx-releases/org/eclipse/lemminx/${pname}/${version}/${pname}-${version}-vscode-uber-jars.zip";
    sha256 = "XsMOqxShdi+etbnlQk3Jk3unJd2E8d2CkIM6JZZ/7xQ=";
  };

  nativeBuildInputs = [ unzip ];

  buildInputs = [ makeWrapper ];

  unpackPhase = ''
    unzip ${src}
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r ./**.jar $out/share

    makeWrapper ${jre_headless}/bin/java $out/bin/lemminx \
      --add-flags "-XX:TieredStopAtLevel=1" \
      --add-flags "-XX:+UseParallelGC" \
      --add-flags "-XX:MinHeapFreeRatio=5" \
      --add-flags "-XX:MaxHeapFreeRatio=10" \
      --add-flags "-XX:GCTimeRatio=4" \
      --add-flags "-XX:AdaptiveSizePolicyWeight=90" \
      --add-flags "-Dsun.zip.disableMemoryMapping=true" \
      --add-flags "-cp" \
      --add-flags "$(ls -d -1 $out/share/** | tr '\n' ':')" \
      --add-flags "org.eclipse.lemminx.XMLServerLauncher"

    runHook postInstall
  '';

  meta = {
    description = "lemminx-maven";
    homepage = "https://github.com/eclipse-lemminx/lemminx-maven";
    license = lib.licenses.epl20;
    mainProgram = "lemminx";
    maintainers = with lib.maintainers; [ wenjinnn ];
    platforms = [ "x86_64-linux" ];
  };
}
