{ inputs }:

let
  inherit (inputs) sab;
  sab-overlay = final: prev: { stream-alert-bot = sab.packages.${prev.system}.default; };

in sab-overlay
