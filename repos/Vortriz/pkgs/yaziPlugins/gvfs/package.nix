{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "gvfs.yazi";
    version = "unstable-2026-07-13";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "gvfs.yazi";
        rev = "c5a0bb924eceeeb8b44bfc00aba0a97ba0287fa3";
        hash = "sha256-hSHEN/F4uc1FFScB5lLRAKryLwP+O7I9vgEgobGbQyw=";
    };

    meta = {
        description = "Transparently mount and unmount devices in read/write mode";
        homepage = "https://github.com/boydaihungst/gvfs.yazi";
        license = lib.licenses.mit;
    };
}
