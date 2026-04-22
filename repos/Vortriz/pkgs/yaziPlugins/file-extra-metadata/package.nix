{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "file-extra-metadata.yazi";
    version = "unstable-2026-04-22";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "file-extra-metadata.yazi";
        rev = "044274ca2e473f18910d03ca7392dff5ef028deb";
        hash = "sha256-Yq8nv/MSxOy0xTyeIQac/Gu8j1tLL6m7glFicjJ3fIs=";
    };

    meta = {
        description = "Replace the default file preview with extra information.";
        homepage = "https://github.com/boydaihungst/file-extra-metadata.yazi";
        license = lib.licenses.mit;
    };
}
