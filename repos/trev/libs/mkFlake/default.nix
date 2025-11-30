{
  systems ? [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
  ],
}:
let
  # Ignore flake output attributes that are not per-system.
  ignoredAttrs = [
    "libs"
    "overlays"
    "nixosModules"
    "nixosConfigurations"
    "hydraJobs"
    "templates"
  ];

  # Applies a merge operation across systems.
  eachSystemOp =
    op: systems: f:
    builtins.foldl' (op f) { } (
      if !builtins ? currentSystem || builtins.elem builtins.currentSystem systems then
        systems
      else
        # Add the current system if the --impure flag is used.
        systems ++ [ builtins.currentSystem ]
    );
in
# Builds a map from <attr>.value to <attr>.<system>.value for each system.
eachSystemOp (
  # Merge outputs for each system.
  f: attrs: system:
  let
    ret = f system;
  in
  builtins.foldl' (
    attrs: key:
    if builtins.elem key ignoredAttrs then
      # Bypass setting <system>
      attrs
      // {
        ${key} = (attrs.${key} or { }) // ret.${key};
      }
    else
      # Set as <attr>.<system>.value
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} = ret.${key};
        };
      }
  ) attrs (builtins.attrNames ret)
) systems
