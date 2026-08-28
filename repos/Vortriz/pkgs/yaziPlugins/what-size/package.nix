{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "what-size.yazi";
    version = "unstable-2026-08-27";

    src = fetchFromGitHub {
        owner = "pirafrank";
        repo = "what-size.yazi";
        rev = "ec94d9a8496241d91dcfb2a864214871c326ddc5";
        hash = "sha256-slM9qypEy8A4l3KodE7bmyixA+1c4X7hgoGcQP7R25k=";
    };
    meta = {
        description = "A plugin for yazi to calculate the size of current selection or current working directory";
        homepage = "https://github.com/pirafrank/what-size.yazi";
        license = lib.licenses.mit;
    };
}
