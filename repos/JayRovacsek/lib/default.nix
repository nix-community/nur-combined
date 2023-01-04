{ pkgs }: {
  upstream-supported = { system, packages }:
    if builtins.hasAttr system packages then
      packages.${system}.default
    else
      { };
}
