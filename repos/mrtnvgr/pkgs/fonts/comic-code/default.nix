{ stdenvNoCC, fetchzip, lib }:
stdenvNoCC.mkDerivation {
  name = "comic-code";

  src = fetchzip {
    url = "https://drive.google.com/uc?export=download&id=1wx7FEsAGnG5ZRyrnSG2NjcsrhHmL4nuh";
    hash = "sha256-htNWoKBE14SvtuE0sUVj+fs190ZojxSZ/OzPV4VCLzI=";
    extension = "zip";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype
    install -Dm444 *.otf $out/share/fonts/truetype/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Monospaced adaptation of the most infamous yet most popular casual font";
    homepage = "https://tosche.net/fonts/comic-code";
    license = licenses.unfree;
    platforms = platforms.all;
    unsafe = true;
  };
}
