{
    lib,
    mkYaziPlugin,
    fetchFromGitHub,
}:
mkYaziPlugin {
    pname = "what-size.yazi";
    version = "unstable-2026-01-02";

    src = fetchFromGitHub {
        owner = "pirafrank";
        repo = "what-size.yazi";
        rev = "a1438d488fefc2cf578fd1df1aeb66411de53d22";
        hash = "sha256-s2BifzWr/uewDI6Bowy7J+5LrID6I6OFEA5BrlOPNcM=";
    };
    meta = {
        description = "A plugin for yazi to calculate the size of current selection or current working directory";
        homepage = "https://github.com/pirafrank/what-size.yazi";
        license = lib.licenses.mit;
    };
}
