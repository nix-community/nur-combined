{
  pkgs,
  ...
}: let
  dotnetSdk = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_6_0-bin
    pkgs.dotnetCorePackages.sdk_8_0-bin
    pkgs.dotnetCorePackages.sdk_9_0-bin
    pkgs.dotnetCorePackages.sdk_10_0-bin
    pkgs.dotnetCorePackages.sdk_11_0-bin
  ];
in {
  environment.systemPackages = with pkgs; [
    dotnetSdk # Keep multiple SDK generations available for projects with different targets.
    csharpier
    ilspycmd # Tool for decompiling .NET assemblies and generating portable PDBs
  ];

  home-manager.sharedModules = [
    ({...}: {
      home.sessionVariables = {
        DOTNET_ROOT = "${dotnetSdk}/share/dotnet";
      };
    })
  ];
}
