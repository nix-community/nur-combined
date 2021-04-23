{ lib, ... }:
let
  inherit (lib) filterAttrs mapAttrs';
in
{
  mapFilterAttrs = pred: f: attrs: filterAttrs pred (mapAttrs' f attrs);
}
