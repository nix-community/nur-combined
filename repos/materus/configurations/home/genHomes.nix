{ inputs, materusFlake, ... }:
let
  profiles = import ../profile;

  hosts = builtins.attrNames materusFlake.nixosConfigurations;
  genHomes = username:
    let
      #Make host specific user profile "username@host"
      _list = builtins.map (host: username + "@" + host) hosts;
      _for = i: (
        let len = builtins.length hosts; in
        ([{
          name = builtins.elemAt _list i;
          value = let host = builtins.elemAt hosts i; in
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = materusFlake.nixosConfigurations.${host}.pkgs;
              extraSpecialArgs = { inherit inputs; inherit materusFlake; };
              modules = [
                ./${username}
                ../host/${host}/extraHome.nix
                profiles.homeProfile
                inputs.private.homeModule

              ];
            };
        }]
        ++ (if ((i + 1) < len) then _for (i + 1) else [ ]))
      );
    in
    (builtins.listToAttrs (_for 0)) // {
      #Make generic x86_64-linux user profile "username"
      ${username} = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs { system = "x86_64-linux"; config = {allowUnfree = true;}; };
        extraSpecialArgs = { inherit inputs; inherit materusFlake; };
        modules = [
          ./${username}
          profiles.homeProfile
          inputs.private.homeModule
        ];
      };
    };

in
genHomes
