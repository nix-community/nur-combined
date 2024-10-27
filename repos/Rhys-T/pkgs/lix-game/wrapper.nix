{
    stdenvNoCC, lib, lndir, makeBinaryWrapper,
    fetchFromGitHub,
    game-unwrapped, assets,
    useHighResTitleScreen, highResTitleScreen,
    includeMusic, music,
    common
}: stdenvNoCC.mkDerivation {
    inherit (common) pname version;
    dontUnpack = true;
    preferLocalBuild = true;
    nativeBuildInputs = [lndir makeBinaryWrapper];
    unwrapped = game-unwrapped;
    inherit assets;
    ${if includeMusic then "music" else null} = music;
    ${if useHighResTitleScreen then "highResTitleScreen" else null} = highResTitleScreen;
    installPhase =
        ''
        shopt -s extglob
        mkdir -p "$out"
        lndir "$unwrapped" "$out"
        '' + (if !(includeMusic || useHighResTitleScreen) then ''
            mkdir -p "$out"/share
            ln -s "$assets"/share/lix "$out"/share/lix
        '' else (
            ''
            mkdir -p "$out"/share/lix
            ln -s "$assets"/share/lix/${if useHighResTitleScreen then "!(data)" else "*"} "$out"/share/lix/
            '' + lib.optionalString includeMusic ''
                ln -s "$music" "$out"/share/lix/music
            '' + lib.optionalString useHighResTitleScreen ''
                mkdir -p "$out"/share/lix/data/images
                ln -s "$assets"/share/lix/data/!(images) "$out"/share/lix/data/
                ln -s "$assets"/share/lix/data/images/!(mainmenubg.png) "$out"/share/lix/data/images/
                cp "$highResTitleScreen" "$out"/share/lix/data/images/mainmenubg.png
            ''
        )) + ''
        wrapProgram "$out"/bin/lix --suffix XDG_DATA_DIRS : "$out"/share/
        shopt -u extglob
        '' + lib.optionalString stdenvNoCC.isDarwin ''
            ln -sf "$out"/bin/lix "$out"/Applications/Lix.app/Contents/MacOS/Lix
        '';
    meta = common.meta // {
        license = lib.unique (lib.concatMap (p: lib.toList (p.meta.license or [])) (
            [game-unwrapped assets] ++ 
            lib.optional includeMusic music ++
            lib.optional useHighResTitleScreen highResTitleScreen
        ));
        inherit (game-unwrapped.meta) mainProgram;
    };
    passthru = {
        inherit (game-unwrapped) pkgs;
    };
}
