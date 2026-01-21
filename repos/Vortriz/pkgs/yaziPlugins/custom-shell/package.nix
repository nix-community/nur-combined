{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "custom-shell.yazi";
    version = "unstable-2026-01-20";

    src = fetchFromGitHub {
        owner = "AnirudhG07";
        repo = "custom-shell.yazi";
        rev = "3449686fdedd3fd21bc0b60fa60e8f2245f55679";
        hash = "sha256-hAfXoQGx+Usp8tZneeLAhWNckvDbIo2cIQcsHDNAvEI=";
    };

    meta = {
        description = "Set your custom-shell as default shell in yazi";
        homepage = "https://github.com/AnirudhG07/custom-shell.yazi";
        license = lib.licenses.mit;
    };
}
