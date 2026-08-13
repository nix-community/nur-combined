{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "custom-shell.yazi";
    version = "unstable-2026-08-07";

    src = fetchFromGitHub {
        owner = "AnirudhG07";
        repo = "custom-shell.yazi";
        rev = "6f684046fc44465bd310969ae1e42d4d8a19685b";
        hash = "sha256-vEX6E9lfMV77wrgEgAIOHTb8ibbW0UUQIWiwo/fPN2w=";
    };

    meta = {
        description = "Set your custom-shell as default shell in yazi";
        homepage = "https://github.com/AnirudhG07/custom-shell.yazi";
        license = lib.licenses.mit;
    };
}
