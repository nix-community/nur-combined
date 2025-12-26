{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "hover-after-moved.yazi";
    version = "unstable-2025-12-26";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "hover-after-moved.yazi";
        rev = "65b67483d50412db389d6dbb8bff207175368cc9";
        hash = "sha256-uvLEI+JdhHa42cvZakvmq5eGsi++VIdG8lRLKIYiKo4=";
    };

    meta = {
        description = "Hover over the first file/folder after moved";
        homepage = "https://github.com/boydaihungst/hover-after-moved.yazi";
        license = lib.licenses.mit;
    };
}
