{
  lib,
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
  # Cloudflare 403s the Nixpkgs curl user-agent on wikia.nocookie.net.
  src = fetchurl {
    inherit url sha256;
    curlOptsList = lib.optionals (lib.hasInfix "wikia.nocookie.net" url) [
      "--user-agent"
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
      "--referer"
      "https://elderscrolls.fandom.com/"
    ];
  };
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
