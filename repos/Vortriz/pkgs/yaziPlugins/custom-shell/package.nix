{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "custom-shell.yazi";
    version = "unstable-2026-07-11";

    src = fetchFromGitHub {
        owner = "AnirudhG07";
        repo = "custom-shell.yazi";
        rev = "9bf5954827fbc34041ed0cac74f4f660ac4cd2ef";
        hash = "sha256-Ur5+HsUN4TAVr+BkKThhzm2xRe270UFCf1S+zSMwpw8=";
    };

    meta = {
        description = "Set your custom-shell as default shell in yazi";
        homepage = "https://github.com/AnirudhG07/custom-shell.yazi";
        license = lib.licenses.mit;
    };
}
