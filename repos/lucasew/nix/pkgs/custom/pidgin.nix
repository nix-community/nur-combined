{ pidgin
, purple-discord
, purple-slack
, purple-matrix
, }:
pidgin.override {
  plugins = [
    purple-discord
    purple-slack
  ];
}
