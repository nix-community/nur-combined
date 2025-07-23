{
  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      files.files = [
        {
          path_ = "README.md";
          drv =
            let
              nameMkContentPair = name: mkContent: {
                inherit name;
                inherit mkContent;
              };

              columns = [
                (nameMkContentPair "Name" (p: p.pname))
                (nameMkContentPair "Description" (p: p.meta.description))
                (nameMkContentPair "Version" (p: p.version))
                (nameMkContentPair "Homepage" (p: if p ? meta.homepage then "[Link](${p.meta.homepage})" else ""))
              ];

              mkTableRow =
                package:
                let
                  contents = map (c: c.mkContent package) columns;
                in
                "| ${lib.concatStringsSep " | " contents} |";

              tableRows = map mkTableRow (builtins.attrValues self'.packages);

              tableMarkdown = ''
                | ${lib.concatStringsSep " | " (map (c: c.name) columns)} |
                | ${lib.concatStringsSep " | " (map (_c: "---") columns)} |
                ${lib.concatStringsSep "\n" tableRows}
              '';
            in
            pkgs.writeText "README.md" ''
              # nur-packages

              **My personal [NUR](https://github.com/nix-community/NUR) repository**

              [![Check, build and cache](https://github.com/fym998/nur-packages/actions/workflows/build.yml/badge.svg)](https://github.com/fym998/nur-packages/actions/workflows/build.yml)
              [![Cachix Cache](https://img.shields.io/badge/cachix-fym998--nur-blue.svg)](https://fym998-nur.cachix.org)

              ## Packages

              ${tableMarkdown}
            '';
        }
      ];
    };
}
