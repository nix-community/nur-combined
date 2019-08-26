{ pkgs }:

let

  hm = import ./src.nix { lib = pkgs.lib; };

  hmDocs = import "${hm}/doc" { inherit pkgs; };

in

{
  html-manual = hmDocs.manual.html;
  json-options = hmDocs.options.json;
  man-pages = hmDocs.manPages;
}
