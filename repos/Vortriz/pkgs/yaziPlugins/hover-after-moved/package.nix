{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "hover-after-moved.yazi";
    version = "unstable-2026-02-16";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "hover-after-moved.yazi";
        rev = "a41e8ec5cd10e3ede87ceddc563d6a25b7bd403c";
        hash = "sha256-xN9T+9CfDQsl6ZVnz7XNQpxEOIZeRu+u+x0aksKBTLE=";
    };

    meta = {
        description = "Hover over the first file/folder after moved";
        homepage = "https://github.com/boydaihungst/hover-after-moved.yazi";
        license = lib.licenses.mit;
    };
}
