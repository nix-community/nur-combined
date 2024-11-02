{ stdenvNoCC, drl-unwrapped, imagemagick }: stdenvNoCC.mkDerivation {
    pname = "drl-icon";
    inherit (drl-unwrapped) version src;
    nativeBuildInputs = [imagemagick];
    buildPhase = ''
        runHook preBuild
        magick bin/graphics/logo.png -trim -background none -gravity center -resize 512x512 -extent 512x512 drl-icon.png
        runHook postBuild
    '';
    installPhase = ''
        runHook preInstall
        install -D drl-icon.png "$out"/share/icons/hicolor/512x512/apps/drl.png
        runHook postInstall
    '';
}
