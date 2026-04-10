{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "enhance-piper.yazi";
    version = "unstable-2026-04-09";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "enhance-piper.yazi";
        rev = "9af29cd9fe66ae8d661c71b598db6545deca05a4";
        hash = "sha256-nQy/VoUZfAJ2rTWrHtf8Yb9UFgIf1nYbC9DBhLuQmPk=";
    };

    meta = {
        description = "A wrapper that caches Piper command outputs in RAM for better performance.";
        homepage = "https://github.com/boydaihungst/enhance-piper.yazi";
        license = lib.licenses.mit;
    };
}
