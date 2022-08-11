{
  pkgs,
  sources,
}: let
  nodeDeps = pkgs.callPackage ./node2nix/default.nix {nodejs = pkgs.nodejs-14_x;};
in {
  tailwindcss-language-server = nodeDeps."@tailwindcss/language-server";
}
