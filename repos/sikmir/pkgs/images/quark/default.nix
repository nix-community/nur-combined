{ dockerTools, quark }:

dockerTools.buildImage {
  name = "quark";
  tag = quark.version;

  contents = [ dockerTools.fakeNss quark ];
  runAsRoot = "mkdir -p /htdocs";

  config = {
    Cmd = [ "quark" "-h" "0.0.0.0" "-p" "8080" "-g" "nobody" "-l" ];
    WorkingDir = "/htdocs";
    Volumes = {
      "/htdocs" = { };
    };
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
}
