{ sources, lib, buildFishPlugin }:

buildFishPlugin rec {
  inherit (sources.replay-fish) pname version src;

  meta = with lib; {
    description = "Run Bash commands replaying changes in Fish";
    homepage = "https://github.com/jorgebucaran/replay.fish";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
