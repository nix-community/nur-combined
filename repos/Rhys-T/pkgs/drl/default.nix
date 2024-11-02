{ stdenvNoCC, lib, drl-unwrapped, drl-audio, drl-icon, makeDesktopItem, copyDesktopItems, desktopToDarwinBundle, coreutils }: let
    wrongAudioSuffix = if drl-audio.audioQuality == "hq" then "" else "hq";
in stdenvNoCC.mkDerivation {
    pname = "drl-${drl-audio.audioQuality}";
    inherit (drl-unwrapped) version;
    nativeBuildInputs = [copyDesktopItems] ++ lib.optionals stdenvNoCC.isDarwin [desktopToDarwinBundle];
    dontUnpack = true;
    unwrapped = drl-unwrapped;
    audio = drl-audio;
    icon = drl-icon;
    inherit coreutils;
    desktopItems = [(makeDesktopItem {
        name = "drl";
        desktopName = "DRL";
        exec = "drl";
        icon = "drl";
        type = "Application";
        genericName = drl-unwrapped.meta.description;
        categories = [ "Game" ];
        keywords = [ "Game" ];
    })];
    installPhase = ''
        runHook preInstall
        shopt -s extglob
        mkdir -p "$out"/bin "$out"/share/drl
        ln -s \
            "$unwrapped"/share/drl/!(@(sound|music)${wrongAudioSuffix}.lua) \
            "$out"/share/drl/
        ${lib.optionalString (drl-audio.audioQuality == "hq") ''
            for file in sound music; do
                mv "$out/share/drl/''${file}hq.lua" "$out/share/drl/$file.lua"
            done
        ''}
        ln -s "$audio"/* "$out"/share/drl/
        ln -s "$icon"/share/icons "$out"/share/icons
        substituteAll ${./drl.sh} "$out"/bin/drl
        chmod +x "$out"/bin/drl
        shopt -u extglob
        runHook postInstall
    '';
    meta = drl-unwrapped.meta // {
        mainProgram = "drl";
    };
}
