{ lib }:

final: prev:

with final;

let
  callPackage = prev.newScope (
    final
    // {
      emacsPackages = prev.emacsPackages.overrideScope emacsPackagesOverlay;
      linuxPackages = prev.linuxPackages.extend linuxModulesOverlay;
    }
    // (builtins.foldl' (
      acc: name:
      if builtins.match "python3[0-9]+Packages" name != null then
        acc
        // {
          ${name} = prev.${name}.overrideScope pythonModulesOverlay;
        }
      else
        acc
    ) { } (builtins.attrNames prev))
  );

  emacsPackagesOverlay = import ./applications/editors/emacs/elisp-packages/manual-packages {
    inherit lib;
    pkgs = final;
  };

  linuxModulesOverlay = import ./os-specific/linux/modules.nix {
    inherit lib;
    pkgs = final;
  };

  pythonModulesOverlay = import ./development/python-modules {
    inherit lib;
    pkgs = final;
  };
in

# Automatically import packages in ./by-name
(lib.foldlAttrs
  (
    acc: _: attrs:
    acc // attrs
  )
  { }
  (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./by-name;
    }
  )
)

# Automatically reflect upstream supported python package sets
// (builtins.foldl' (
  acc: name:
  if builtins.match "python3[0-9]+Packages" name != null then
    acc
    // {
      ${name} = (lib.fix (self: pythonModulesOverlay (prev.${name} // self) prev.${name})) // {
        recurseForDerivations = prev.${name}.recurseForDerivations or false;
      };
    }
  else
    acc
) { } (builtins.attrNames prev))

# Manually defined packages
// {
  inherit callPackage;

  cec-sync = callPackage ./by-name/ce/cec-sync/package.nix {
    libcec = libcec.overrideAttrs (
      finalAttrs: prevAttrs: {
        version = "7.1.1";
        src = fetchFromGitHub {
          owner = "Pulse-Eight";
          repo = "libcec";
          rev = "libcec-${finalAttrs.version}";
          sha256 = "sha256-t8GUQKWTcxjyaAlsTP4C+heYiVYowG7x+fmjHPND7As=";
        };
      }
    );
  };

  emacsPackages = lib.recurseIntoAttrs (
    emacsPackagesOverlay (prev.emacsPackages // emacsPackages) prev.emacsPackages
  );

  jakirica-client = jakirica.client;

  linuxPackages = lib.recurseIntoAttrs (
    linuxModulesOverlay (prev.linuxPackages_latest // linuxPackages) prev.linuxPackages_latest
  );

  zynaddsubfx-fltk = zynaddsubfx.override { guiModule = "fltk"; };

  zynaddsubfx-ntk = zynaddsubfx.override { guiModule = "ntk"; };
}
