{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "file-extra-metadata.yazi";
    version = "unstable-2025-12-04";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "file-extra-metadata.yazi";
        rev = "524fd8e46353a5ede7e0903b01c2ac0867b82b3f";
        hash = "sha256-K1iZ7XY4lIh9DFFqZ4opntHdJ5ekpllgj5Zc5FCEx3w=";
    };

    meta = {
        description = "Replace the default file preview with extra information.";
        homepage = "https://github.com/boydaihungst/file-extra-metadata.yazi";
        license = lib.licenses.mit;
    };
}
