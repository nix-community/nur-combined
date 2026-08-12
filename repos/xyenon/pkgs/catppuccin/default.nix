{
  lib,
  newScope,
  sources,
}:

let
  scope =
    self:
    let
      inherit (self) callPackage;
    in
    {
      kitty = callPackage ./kitty { source = sources.catppuccin-kitty; };
      zsh-fsh = callPackage ./zsh-fsh { source = sources.catppuccin-zsh-fsh; };
    };
in

with lib;
pipe scope [
  (makeScope newScope)
  recurseIntoAttrs
]
