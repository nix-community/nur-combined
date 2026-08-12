{
  pidgin,
  purple-discord,
  purple-slack,
  purple-matrix,
}:
let
  plugins = [
    purple-discord
    purple-slack
    purple-matrix
  ];
in

pidgin.override { inherit plugins; }
# pidgin.withPlugins (p: with p; [purple-discord purple-slack purple-matrix])
