{ sources, lib, buildFishPlugin }:

buildFishPlugin rec {
  inherit (sources.pisces) pname version src;

  meta = with lib; {
    description = "Fish shell plugin that helps you to work with paired symbols in the command line";
    homepage = "https://github.com/laughedelic/pisces";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
