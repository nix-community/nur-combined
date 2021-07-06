self: super: let
  arc = import ../canon.nix { inherit self super; };
  _internal = super.arc._internal or { } // {
    overrides = {
      inherit super;
    };
  };
in arc.super.arc.packages.extendWithOverrides self (super.arc._internal.overrides.super or super) // {
  arc = super.arc or { } // {
    inherit _internal;
  };
}
