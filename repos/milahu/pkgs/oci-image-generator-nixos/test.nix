/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./test.nix { }'
*/

{ stdenv
, lib
, writeShellScript
, jq
, xlibs # xlibs.xorgserver -> Xephyr, Xvfb
, dockerTools
, callPackage
, docker
, podman # todo
, ignite
, pv
, musl
, x11vnc
, openbox
}:

let
  ociTools = callPackage ./default.nix {};

  container-image = ociTools.buildImage {
    #buildLayeredImage {

    /* get imageDigest:
    imageName=docker.io/library/alpine:latest
    imgid=$(buildah from $imageName)
    imageDigest=$(buildah inspect $imgid | jq '.ImageAnnotations."org.opencontainers.image.base.digest"')
    */

    # test compatibility: docker vs OCI
    #fromImage = ociTools.pullImage { # pull image in OCI format
    fromImage = dockerTools.pullImage { # pull image in docker format
      imageName = "docker.io/library/alpine";
      imageDigest = "sha256:69704ef328d05a9f806b6b8502915e6a0a4faa4d72018dc42343f511490daf8a";
      sha256 = "8U9wv86MP0r/nGUegtnjN/qHSvpsLZeZaIwy0qrgGVQ="; # TODO avoid? use only imageDigest?
      #finalImageTag = "alpine-3.12-v3.5.7";
      #finalImageName = "baseimage";
    };

    compress = false; # containerd needs uncompressed image?

    name = "my-container-image";
    tag = "1.0.0";
    contents = [
      musl # libc.musl-x86_64.so.1 - required by alpine?
      x11vnc
      xlibs.xorgserver
      openbox
      jq
    ];
    extraCommands = ''
      echo "hello from extraCommands"

      mkdir appdata
      echo "hello world" >appdata/test.extraCommands.txt
      mkdir output

      # FIXME etc is readonly (mode 0555)
      stat etc
      #stat etc/passwd
      #echo "user:x:1000:100::/approot:/sbin/nologin" >>etc/passwd
      #echo "user:!:18736::::::" >>etc/shadow

      cat >cmd.sh <<'EOF'
      #!/bin/sh
      echo "hello from cmd.sh"
      echo "sleep ..."
      sleep 10000000000
      EOF
      chmod +x cmd.sh # fix: Error: open executable: Permission denied: OCI permission denied
    '';

    config = {
      Cmd = [ "/cmd.sh" ];
      WorkingDir = "/appdata";
      Volumes = {
        "/appdata" = {};
        "/output" = {};
      };
      ExposedPorts = {
        "5900/tcp" = {}; # x11vnc?
        "5920/tcp" = {}; # x11vnc?
      };
      Env = [
        "APP_NAME=MyContainerApp"

        # A user is required by nix
        # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
        #"USER=nobody"
      ];
    };
  };

in

stdenv.mkDerivation rec {
  pname = "my-container-app";
  version = "1.0.0";

  unpackPhase = ":"; # no source

  #    --user 1000:100   # has no effect on: podman run
  podman-run = writeShellScript "podman-run" ''
    PATH=$PATH:${lib.makeBinPath [ podman ]}
    podman run \
      --name=${pname} \
      -p 5920:5920 \
      -p 5900:5900 \
      --user 1000:100 \
      -v /docker/appdata/${pname}:/appdata:rw \
      -v $HOME/Downloads/${pname}:/output:rw \
      --sysctl net.ipv6.conf.all.disable_ipv6=1 \
      --sysctl net.ipv4.ip_forward=1 \
      --cap-add=NET_ADMIN \
      --network=bridge \
      --security-opt=no-new-privileges \
      localhost/${pname}:${version}
  '';

  # missing: ignite load < oci-image.tar
  ignite-run = writeShellScript "ignite-run" ''
    PATH=$PATH:${lib.makeBinPath [ ignite ]}
    # TODO disable auto-pull if not found locally
    sudo ignite run ${pname}:${version}
  '';

  containerd-load = writeShellScript "containerd-load" ''
    PATH=$PATH:${lib.makeBinPath [ podman ]}
    sudo ctr image import ${container-image}
  '';

  podman-load = writeShellScript "podman-load" ''
    PATH=$PATH:${lib.makeBinPath [ podman pv ]}
    pv --width 98 ${container-image} | sudo podman load
  '';

  podman-shell = writeShellScript "podman-shell" ''
    PATH=$PATH:${lib.makeBinPath [ podman ]}
    # TODO get the actual container ID. "podman ps -l" prints the last container
    podman exec -it $(podman ps -lq) sh
  '';

  /*
  # WONTFIX docker: Error response from daemon: No command specified.
  # https://github.com/moby/moby/pull/38738
  # docker cannot load OCI images ...

  docker-load = writeShellScript "docker-load" ''
    PATH=$PATH:${lib.makeBinPath [ docker pv ]}
    pv --width 98 ${container-image} | sudo podman load
    # open /var/lib/docker/tmp/docker-import-657563068/blobs/json: no such file or directory
    sudo docker import ${container-image} ${pname}:${version}
    # docker: Error response from daemon: No command specified.
  '';

  docker-run = writeShellScript "docker-run" ''
    PATH=$PATH:${lib.makeBinPath [ docker ]}
    sudo docker run \
      --name=${pname} \
      -p 5920:5920 \
      -p 5900:5900 \
      --user 1000:100 \
      -v /docker/appdata/${pname}:/appdata:rw \
      -v $HOME/Downloads/${pname}:/output:rw \
      --sysctl net.ipv6.conf.all.disable_ipv6=1 \
      --sysctl net.ipv4.ip_forward=1 \
      --cap-add=NET_ADMIN \
      --network=bridge \
      --security-opt=no-new-privileges \
      ${pname}:${version}
  '';

  docker-shell = writeShellScript "docker-shell" ''
    PATH=$PATH:${lib.makeBinPath [ docker ]}
    # TODO get the actual container ID. "docker ps -l" prints the last container
    sudo docker exec -it $(sudo docker ps -lq) sh
  '';

    cp ${docker-load} $out/bin/${pname}-docker-load
    cp ${docker-run} $out/bin/${pname}-docker-run
    cp ${docker-shell} $out/bin/${pname}-docker-shell
  */

  installPhase = ''
    mkdir -p $out/bin $out/share/applications

    cp ${podman-load} $out/bin/${pname}-podman-load
    cp ${podman-run} $out/bin/${pname}-podman-run
    cp ${podman-shell} $out/bin/${pname}-podman-shell

    cp ${containerd-load} $out/bin/${pname}-containerd-load

    # TODO ignite load? https://github.com/weaveworks/ignite/issues/873
    cp ${ignite-run} $out/bin/${pname}-ignite-run
  '';
}
