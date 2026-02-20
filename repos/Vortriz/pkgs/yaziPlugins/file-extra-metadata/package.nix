{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "file-extra-metadata.yazi";
    version = "unstable-2026-02-16";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "file-extra-metadata.yazi";
        rev = "871ba3cecf960db6d1849ded33f3e36a91d870dd";
        hash = "sha256-7ewJUgZQQVRrDDzDZX3bQCP5etik1FhdyOvZG0jffEw=";
    };

    meta = {
        description = "Replace the default file preview with extra information.";
        homepage = "https://github.com/boydaihungst/file-extra-metadata.yazi";
        license = lib.licenses.mit;
    };
}
