{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "gvfs.yazi";
    version = "unstable-2026-01-07";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "gvfs.yazi";
        rev = "d9e3e0d3ce352f230ec066c116afdb496a114530";
        hash = "sha256-YhiqH3fFX6XjxyoyWwz+VpyHmFWGegWRie/GHeD6+SE=";
    };

    meta = {
        description = "Transparently mount and unmount devices in read/write mode";
        homepage = "https://github.com/boydaihungst/gvfs.yazi";
        license = lib.licenses.mit;
    };
}
