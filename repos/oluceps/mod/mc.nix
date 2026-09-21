{
  flake.modules.nixos.mc =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {

      virtualisation.oci-containers.containers."mc-server-new-steam-trip" = {
        image = "container-registry.oracle.com/graalvm/jdk:21";
        ports = [ "25565:25565" ];
        volumes = [
          "/var/lib/new-steam-trip:/data"
        ];
        workingDir = "/data";
        cmd = [
          "sh"
          "run.sh"
        ];
      };
    };
}
