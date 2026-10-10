{
  pkgs ? import <nixpkgs> { },
  package ? (import ../../default.nix { inherit pkgs; }).rsshub,
}:
let
  configuration =
    (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      inherit pkgs;
      modules = [
        {
          services.rsshub = {
            enable = true;
            inherit package;
            openFirewall = false;
            redis.enable = true;
            settings = {
              LISTEN_INADDR_ANY = true;
              PORT = 1201;
            };
            secretFiles = [ "/run/agenix/rsshub-access" ];
          };
        }
      ];
    }).config;
  service = configuration.systemd.services.rsshub;
  overridden = package.overrideAttrs {
    version = "2026.10.11-8411.abcdef0";
    __intentionallyOverridingVersion = true;
  };
in
assert package.src.tag == "v${package.version}";
assert overridden.src.tag == "v2026.10.11-8411.abcdef0";
assert builtins.elem "rsshub" (builtins.attrNames (import ../../default.nix { pkgs = null; }));
assert
  !pkgs.stdenv.hostPlatform.isLinux
  || (
    service.serviceConfig.ExecStart == pkgs.lib.getExe package
    && service.environment.PORT == "1201"
    && service.environment.LISTEN_INADDR_ANY == "1"
    && service.environment.CACHE_TYPE == "redis"
    && service.environment.REDIS_URL == "redis://localhost:6379"
    && service.serviceConfig.EnvironmentFile == [ "/run/agenix/rsshub-access" ]
    && builtins.elem "redis-rsshub.service" service.requires
    && configuration.services.redis.servers.rsshub.enable
    && !(builtins.elem 1201 configuration.networking.firewall.allowedTCPPorts)
  );
pkgs.runCommand "rsshub-package-check"
  {
    nativeBuildInputs = [ pkgs.python3 ];
  }
  ''
    test -x ${package}/bin/rsshub
    test -f ${package}/lib/rsshub/dist/index.mjs
    test -d ${package}/lib/rsshub/dist/assets
    test -d ${package}/lib/rsshub/lib/assets
    python3 ${./rsshub.py} ${package}
    touch "$out"
  ''
