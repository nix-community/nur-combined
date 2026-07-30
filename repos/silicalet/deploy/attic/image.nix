{ pkgs }:

pkgs.dockerTools.buildLayeredImage {
  name = "atticd";
  tag = "latest";

  contents = [
    pkgs.attic-server
    pkgs.cacert
  ];

  extraCommands = ''
    mkdir -p etc/attic var/lib/atticd/storage tmp
    cp ${./server.toml} etc/attic/server.toml

    cat > etc/passwd <<'EOF'
    atticd:x:1000:1000:Attic server:/var/lib/atticd:/sbin/nologin
    EOF

    cat > etc/group <<'EOF'
    atticd:x:1000:
    EOF

    chmod 1777 tmp
  '';

  fakeRootCommands = ''
    chown -R 1000:1000 var/lib/atticd
  '';

  config = {
    User = "1000:1000";
    Env = [
      "HOME=/var/lib/atticd"
      "PATH=${pkgs.lib.makeBinPath [ pkgs.attic-server ]}"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Entrypoint = [ "${pkgs.attic-server}/bin/atticd" ];
    Cmd = [
      "--config"
      "/etc/attic/server.toml"
    ];
    ExposedPorts = {
      "8080/tcp" = { };
    };
    Volumes = {
      "/var/lib/atticd" = { };
    };
  };
}
