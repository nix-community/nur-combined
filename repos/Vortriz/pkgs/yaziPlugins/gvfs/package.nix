{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "gvfs.yazi";
    version = "unstable-2026-01-06";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "gvfs.yazi";
        rev = "eb51303ccbd5d3446d5616a8e170eed8afe755ac";
        hash = "sha256-hNp/XSbrBuQnCh/TvPUoImLcVWBL3Oz2oSxQJDatxoI=";
    };

    meta = {
        description = "Transparently mount and unmount devices in read/write mode";
        homepage = "https://github.com/boydaihungst/gvfs.yazi";
        license = lib.licenses.mit;
    };
}
