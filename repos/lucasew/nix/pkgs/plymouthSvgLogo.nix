{
  stdenvNoCC,
  fetchurl,
  inkscape,
}:
{
  url,
  sha256,
  width ? 150,
  height ? 210,
}:
stdenvNoCC.mkDerivation {
  name = "plymouth-logo.png";
  dontUnpack = true;
  src = fetchurl { inherit url sha256; };
  nativeBuildInputs = [ inkscape ];
  buildPhase = ''
    runHook preBuild
    inkscape --export-type=png "$src" -w ${toString width} -h ${toString height} -o wallpaper.png
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    install -Dm0644 wallpaper.png $out
    runHook postInstall
  '';
}
