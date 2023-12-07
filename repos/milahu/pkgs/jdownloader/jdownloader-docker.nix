# https://hub.docker.com/r/jlesage/jdownloader-2/

{ lib
, pkgs
, stdenv
, dockerTools
, fetchurl
, fetchFromGitHub
, writeScript
, writeShellScript
, jre
, makeWrapper
, jq
, docker
, buildPackages
, callPackage
, pv
}:

let

  # https://hub.docker.com/r/jlesage/jdownloader-2/
  docker-image-jdownloader-backend = dockerTools.pullImage {
    # FIXME this is slow. "Storing signatures" takes forever
    # FIXME glibc version mismatch -> openbox breaks
    imageName = "jlesage/jdownloader-2";
    imageDigest = "sha256:7cc834fa09fcbb9852502719927739db6d4f2484e95d689a7de96c92273e6801";
    sha256 = "sha256-4+Idly5+hVdbZA9/w+9satrfLKZwoT1c7+fX3VVb8UI=";
    #finalImageTag = "alpine-3.12-v3.5.7";
    #finalImageName = "jdownloader-2";
  };

  /*
  docker-image-jdownloader-backend = stdenv.mkDerivation rec {
    pname = "docker-jdownloader";
    version = "85956e0";
    src = fetchFromGitHub {
      owner = "jlesage";
      repo = "docker-jdownloader-2";
      rev = "85956e01d948b7788c66a158bb5287fc5acffd75";
      sha256 = "12sxap2wqld646ssfcg6g4py6q8fgwmnaw5g0j8759nggipassq3";
    };
    installPhase = ''
      cd ..
      mv source $out
    '';
  };
  */

  /*
  get imageDigest

  https://hub.docker.com/r/jlesage/baseimage-gui/tags

  imageName = "jlesage/baseimage-gui";
  tag=alpine-3.12-v3.5.7

  token=$(curl --silent "https://auth.docker.io/token?scope=repository:$image:pull&service=registry.docker.io"  | jq -r '.token')
  curl -s --header "Accept: application/vnd.docker.distribution.manifest.list.v2+json" --header "Authorization: Bearer ${token}" "https://registry-1.docker.io/v2/$imageName/manifests/$tag" \
  | jq

  | jq -r '.manifests|.[]| "\(.digest) \(.platform.architecture) \(.platform.variant)"'
  */

  myJDownloaderPort = 3129; # For MyJDownloader in Direct Connection mode.

in

stdenv.mkDerivation rec {
  pname = "jdownloader";
  version = "autoupdate";

  dontUnpack = true;

  jdownloader-docker-run = writeShellScript "jdownloader-docker-run" ''
    PATH=$PATH:${lib.makeBinPath [ docker ]}
    docker run \
      --name=jdownloader-backend \
      -p 5800:5800 \
      -p 9665:9665 \
      -p 5920:5920 \
      -p 5900:5900 \
      --user 1000:100 \
      -v /docker/appdata/jdownloader-backend:/appdata:rw \
      -v $HOME/Downloads/jdownloader:/output:rw \
      --sysctl net.ipv6.conf.all.disable_ipv6=1 \
      --sysctl net.ipv4.ip_forward=1 \
      --cap-add=NET_ADMIN \
      --add-host host.docker.internal:host-gateway \
      --network=bridge \
      --security-opt=no-new-privileges \
      jdownloader-backend:autoupdate
  '';

  jdownloader-docker-load = writeShellScript "jdownloader-docker-load" ''
    PATH=$PATH:${lib.makeBinPath [ docker pv ]}
    du -h ${docker-image-jdownloader-backend}
    echo "parsing image ..."
    pv --width 98 ${docker-image-jdownloader-backend} | docker load
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    cp ${jdownloader-docker-load} $out/bin/jdownloader-docker-load
    cp ${jdownloader-docker-run} $out/bin/jdownloader-docker-run
  '';
}
