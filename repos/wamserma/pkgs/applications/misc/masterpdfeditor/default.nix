{ stdenv, fetchurl, sane-backends, qtbase, qtsvg, nss, autoPatchelfHook, lib, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "masterpdfeditor4";
  version = "4.3.89";

  src = fetchurl {
    url = "https://code-industry.net/public/master-pdf-editor-${version}_qt5.amd64.tar.gz";
    sha256 = "0k5bzlhqglskiiq86nmy18mnh5bf2w3mr9cq3pibrwn5pisxnxxc";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapQtAppsHook ];

  buildInputs = [ nss qtbase qtsvg sane-backends stdenv.cc.cc ];

  dontStrip = true;

  installPhase = ''
    runHook preInstall

    p=$out/opt/masterpdfeditor
    mkdir -p $out/bin

    substituteInPlace masterpdfeditor4.desktop \
      --replace 'Exec=/opt/master-pdf-editor-4' "Exec=$out/bin" \
      --replace 'Path=/opt/master-pdf-editor-4' "Path=$out/bin" \
      --replace 'Icon=/opt/master-pdf-editor-4' "Icon=$out/share/pixmaps"

    install -Dm644 -t $out/share/pixmaps      masterpdfeditor4.png
    install -Dm644 -t $out/share/applications masterpdfeditor4.desktop
    install -Dm755 -t $p                      masterpdfeditor4
    install -Dm644 license.txt $out/share/$name/LICENSE
    ln -s $p/masterpdfeditor4 $out/bin/masterpdfeditor4
    cp -v -r stamps templates lang fonts $p

    runHook postInstall
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Master PDF Editor (old version with free text editing)";
    homepage = "https://code-industry.net/free-pdf-editor/";
    license = licenses.unfreeRedistributable;
    platforms = with platforms; [ "x86_64-linux" ];
    maintainers = with maintainers; [ wamserma ];
  };
}
