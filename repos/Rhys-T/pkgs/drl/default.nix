{ stdenvNoCC, lib, drl-unwrapped, drl-audio, coreutils }: let
    wrongAudioSuffix = if drl-audio.audioQuality == "hq" then "" else "hq";
in stdenvNoCC.mkDerivation {
    pname = "drl-${drl-audio.audioQuality}";
    inherit (drl-unwrapped) version;
    dontUnpack = true;
    unwrapped = drl-unwrapped;
    audio = drl-audio;
    inherit coreutils;
    installPhase = ''
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
        substituteAll ${./drl.sh} "$out"/bin/drl
        chmod +x "$out"/bin/drl
        shopt -u extglob
    '';
    meta = drl-unwrapped.meta // {
        mainProgram = "drl";
    };
}
