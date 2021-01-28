{ dockerTools, elevation_server }:

dockerTools.buildImage {
  name = "elevation_server";
  tag = elevation_server.version;

  contents = [ elevation_server ];
  runAsRoot = "mkdir -p /dem";

  config = {
    Cmd = [ "${elevation_server}/bin/elevation_server" "-dem" "/dem/dem_tiles" "-host" "0.0.0.0" ];
    Volumes = {
      "/dem" = { };
    };
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
}
