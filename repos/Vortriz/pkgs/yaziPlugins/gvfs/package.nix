{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "gvfs.yazi";
    version = "unstable-2026-08-29";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "gvfs.yazi";
        rev = "a85d65961b0ce99b472dd6e83b99062be178450b";
        hash = "sha256-NCFdSNqSqrcbFsp8osnDhbzY2p2CyF5hzxQ1qG3TXwc=";
    };

    meta = {
        description = "Transparently mount and unmount devices in read/write mode";
        homepage = "https://github.com/boydaihungst/gvfs.yazi";
        license = lib.licenses.mit;
    };
}
