{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "hover-after-moved.yazi";
    version = "unstable-2026-04-03";

    src = fetchFromGitHub {
        owner = "boydaihungst";
        repo = "hover-after-moved.yazi";
        rev = "d9b5bafcc36e653dd568553284945ba6b79acc90";
        hash = "sha256-xCC5Q/Z0eABTbZYc5sWmK1+IbTid7Wvp2bjQy1NczKg=";
    };

    meta = {
        description = "Hover over the first file/folder after moved";
        homepage = "https://github.com/boydaihungst/hover-after-moved.yazi";
        license = lib.licenses.mit;
    };
}
