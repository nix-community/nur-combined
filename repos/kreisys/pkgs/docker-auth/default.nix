{ lib, buildGoModule, fetchFromGitHub }:

let
  rev     = "3fb13f1d7eb9bbe0285c3877ed1938e39609e1af";
  version = "1.4.0-17-g${builtins.substring 0 7 rev}";

  repo = fetchFromGitHub {
    inherit rev;
    owner  = "cesanta";
    repo   = "docker_auth";
    sha256 = "1b1rjp6kf37yxbwmx2cbqrm398sywmifvhpw3ls6g5wigqpyp31d";
  };

  src = "${repo}/auth_server";

in buildGoModule {
  inherit src version;

  pname     = "docker_auth";
  modSha256 = "0bxggy2lqh3j4ivfv759nafspzsh5hs0b2w4m6ysvvgdh7if1c7f";

  prePatch = ''
    cat <<EOF > version.go
    package main

    const (
      Version = "${version}"
      BuildId = "0"
    )
    EOF
  '';

  subPackages = [ "." ];

  meta = with lib; {
    description = "Authentication server for Docker Registry 2";
    homepage    = https://github.com/cesanta/docker_auth;
    license     = licenses.asl20;
    platforms   = platforms.linux ++ platforms.darwin;
  };
}
