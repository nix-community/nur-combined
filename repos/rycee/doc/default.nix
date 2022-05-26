{ pkgs }:

let

  lib = pkgs.lib;

  nmdSrc = pkgs.fetchFromGitLab {
    name = "nmd";
    owner = "rycee";
    repo = "nmd";
    rev = "2398aa79ab12aa7aba14bc3b08a6efd38ebabdc5";
    sha256 = "0yxb48afvccn8vvpkykzcr4q1rgv8jsijqncia7a5ffzshcrwrnh";
  };

  nmd = import nmdSrc { inherit pkgs; };

  # Make sure the used package is scrubbed to avoid actually instantiating
  # derivations.
  #
  # Also disable checking since we'll be referring to undefined options.
  setupModule = {
    imports = [{
      _module.args = {
        pkgs = lib.mkForce (nmd.scrubDerivations "pkgs" pkgs);
        pkgs_i686 = lib.mkForce { };
      };
      _module.check = false;
    }];
  };

  hmModulesDocs = nmd.buildModulesDocs {
    modules = [
      ../hm-modules/emacs-init.nix
      ../hm-modules/theme-base16
      ../hm-modules/theme-base16/emacs.nix
      setupModule
    ];
    moduleRootPaths = [ ../hm-modules ];
    mkModuleUrl = path:
      "https://gitlab.com/rycee/nur-expressions/blob/master"
      + "/hm-modules/${path}#blob-content-holder";
    channelName = "nur-rycee";
    docBook = {
      id = "nur-rycee-hm-options";
      optionIdPrefix = "hm-opt";
    };
  };

  nixosModulesDocs = nmd.buildModulesDocs {
    modules = [ ../modules/containers-docker-support.nix setupModule ];
    moduleRootPaths = [ ../modules ];
    mkModuleUrl = path:
      "https://gitlab.com/rycee/nur-expressions/blob/master"
      + "/modules/${path}#blob-content-holder";
    channelName = "nur-rycee";
    docBook = {
      id = "nur-rycee-nixos-options";
      optionIdPrefix = "nixos-opt";
    };
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

in {
  options = {
    json = pkgs.symlinkJoin {
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

  manual = { inherit (docs) html htmlOpenTool; };
}
