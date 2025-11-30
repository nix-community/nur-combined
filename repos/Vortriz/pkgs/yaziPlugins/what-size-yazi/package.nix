{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "what-size-yazi";
    version = "0-unstable-2025-06-19";

    src = fetchFromGitHub {
        owner = "pirafrank";
        repo = "what-size.yazi";
        rev = "d8966568f2a80394bf1f9a1ace6708ddd4cc8154";
        hash = "sha256-s2BifzWr/uewDI6Bowy7J+5LrID6I6OFEA5BrlOPNcM=";
    };
    meta = {
        description = "A plugin for yazi to calculate the size of current selection or current working directory";
        homepage = "https://github.com/pirafrank/what-size.yazi";
        license = lib.licenses.mit;
    };
}
