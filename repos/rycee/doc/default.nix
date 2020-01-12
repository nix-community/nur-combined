{ pkgs }:

let

  lib = pkgs.lib;

  nmdSrc = pkgs.fetchFromGitLab {
    name = "nmd";
    owner = "rycee";
    repo = "nmd";
    rev = "9751ca5ef6eb2ef27470010208d4c0a20e89443d";
    sha256 = "0rbx10n8kk0bvp1nl5c8q79lz1w0p1b8103asbvwps3gmqd070hi";
  };

  nmd = import nmdSrc { inherit pkgs; };

  # Make sure the used package is scrubbed to avoid actually
  # instantiating derivations.
  scrubbedPkgsModule = {
    imports = [
      {
        _module.args = {
          pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
          pkgs_i686 = lib.mkForce { };
        };
      }
    ];
  };

  hmModulesDocs = nmd.buildModulesDocs {
    modules =
      [ ../hm-modules/emacs-init.nix ]
      ++ [ scrubbedPkgsModule ];
    moduleRootPaths = [ ../hm-modules ];
    mkModuleUrl = path:
      "https://gitlab.com/rycee/nur-expressions/blob/master"
      + "/hm-modules/${path}#blob-content-holder";
    channelName = "nur-rycee";
    docBook.id = "nur-rycee-hm-options";
  };

  nixosModulesDocs = nmd.buildModulesDocs {
    modules =
      [ ../modules/containers-docker-support.nix ]
      ++ [ scrubbedPkgsModule ];
    moduleRootPaths = [ ../modules ];
    mkModuleUrl = path:
      "https://gitlab.com/rycee/nur-expressions/blob/master"
      + "/modules/${path}#blob-content-holder";
    channelName = "nur-rycee";
    docBook.id = "nur-rycee-nixos-options";
  };

  docs = nmd.buildDocBookDocs {
    pathName = "nur-rycee";
    modulesDocs = [ hmModulesDocs nixosModulesDocs ];
    documentsDirectory = ./.;
    chunkToc = ''
      <toc>
        <d:tocentry xmlns:d="http://docbook.org/ns/docbook" linkend="book-nur-rycee-manual"><?dbhtml filename="index.html"?>
          <d:tocentry linkend="ch-hm-options"><?dbhtml filename="hm-options.html"?></d:tocentry>
          <d:tocentry linkend="ch-nixos-options"><?dbhtml filename="nixos-options.html"?></d:tocentry>
        </d:tocentry>
      </toc>
    '';
  };

in

{
  options = {
    json =
      pkgs.symlinkJoin {
        name = "nur-rycee-options-json";
        paths = [
          (hmModulesDocs.json.override {
            path = "share/doc/nur-rycee/hm-options.json";
          })

          (nixosModulesDocs.json.override {
            path = "share/doc/nur-rycee/nixos-options.json";
          })
        ];
      };
  };

  manPages = docs.manPages;

  manual = {
    inherit (docs) html htmlOpenTool;
  };
}
