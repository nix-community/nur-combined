{ pkgs, ... }:
{
  sane.programs.kiwix-mcp = {
    packageUnwrapped = pkgs.kiwix-mcp.overrideAttrs (prevAttrs: {
      # article images are shared with the caller by saving to disk and referring to the path name.
      # default is to place them in ~/.cache/kiwix-mcp/images.
      makeWrapperArgs = (prevAttrs.makeWrapperArgs or [ ]) ++ [
        "--set-default"
        "KIWIX_MCP_IMAGE_DIR"
        "/tmp"
      ];
    });

    sandbox.extraPaths = [
      "/tmp" # ^^^ see patch above: this is where kiwix-mcp is configured to place its images.
    ];

    fs.".local/share/kiwix-mcp/archives".symlink.target = pkgs.symlinkJoin {
      name = "kiwix-mcp-archives";
      stripPrefix = "/share/zim";
      paths = [
        # TODO: tune this. not sure if it's better to expose too much or too little here.
        pkgs.zimPackages.alpinelinux_en_all_maxi
        pkgs.zimPackages.archlinux_en_all_maxi
        pkgs.zimPackages.bitcoin_en_all_maxi
        pkgs.zimPackages.devdocs_en_nix
        pkgs.zimPackages.gentoo_en_all_maxi
        # pkgs.zimPackages.khanacademy_en_all  # 80GB of presumably videos; costly
        pkgs.zimPackages.openstreetmap-wiki_en_all_maxi
        pkgs.zimPackages.psychonautwiki_en_all_maxi
        pkgs.zimPackages.rationalwiki_en_all_maxi
        pkgs.zimPackages.wikipedia_en_all_maxi
        pkgs.zimPackages.zimgit-food-preparation_en
        pkgs.zimPackages.zimgit-medicine_en
        pkgs.zimPackages.zimgit-post-disaster_en
        pkgs.zimPackages.zimgit-water_en
      ];
    };

    # persist.byStore.ephemeral = [
    #   ".cache/kiwix-mcp" # images
    # ];
  };
}
