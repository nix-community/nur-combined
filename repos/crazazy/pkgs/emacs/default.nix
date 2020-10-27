{ pkgs, sources, fetchzip }:
let
  emacsSrc = (fetchzip { inherit (sources.emacs) url sha256; });
in
  import emacsSrc { inherit pkgs; }
