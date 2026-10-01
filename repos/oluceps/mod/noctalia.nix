{ inputs, ... }:
{

  flake.modules.nixos.noctalia =
    { pkgs, ... }:
    {
      # hjem = {
      #   extraModules = [
      #     inputs.noctalia.hjemModules.default
      #   ];

      #   users.drfoobar = {
      #     programs.noctalia = {
      #       enable = true;

      #       # settings = { ... };
      #     };
      #   };
      # };
      imports = [
        inputs.noctalia.nixosModules.default
      ];
      # enable the systemd service
      programs.noctalia = {
        enable = true;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace src/shell/lockscreen/lock_screen.cpp \
              --replace-fail 'const std::string pamService = "login";' 'const std::string pamService = "noctalia";'
          '';
        });

        # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
        recommendedServices.enable = true;
        systemd.enable = true;
      };
    };
}
