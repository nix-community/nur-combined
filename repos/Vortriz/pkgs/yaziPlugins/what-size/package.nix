{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "what-size.yazi";
    version = "unstable-2025-12-31";

    src = fetchFromGitHub {
        owner = "pirafrank";
        repo = "what-size.yazi";
        rev = "a36fdaf6e011b1da41a8884956dd7237b59fad4d";
        hash = "sha256-dakNC8Pivqm89FVpNL8FfpWjF0687Kd4cWnpcyEMq+Y=";
    };
    meta = {
        description = "A plugin for yazi to calculate the size of current selection or current working directory";
        homepage = "https://github.com/pirafrank/what-size.yazi";
        license = lib.licenses.mit;
    };
}
