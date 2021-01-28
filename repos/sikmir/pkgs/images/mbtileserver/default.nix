{ dockerTools, mbtileserver }:

dockerTools.buildImage {
  name = "mbtileserver";
  tag = mbtileserver.version;

  contents = [ mbtileserver ];
  runAsRoot = "mkdir -p /tilesets";

  config = {
    Cmd = [ "${mbtileserver}/bin/mbtileserver" "--enable-reload" ];
    Volumes = {
      "/tilesets" = { };
    };
    ExposedPorts = {
      "8000/tcp" = { };
    };
  };
}
