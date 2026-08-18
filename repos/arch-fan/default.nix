{
  pkgs,
}:

{
  chatgpt = pkgs.callPackage ./pkgs/chatgpt { };
}
