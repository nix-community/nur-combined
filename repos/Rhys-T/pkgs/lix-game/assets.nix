{
    stdenvNoCC, lib,
    convertImagesToTrueColor, imagemagick, perl,
    common
}: let
    hash = if convertImagesToTrueColor then common.assetsPNG32Hash or lib.fakeHash else common.assetsHash or lib.fakeHash;
    hashAlgo = builtins.head (lib.strings.splitString "-" hash);
    # ImageMagick 7.1.1-44 is adding an extra tEXt chunk to its output PNGs.
    # https://github.com/ImageMagick/ImageMagick/issues/7977#issuecomment-2682981255
    # This strips it back out to make the hash consistent.
    # Seems to be fixed in 7.1.1-45.
    needToStripMimeTypeChunk = lib.versionAtLeast imagemagick.version "7.1.1-44" && lib.versionOlder imagemagick.version "7.1.1-45";
in stdenvNoCC.mkDerivation {
    pname = "${common.pname}-assets" + lib.optionalString convertImagesToTrueColor "-PNG32";
    inherit (common) version src;
    nativeBuildInputs = lib.optionals convertImagesToTrueColor ([imagemagick] ++ lib.optionals needToStripMimeTypeChunk [perl]);
    postPatch = ''
        rm -r data/desktop
        '' + lib.optionalString convertImagesToTrueColor ''
        echo 'Converting all game images to PNG32 to work around <https://github.com/SimonN/LixD/issues/431>...'
        find images/ data/images/ -name \*.png -exec magick mogrify -define png:color-type=6 -depth 8 {} +${
            lib.optionalString needToStripMimeTypeChunk ''${" "}-exec perl -pi -e 's|\x00\x00\x00\x13\x74\x45\x58\x74\x6D\x69\x6D\x65\x3A\x74\x79\x70\x65\x00\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\xB9\x95\x10\x87||g' {} +''
        }
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
