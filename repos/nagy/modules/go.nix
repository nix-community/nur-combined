{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.go
    pkgs.gopls

    pkgs.ginkgo

    pkgs.golangci-lint

    # Debugger
    pkgs.delve
    # pkgs.gdlv
  ];

  environment.sessionVariables = {
    # https://go.dev/doc/telemetry
    GOTELEMETRY = "off";

    # GOPLS_CACHE = "/run/user/''$(id -u)/gopls";
    # This syntax is used for PAM
    # GOPLSCACHE = "''$\{XDG_RUNTIME_DIR}/gopls";
    GOPLSCACHE = "$\{XDG_RUNTIME_DIR}/gopls";
    GOMODCACHE = "$\{XDG_RUNTIME_DIR}/go/pkg/mod";
    GOCACHE = "$\{XDG_RUNTIME_DIR}/go-build";
  };

  # programs.bash.interactiveShellInit = ''
  #   export GOPLS_CACHE="/run/user/$(id -u)/gopls"
  # '';

}
