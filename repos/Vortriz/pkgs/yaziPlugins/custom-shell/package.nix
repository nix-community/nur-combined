{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "custom-shell.yazi";
    version = "0-unstable-2025-06-07";

    src = fetchFromGitHub {
        owner = "AnirudhG07";
        repo = "custom-shell.yazi";
        rev = "b04213d2f4ca6079bef37491be07860baa8264b9";
        hash = "sha256-hJVFZvcHgcjmcwUUGs1Q668KjeLSCEVuAhAD1A8ZM90=";
    };

    meta = {
        description = "Set your custom-shell as default shell in yazi";
        homepage = "https://github.com/AnirudhG07/custom-shell.yazi";
        license = lib.licenses.mit;
    };
}
