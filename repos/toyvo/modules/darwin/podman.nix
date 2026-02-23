{
  config,
  pkgs,
  lib,
  ...
}:
{
  # darwin port to enable podman and symlink to docker
  options.virtualisation.podman = {
    enable = lib.mkEnableOption "This option enables Podman, a daemonless container engine for developing, managing, and running OCI Containers on your System.";
    dockerCompat = lib.mkEnableOption "Create an alias mapping docker to podman.";
  };

  config = lib.mkIf config.virtualisation.podman.enable {
    environment.systemPackages =
      with pkgs;
      [
        podman
        vfkit
      ]
      ++ lib.optionals config.virtualisation.podman.dockerCompat [
        (runCommand "${podman.pname}-docker-compat-${podman.version}"
          {
            outputs = [
              "out"
              "man"
            ];
            inherit (podman) meta;
          }
          ''
            mkdir -p $out/bin
            ln -s ${lib.getExe podman} $out/bin/docker

            mkdir -p $man/share/man/man1
            for f in ${podman.man}/share/man/man1/*; do
              basename=$(basename $f | sed s/podman/docker/g)
              ln -s $f $man/share/man/man1/$basename
            done
          ''
        )
      ];
  };
}
