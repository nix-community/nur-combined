{
  config,
  inputs,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: let
    drv = let
      name = "nix-${builtins.replaceStrings ["/"] ["-"] pkgs.nixStore}";
    in
      pkgs.writeScriptBin name (with pkgs; let
        NIX_CONF_DIR = let
          nixConf = pkgs.writeTextDir "opt/nix.conf" ''
            sandbox = true
            auto-optimise-store = true
            allowed-users = *
            system-features = recursive-nix nixos-test benchmark big-parallel kvm
            sandbox-fallback = true
            keep-outputs = true       # Nice for developers
            keep-derivations = true   # Idem
            experimental-features = nix-command flakes recursive-nix ca-derivations
            system-features = recursive-nix nixos-test benchmark big-parallel gccarch-x86-64 kvm
            extra-platforms = i686-linux aarch64-linux
          '';
        in "${nixConf}/opt";
      in ''
        #!${runtimeShell}
        export XDG_CACHE_HOME=$HOME/.cache/${name}
        export PATH=${pkgs.nix}/bin:$PATH
        export NIX_CONF_DIR=${NIX_CONF_DIR}
        export NIX_STORE=${nixStore}/store
        $@
      '');
  in {
    checks.app-nix = drv;
    apps.nix = inputs.flake-utils.lib.mkApp {
      inherit drv;
    };
  };
}
