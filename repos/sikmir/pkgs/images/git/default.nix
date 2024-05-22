{ dockerTools, git }:

dockerTools.buildImage {
  name = "git";
  tag = git.version;

  contents = [ git ];
  runAsRoot = "mkdir -p /git";

  config = {
    Cmd = [
      "git"
      "daemon"
      "--base-path=/git"
    ];
    Volumes = {
      "/git" = { };
    };
    ExposedPorts = {
      "9418/tcp" = { };
    };
  };
}
