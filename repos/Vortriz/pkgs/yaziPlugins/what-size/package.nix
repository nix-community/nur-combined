{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "what-size.yazi";
    version = "unstable-2026-01-03";

    src = fetchFromGitHub {
        owner = "pirafrank";
        repo = "what-size.yazi";
        rev = "6fd634aa7cea6fea286df05a8b2e9475c22958cb";
        hash = "sha256-Qi95CWehaUpu+4Irwwn+nnxv3NobBCnO+dedDbUFDUs=";
    };
    meta = {
        description = "A plugin for yazi to calculate the size of current selection or current working directory";
        homepage = "https://github.com/pirafrank/what-size.yazi";
        license = lib.licenses.mit;
    };
}
