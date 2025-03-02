{ dockerTools, elevation-server }:

dockerTools.buildImage {
  name = "elevation-server";
  tag = elevation-server.version;

  contents = [ elevation-server ];
  runAsRoot = "mkdir -p /dem";

  config = {
    Cmd = [
      "elevation_server"
      "-dem"
      "/dem/dem_tiles"
      "-host"
      "0.0.0.0"
    ];
    Volumes = {
      "/dem" = { };
    };
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
}
