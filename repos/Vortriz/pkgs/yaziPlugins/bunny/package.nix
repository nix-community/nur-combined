{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "bunny.yazi";
    version = "unstable-2026-10-20";

    src = fetchFromGitHub {
        owner = "stelcodes";
        repo = "bunny.yazi";
        rev = "8f3f84e20ea0545d032c134cf184784eaff55d13";
        hash = "sha256-AX7ILZTXPKqvEI3jgVADsfVeSR39qHB7Ti6NGHL0yag=";
    };

    meta = {
        description = "Bookmarks menu for yazi with persistent and ephemeral bookmarks, fuzzy searching, previous directory, directory from another tab";
        homepage = "https://github.com/stelcodes/bunny.yazi";
        license = lib.licenses.mit;
    };
}
