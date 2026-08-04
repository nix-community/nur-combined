{ starship }:

starship.overrideAttrs (oldAttrs: {
  pname = "starship-patched";

  patches = (oldAttrs.patches or [ ]) ++ [
    ./hide-command-timeout-warnings.patch
  ];
})
