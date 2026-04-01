{
  buildNpmPackage,
  fetchFromGitHub,
  grim,
  hyprland,
  lib,
  makeWrapper,
  wtype,
  ydotool,
}:
let
  pname = "hyprland-mcp-server";
  rev = "ff287c5f3e5a3b50ed340c6fad98716db6ea8bad";
in
buildNpmPackage rec {
  inherit pname;
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "rodsilvavieira2";
    repo = pname;
    inherit rev;
    hash = "sha256-nRjsZ7x9oetM9wEe01FazfelNSKPa/dIfo031Opp3cc=";
  };

  npmDepsHash = "sha256-Ro6c1rH7Rlmy1xF+EIQeUqWrqsZ/p7x4EC1LlldcX5E=";

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram "$out/bin/${pname}" \
      --prefix PATH : "${
        lib.makeBinPath [
          hyprland
          grim
          wtype
          ydotool
        ]
      }"
  '';

  meta = with lib; {
    description = "MCP server to control Hyprland via natural language";
    homepage = "https://github.com/rodsilvavieira2/hyprland-mcp-server";
    license = [ ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = pname;
  };
}
