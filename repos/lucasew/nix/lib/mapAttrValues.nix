{ lib }:
fn: data:
builtins.mapAttrs (k: v: fn v) data
