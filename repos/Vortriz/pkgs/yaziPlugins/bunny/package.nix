{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "bunny.yazi";
    version = "unstable-2026-03-08";

    src = fetchFromGitHub {
        owner = "stelcodes";
        repo = "bunny.yazi";
        rev = "71b14a3d624572f4884354c2e218296e9ece07cc";
        hash = "sha256-uQO0C00yOFPWq8KEO/kEZM6tFZRc9SiXfgN7kzlwDeA=";
    };

    meta = {
        description = "Bookmarks menu for yazi with persistent and ephemeral bookmarks, fuzzy searching, previous directory, directory from another tab";
        homepage = "https://github.com/stelcodes/bunny.yazi";
        license = lib.licenses.mit;
    };
}
