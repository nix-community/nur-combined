{ self }:
with builtins;
let
  inherit (self.inputs.stable.lib.attrsets) filterAttrs attrValues;
  path = ./. + "/../users";

  # Filter the user standard directory for regular files
  # and consume them assuming they are sets NOT functions
  user-files = filterAttrs (name: value: value == "regular") (readDir path);

  # Given above list of regular files, create an array of the 
  # user configs loaded as set values.
  user-configs =
    attrValues (mapAttrs (name: _: import "${path}/${name}") user-files);

  # Fold set values by the username as the key and set as
  # the value, enabling us to expose this as a top-level 
  # flake construct to be presented once, but available
  # across anything that has access to self/flake. (including external)
  # This means we can reference users and/or generate lists via
  # self.users such as:
  #
  # let cool-users = with self.users [ jay ]; in ...
  #
  # Alternatively via inherit:
  # inherit (self.users) jay;
  # let cool-users = [ jay ]; in ...
  # 
  # To see this more interactively use the repl:
  # $ nix repl
  # nix-repl> :lf .
  # nix-repl> users.jay                      
  # { extraGroups = [ ... ]; initialHashedPassword = ""; isNormalUser = true; name = "jay"; openssh = { ... }; }
  users = foldl' (x: y: x // { ${y.name} = y; }) { } user-configs;
in users
