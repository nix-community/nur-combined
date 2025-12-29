{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "enhance-piper.yazi";
    version = "unstable-2025-12-29";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "enhance-piper.yazi";
        rev = "8432aeb7c25d5e4546aa50c8d50ff1d174b5a2f4";
        hash = "sha256-/USHPhrDuiNhVxOjo3o0mAt8sbig/T1U58M1DRdD+hg=";
    };

    meta = {
        description = "A wrapper that caches Piper command outputs in RAM for better performance.";
        homepage = "https://github.com/boydaihungst/enhance-piper.yazi";
        license = lib.licenses.mit;
    };
}
