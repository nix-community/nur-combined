{ pkgs }:

pkgs.lib.extend (
  self: super: with super; {
    # Add your library functions here
    #
    # hexint = x: hexvals.${toLower x};

    # Get packages with upgrade script
    packagesWithUpdateScript = filterAttrs (k: v: v ? passthru && v.passthru ? updateScript) (
      import ../pkgs { inherit pkgs; }
    );
  }
)
