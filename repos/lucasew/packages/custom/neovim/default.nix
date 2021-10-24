{ pkgs
, ...
}:
let
  inherit (builtins)
    getFlake
    toString
    readFile
    trace
  ;
  self = getFlake (toString ../../..);
  inherit (self) inputs;
  inherit (pkgs) 
    fetchFromGitHub
    vimPlugins
    fetchurl
    wrapNeovim
    callPackage
    fetchzip
  ;
  inherit (pkgs.vimUtils)
    buildVimPlugin
    buildVimPluginFrom2Nix
  ;
  machNix = import "${inputs.mach-nix}" {inherit pkgs;};
in
let
  pluginNocapsquit = buildVimPlugin {
    name = "nocapsquit";
    src = fetchFromGitHub {
        owner = "lucasew";
        repo = "nocapsquit.vim";
        rev = "4418b78b635e797eab915bc54380a2a7e66d2e84";
        sha256 = "1jwwiq321b86bh1z3shcprgh2xs5n1xjy9s364zxlxy8qhwfsryq";
    };
  };
  pluginEmbark = buildVimPlugin {
    name = "embark-theme";
    src = fetchFromGitHub {
      owner = "embark-theme";
      repo = "vim";
      rev = "cce94a2cc9f0395ed156930bf6a2d1e3198daa4f";
      sha256 = "02wxjg8ygx7viirphdjlpqr26mdbzcpajnijlchjafy1gms0gryc";
    };
  };
  pluginCoq = buildVimPluginFrom2Nix {
    # based on https://github.com/cideM/coq-nvim-nix/blob/main/flake.nix
    name = "coq-nvim";
    patches = [
      ./coq.patch
    ];
    src = fetchFromGitHub {
      owner = "ms-jpq";
      repo = "coq_nvim";
      sha256 = "sha256-UBlB6M8t1i47MzRG97NmlCZzMnQBusUJDuYEWTDs8YI=";
      rev = "9718da5b621a15709dca342d311a1ee8553f7955";
    };
  };
  pluginCoqArtifacts = buildVimPlugin {
    name = "coq.artifacts";
    src = fetchFromGitHub {
      owner = "ms-jpq";
      repo = "coq.artifacts";
      rev = "254ad1d7974f4f2b984e2b9dd4cc3cdc39b7e361";
      sha256 = "sha256-rZjesUv1Irx4jSUEuONIWiWVwMSeB3PcNEwlSQyM1UA=";
    };
  };
  pluginIonideVim = buildVimPlugin {
    name = "ionide-vim";
    src = fetchFromGitHub {
      owner = "ionide";
      repo = "ionide-vim";
      rev = "0b688cccdb80598e09cd24cd3537145f8633e051";
      sha256 = "sha256-/CizU/ZeyjN7MM0dMoSAd3nFtOth5U0cUZt0bV0wjIw=";
    };
    dontBuild = true;
    postInstall =
    let
      zip = fetchurl {
        url = "https://github.com/fsharp/FsAutoComplete/releases/download/0.47.2/fsautocomplete.netcore.zip";
        sha256 = "1hf6znwpli8mr9mn0ifx6y0v60mzz76k5md7i80gxc5q8mh636l7";
      };
    in
    ''
      ${pkgs.unzip}/bin/unzip -o -d $out/share/vim-plugins/ionide-vim/fsac ${zip}
      chmod 555 $out/share/vim-plugins/ionide-vim/fsac -R
    '';
  };
  pluginLspSignature = vimPlugins.lsp_signature-nvim.overrideAttrs (old: old // {
    src = fetchurl {
      url = "https://github.com/ray-x/lsp_signature.nvim/archive/refs/tags/v0.1.1.tar.gz";
      sha256 = "1dk7sdpxhbvmnwiy811n7jd675mqlsgkjb046f7m6cr7z12gxcnq";
    };
  });
  themeStarrynight = buildVimPlugin {
    name = "starrynight";
    src = fetchFromGitHub {
      owner = "josegamez82";
      repo = "starrynight";
      rev = "fcc8776f64061251a73158515a0ce82304fe4518";
      sha256 = "0zspnzgn5aixwcp7klj5vaijmj4ca6hjj58jrz5aqn10dv41s02p";
    };
  };
  themePaper = buildVimPlugin {
    name = "vim-paper";
    src = fetchFromGitHub {
      owner = "YorickPeterse";
      repo = "vim-paper";
      rev = "67763e10371beb56f9059efe257ec2db2fec2848";
      sha256 = "CEPT2LtDc5hKnA7wrdEX6nzik29o6ewUgGvif5j5l+c=";
    };
  };
  themePreto = buildVimPlugin {
    name = "vim-preto";
    src = fetchFromGitHub {
      owner = "ewilazarus";
      repo = "preto";
      rev = "b9200d9a0ff09c4bc8b1cf054f61f12f49438454";
      sha256 = "sha256-N7GLBVxO9FbLqo9FKJJndnHRnekunxwVAjcgu4l8jLw=";
    };
  };
  neovimAltered = pkgs.neovim-unwrapped.overrideAttrs (old: rec {
    version = "0.5.0";

    src = fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "v${version}";
      sha256 = "0lgbf90sbachdag1zm9pmnlbn35964l3khs27qy4462qzpqyi9fi";
    };
    cmakeFlags = old.cmakeFlags ++ ([
      "-DUSE_BUNDLED=OFF"
    ]);
    buildInputs = old.buildInputs ++ (with pkgs;[
      tree-sitter
    ]);
});
in wrapNeovim neovimAltered {
  withPython3 = true;
  extraPython3Packages = b:
    with b; with callPackage ./python.nix b b b; [
    std2
    pynvim-pp
    # pynvim
    PyYAML
  ];
  configure = {
    plug.plugins = with vimPlugins; [
      # builtin
      # LanguageClient-neovim
      # auto-pairs
      dart-vim-plugin
      echodoc
      emmet-vim
      indentLine
      nvim-lspconfig
      nvim-web-devicons
      onedark-vim
      plantuml-syntax
      plenary-nvim # dep of telescope
      popup-nvim # dep of telescope
      telescope-nvim
      vim-commentary
      vim-nix
      vim-startify
      vim-fetch # support for stacktrace paths
      # custom
      pluginCoq
      pluginCoqArtifacts
      pluginEmbark
      pluginNocapsquit
      pluginLspSignature
      pluginIonideVim
      themePaper
      themePreto
      themeStarrynight
    ];
    customRC = ''
    lua << EOF
    ${readFile ./init.lua}
    EOF
    ${readFile ./rc.vim}
    '';
  };
}
