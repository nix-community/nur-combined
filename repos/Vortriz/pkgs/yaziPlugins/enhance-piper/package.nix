{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "enhance-piper.yazi";
    version = "unstable-2026-09-08";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "enhance-piper.yazi";
        rev = "b9115b132858b5c6767b34a9597572cbeed172fd";
        hash = "sha256-YtJwT7KGea0oBzTN9Y9f7ntqmsthA5V1kyKzqtNiZjM=";
    };

    meta = {
        description = "A wrapper that caches Piper command outputs in RAM for better performance.";
        homepage = "https://github.com/boydaihungst/enhance-piper.yazi";
        license = lib.licenses.mit;
    };
}
