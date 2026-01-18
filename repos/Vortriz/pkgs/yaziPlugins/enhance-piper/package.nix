{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "enhance-piper.yazi";
    version = "unstable-2026-01-01";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "enhance-piper.yazi";
        rev = "f127b5fec343903047b2cf1ad166d2fad2d6bd87";
        hash = "sha256-GEB7oZOaDQYfKwCzot1xv44h7BJV/5tmZEXrvxyDuSM=";
    };

    meta = {
        description = "A wrapper that caches Piper command outputs in RAM for better performance.";
        homepage = "https://github.com/boydaihungst/enhance-piper.yazi";
        license = lib.licenses.mit;
    };
}
