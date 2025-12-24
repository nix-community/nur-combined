{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "enhance-piper.yazi";
    version = "unstable-2025-12-04";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "enhance-piper.yazi";
        rev = "8956b03525fb8a46414ddfde40961176a3b429fb";
        hash = "sha256-x3TbP/UWXwiCXbov9hmf33Eo4AylIWN51oMgHe6IzBY=";
    };

    meta = {
        description = "A wrapper that caches Piper command outputs in RAM for better performance.";
        homepage = "https://github.com/boydaihungst/enhance-piper.yazi";
        license = lib.licenses.mit;
    };
}
