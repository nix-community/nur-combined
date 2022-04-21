{
  description = "Some NUR repository with CUDA";

  inputs.some-pkgs.url = "..";
  inputs.some-pkgs.inputs.nixpkgs.follows = "nixpkgs-unfree";
  inputs.nixpkgs-unfree.url = github:SomeoneSerge/nixpkgs-unfree/nixpkgs-unstable;

  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  outputs = { self, nixpkgs-unfree, some-pkgs }: some-pkgs;
}
