{ pkgs ? import <nixpkgs> {} }:
let 
  container_name = "ddwt_sql_server";
  sa_password = "YourStrong!Passw0rd";
  pid = "Express";
  pwd = builtins.toString ./.;

  compose_file = ''
    services:
      sqlserver:
        image: mcr.microsoft.com/mssql/server:2022-latest
        container_name: ${container_name}
        environment:
          ACCEPT_EULA: "Y"
          MSSQL_SA_PASSWORD: ${sa_password}
          MSSQL_PID: ${pid}
        ports:
          - "1431:1431"
          - "1433:1433"
        volumes:
          - ${pwd}/mssql:/var/opt/mssql:rw
  '';

in pkgs.mkShell {
  packages = with pkgs; [ podman podman-compose ];

  shellHook = ''
    mkdir -p ${pwd}/mssql
    podman machine init
    podman machine stop
    podman machine start
    echo "${compose_file}" | podman-compose -f /dev/stdin up --force-recreate
    podman machine stop
    echo "${pwd}/mssql"
    exit
  '';
}
