# The importApply argument. Use this to reference things defined locally,
# as opposed to the flake where this is imported.
localFlake:

# Regular module arguments; self, inputs, etc all reference the final user flake,
# where this module was imported.
{ lib, config, self, inputs, ... }:
{
  perSystem = { system, ... }: {
    # A copy of hello that was defined by this flake, not the user's flake.
    packages.packwiz = localFlake.withSystem system ({ config, ... }:
      config.packages.default
    );
  };
}