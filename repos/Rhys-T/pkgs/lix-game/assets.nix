{
    stdenvNoCC, lib,
    lix-game,
    useHighResTitleScreen ? false, requireFile,
    convertImagesToTrueColor ? stdenvNoCC.isDarwin, imagemagick
}: let
    # <https://github.com/SimonN/LixD/issues/128>
    highResTitleScreen = requireFile {
        name = "243207799-937e6266-bad8-46f5-baef-ddef5378009c.png";
        url = "https://github.com/SimonN/LixD/issues/128#issuecomment-1575734721";
        hash = "sha256-BopSCjgHq6sBVeTZcIL49tABM3bDe6YYPjIt68i7I9s=";
    };
in stdenvNoCC.mkDerivation {
    pname = "${lix-game.pname}-assets";
    inherit (lix-game) version src;
    nativeBuildInputs = lib.optionals convertImagesToTrueColor [imagemagick];
    ${if useHighResTitleScreen then "highResTitleScreen" else null} = highResTitleScreen;
    postPatch = ''
    rm -r data/desktop
    '' + lib.optionalString useHighResTitleScreen ''
    cp -f "$highResTitleScreen" data/images/mainmenubg.png
    '' + lib.optionalString convertImagesToTrueColor ''
    echo 'Converting all game images to PNG32 to work around <https://github.com/SimonN/LixD/issues/431>...'
    find images/ data/images/ -name \*.png -exec magick {} PNG32:{} \;
    echo 'Done.'
    '';
    installPhase = ''
    mkdir -p "$out"
    cp -r data images levels "$out"/
    '';
    meta = {
        description = "${lix-game.meta.description} (game asset files)";
        inherit (lix-game.meta) homepage;
        license = with lib.licenses; [
            cc0
            bitstreamVera # data/fonts/djvusans.ttf
        ];
    };
    passthru = {
        inherit useHighResTitleScreen convertImagesToTrueColor;
    };
}
