{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "custom-shell.yazi";
    version = "unstable-2026-01-15";

    src = fetchFromGitHub {
        owner = "AnirudhG07";
        repo = "custom-shell.yazi";
        rev = "d50df9b1217726821eee9f0d51a198410d4cabf8";
        hash = "sha256-gDD6PauePAz9IVton8D4la0LbA7hWKYz+vxUP4DoLhk=";
    };

    meta = {
        description = "Set your custom-shell as default shell in yazi";
        homepage = "https://github.com/AnirudhG07/custom-shell.yazi";
        license = lib.licenses.mit;
    };
}
