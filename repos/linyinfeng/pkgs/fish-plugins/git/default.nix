{ sources, lib, buildFishPlugin }:

buildFishPlugin rec {
  inherit (sources.plugin-git) pname version src;

  meta = with lib; {
    description = "Git plugin for Oh My Fish";
    homepage = "https://github.com/TimothyYe/godns";
    license = licenses.mit;
  };
}
