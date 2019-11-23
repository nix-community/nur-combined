{ sources, lib, buildGoModule, fetchFromGitHub, python }:

let
  inherit (sources.docker_auth) rev;

in buildGoModule rec {
  pname   = "docker_auth";
  version = "1.4.0-18-g${builtins.substring 0 7 rev}";

  buildInputs = [ python ];

  src = sources.docker_auth;

  modSha256 = "0jhlkd41z5b52dkns56h92fp6wr0gcl19jhgvigmbl84vanyz2ml";

  sourceRoot = "source/auth_server";
  overrideModAttrs = _: { inherit sourceRoot; };

  postConfigure = ''
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
