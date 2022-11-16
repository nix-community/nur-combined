{ sources, lib, buildFishPlugin }:

buildFishPlugin rec {
  inherit (sources.plugin-bang-bang) pname version src;

  meta = with lib; {
    description = "Bash style history substitution for Oh My Fish";
    homepage = "https://github.com/oh-my-fish/plugin-bang-bang";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
