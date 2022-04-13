{ sources, poetry2nix, lib }:

poetry2nix.mkPoetryApplication rec {
  inherit (sources.nix-gc-s3) pname version src;
  projectDir = src;
  pyproject = ./pyproject.toml;
  poetrylock = ./poetry.lock;

  overrides = poetry2nix.overrides.withDefaults (self: super: {
    # TODO remove when fixed
    pyparsing = super.pyparsing.overrideAttrs (old: {
      propagatedBuildInputs = [
        self.flit-core
      ];
    });
    # TODO just a workaround
    # poetryup is just a dev dependency
    # and it is currently broken
    poetryup = self.pyparsing;
  });

  meta = with lib; {
    homepage = "https://github.com/linyinfeng/nix-gc-s3";
    description = "A naive tool to perform garbage collecting on nix S3 stores";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}
