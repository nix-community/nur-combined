{ config, pkgs, ... }:
{
  sane.programs.where-am-i = {
    # packageUnwrapped = pkgs.linkIntoOwnPackage config.sane.programs.geoclue2.packageUnwrapped "libexec/geoclue-2.0/demos/where-am-i" {};
    packageUnwrapped = pkgs.writeSymlinkFile {
      # bring the `where-am-i` tool into a `bin/` directory so it can be invokable via PATH
      path = "bin/where-am-i";
      contents = "${config.sane.programs.geoclue2.packageUnwrapped}/libexec/geoclue-2.0/demos/where-am-i";
      nativeBuildInputs = [
        pkgs.makeWrapper
      ];
      # TODO: set up portal-based location services.
      # until then disable portals here.
      postBuild = ''
        wrapProgram $out/bin/where-am-i \
          --unset GIO_USE_PORTALS
      '';
    };

    sandbox.net = "all";  # TODO: why does it require this? i think it just needs *some* net dev and any will do.
    sandbox.whitelistDbus.system = true;  # system is required for non-portal location services
  };
}
