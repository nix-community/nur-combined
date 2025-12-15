{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "yazi-hover-after-moved";
    version = "0-unstable-2025-09-28";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "hover-after-moved.yazi";
        rev = "76e496c4f22a7638598357ddf72dbdd0110f4228";
        hash = "sha256-TFVxC+zrmEWH42ciN/1NjfSeSGOxxLP+kcbuAnQtNTo=";
    };

    meta = {
        description = "Hover over the first file/folder after moved";
        homepage = "https://github.com/boydaihungst/hover-after-moved.yazi";
        license = lib.licenses.mit;
    };
}
