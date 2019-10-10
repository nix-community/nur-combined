{ lib, buildGoModule, fetchFromGitHub, python }:

let
  rev     = "3fb13f1d7eb9bbe0285c3877ed1938e39609e1af";

in buildGoModule rec {
  pname   = "docker_auth";
  version = "1.4.0-17-g${builtins.substring 0 7 rev}";

  buildInputs = [ python ];
  src = fetchFromGitHub {
    inherit rev;
    owner  = "cesanta";
    repo   = "docker_auth";
    sha256 = "1b1rjp6kf37yxbwmx2cbqrm398sywmifvhpw3ls6g5wigqpyp31d";
  };

  modSha256 = "0bxggy2lqh3j4ivfv759nafspzsh5hs0b2w4m6ysvvgdh7if1c7f";

  postConfigure = ''
    cd auth_server

    cat <<EOF > version.go
    package main

    const (
      Version = "${version}"
      BuildId = "0"
    )
    EOF

    cat <<EOF > gen_version.py
    #!/bin/sh
    true
    EOF
    chmod +x gen_version.py

    make generate
  '';

  subPackages = [ "." ];

  meta = with lib; {
    description = "Authentication server for Docker Registry 2";
    homepage    = https://github.com/cesanta/docker_auth;
    license     = licenses.asl20;
    platforms   = platforms.linux ++ platforms.darwin;
  };
}
