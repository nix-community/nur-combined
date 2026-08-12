{ inputs, lib, ... }: {
  catppuccin = {
    enable = lib.mkDefault true;
    autoEnable = lib.mkDefault true;
    flavor = lib.mkDefault "frappe";
    accent = lib.mkDefault "red";
    # Avoid IFD: upstream module imports the theme TOML from the
    # whiskers-built package at eval time, which cannot be built when
    # evaluating for a foreign platform (CI evaluates darwin configs
    # on x86_64-linux). Use the raw port source instead.
    sources.starship = lib.mkDefault "${inputs.catppuccin-starship}/themes";
    sources.rio = lib.mkDefault "${inputs.catppuccin-rio}/themes";
  };
}
