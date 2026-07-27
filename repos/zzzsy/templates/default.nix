{
  flake.templates =
    let
      templates = [
        "rust"
        "hugo"
        "slidev"
        "zig"
        # "python"
        "typst"
      ];
    in
    builtins.listToAttrs (
      map (name: {
        name = name;
        value = {
          path = ./${name};
          description = "Development environment flake for ${name}";
        };
      }) templates
    );
}
