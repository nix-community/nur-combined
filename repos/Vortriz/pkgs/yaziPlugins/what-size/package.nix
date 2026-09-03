{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "what-size.yazi";
    version = "unstable-2026-09-02";

    src = fetchFromGitHub {
        owner = "pirafrank";
        repo = "what-size.yazi";
        rev = "1cb456f8c428a393a65708b45b8c56404d52f326";
        hash = "sha256-lhanC44L4haM7cgqCOhfxk0Rpi/FueBgIdXDiXuzevc=";
    };
    meta = {
        description = "A plugin for yazi to calculate the size of current selection or current working directory";
        homepage = "https://github.com/pirafrank/what-size.yazi";
        license = lib.licenses.mit;
    };
}
