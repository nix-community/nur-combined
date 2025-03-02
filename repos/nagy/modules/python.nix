{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: [
      ps.hy
      ps.hyrule
      ps.addict
    ]))
    black
    isort
    ruff
    pyright
  ];
}
