{ inputs }:

let
  inherit (inputs.nixpkgs.lib)
    getBin
    mapAttrsToList
    mkForce
    optionals
    ;

  generateFjWrappedBinConfig =
    {
      pkg,
      pkg_name,
      bin_name ? pkg_name,
      enable_desktop ? false,
      desktop_file_name ? pkg_name,
    }:

    let
      path = "${getBin pkg}";
    in
    {
      executable = "${path}/bin/${bin_name}";
    }
    // (optionals enable_desktop) {
      desktop = "${path}/share/applications/${desktop_file_name}.desktop";
    };
in
self
