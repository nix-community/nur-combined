{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "file-extra-metadata.yazi";
    version = "unstable-2026-09-08";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "file-extra-metadata.yazi";
        rev = "98baba68b611a11636c1323d061f42d51e8f5e4f";
        hash = "sha256-iPNMy/UGMNMyUg4zRC5X/J427bMM0UStixUNsNIu5zI=";
    };

    meta = {
        description = "Replace the default file preview with extra information.";
        homepage = "https://github.com/boydaihungst/file-extra-metadata.yazi";
        license = lib.licenses.mit;
    };
}
