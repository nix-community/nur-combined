{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "file-extra-metadata.yazi";
    version = "unstable-2026-07-13";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "file-extra-metadata.yazi";
        rev = "f432bb82b745fcb079d1b9a3755da3a9ad01cb07";
        hash = "sha256-VepoX4GYoforxs9kGBCGHgQA/gWXPVfhtOCSdT8rnDc=";
    };

    meta = {
        description = "Replace the default file preview with extra information.";
        homepage = "https://github.com/boydaihungst/file-extra-metadata.yazi";
        license = lib.licenses.mit;
    };
}
