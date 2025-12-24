{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "gvfs.yazi";
    version = "unstable-2025-12-21";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "gvfs.yazi";
        rev = "c12e716b9663cbd6ae141cd1688b46342b5e4d37";
        hash = "sha256-MdH+z9Ec3dUuP64rYkP1KvXrJCZThatckQOtrJu/q8A=";
    };

    meta = {
        description = "Transparently mount and unmount devices in read/write mode";
        homepage = "https://github.com/boydaihungst/gvfs.yazi";
        license = lib.licenses.mit;
    };
}
