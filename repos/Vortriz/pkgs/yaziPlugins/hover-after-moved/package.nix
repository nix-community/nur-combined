{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "hover-after-moved.yazi";
    version = "unstable-2026-01-06";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "hover-after-moved.yazi";
        rev = "c2e90df9278538741a3793d59f78af50e33bdff7";
        hash = "sha256-PtX3tqRrXfBQDquESrL59fAUpKEENJOD0ZwoooKsXko=";
    };

    meta = {
        description = "Hover over the first file/folder after moved";
        homepage = "https://github.com/boydaihungst/hover-after-moved.yazi";
        license = lib.licenses.mit;
    };
}
