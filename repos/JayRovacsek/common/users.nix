{ self }:
with builtins;
let
  inherit (self.lib) generate-user-config;
  inherit (self.common) base-users;
  # The below will create a flake accessible lambda per user
  # that requires input of the packageset so that
  # system shell is correctly set, otherwise we could avoid this 
  # lambda structure and just define users in a static way.
  #
  # Consuming this should be as easy as per supported system package-set
  # just passing the set:
  #
  # nix-repl> :lf .                                    
  # nix-repl> pkgs = nixosConfigurations.alakazam.pkgs 
  # nix-repl> jay = common.users.jay { inherit pkgs; }

  fn = mapAttrs (name: user-settings:
    { config, pkgs, modules ? [ ], overrides ? { } }:
    let flake = self;
    in generate-user-config {
      inherit pkgs modules user-settings config overrides flake;
    }) base-users;
in fn
