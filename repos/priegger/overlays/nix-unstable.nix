self: super: {
  nixUnstable = super.nixUnstable.overrideAttrs (oldAttrs: rec {
    name = "nix-3.0${suffix}";
    suffix = "pre20200928_649c465";

    src = super.fetchFromGitHub {
      owner = "NixOS";
      repo = "nix";
      rev = "649c465873b20465590d3934fdc0672e4b6b826a";
      sha256 = "0xb2jv24d8n389r58nq6m04ggmgm26ipxy2bsq32hv9zzz6v9317";
    };

    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ super.mdbook ];
    buildInputs = oldAttrs.buildInputs ++ [ super.lowdown ];
  });
}
