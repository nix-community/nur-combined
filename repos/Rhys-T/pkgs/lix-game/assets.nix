{
    stdenvNoCC, lib,
    convertImagesToTrueColor, imagemagick,
    common
}: let
    hash = if convertImagesToTrueColor then common.assetsPNG32Hash else common.assetsHash;
    hashAlgo = builtins.head (lib.strings.splitString "-" hash);
in stdenvNoCC.mkDerivation {
    pname = "${common.pname}-assets" + lib.optionalString convertImagesToTrueColor "-PNG32";
    inherit (common) version src;
    nativeBuildInputs = lib.optionals convertImagesToTrueColor ([imagemagick]);
    postPatch = ''
        rm -r data/desktop
        '' + lib.optionalString convertImagesToTrueColor ''
        echo 'Converting all game images to PNG32 to work around <https://github.com/SimonN/LixD/issues/431>...'
        find images/ data/images/ -name \*.png -exec magick mogrify -define png:color-type=6 -depth 8 {} +
        echo 'Done.'
    '';
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/share/lix
        cp -r data images levels "$out"/share/lix/
        runHook postInstall
    '';
    preferLocalBuild = !convertImagesToTrueColor;
    outputHash = hash;
    outputHashAlgo = hashAlgo;
    outputHashMode = "recursive";
    meta = common.meta // {
        description = "${common.meta.description} (game asset files)";
        license = with lib.licenses; [
            cc0
            bitstreamVera # data/fonts/djvusans.ttf
        ];
    };
}
