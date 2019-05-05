{ neovim, vimPlugins, vimUtils, fetchFromGitHub, lib, ... }:

let
  customPluginData = [
    ["ntpeters/vim-better-whitespace" "2018-03-05"
     "ca9d5bdfa83d6df5d54be437db5cc9f5d3702b7c" "07m39lnmcwdhvs8im2acizfxss20vlyxvk31lxkzcnkqa5s2cr21"]
    ["rhysd/vim-clang-format" "2018-02-01"
     "8ff1660a1e9f856479fffe693743521f4f3068cb" "1g9vs6cg7irmwqa1lz6i7xbq50svykhvax12vx7cpf2bxs8jfp3n"]
    ["drmikehenry/vim-headerguard" "2015-04-28"
     "e53b37fa0772ffe2f30209f6109f5f2ae0fbf48f" "0aq6405p6m4wlgak0zzb7rz6fs5f4gbd2fq4fzy683wspg1k5lq0"]
  ];

  buildCustomPlugins = plugins: with lib; listToAttrs (map (plugin:
    let
      fullname = splitString "/" (elemAt plugin 0);
      owner = elemAt fullname 0;
      name = elemAt fullname 1;
      version = elemAt plugin 1;
      rev = elemAt plugin 2;
      sha256 = elemAt plugin 3;
    in
    { name = name;
      value = vimUtils.buildVimPluginFrom2Nix {
        name = "${name}-${version}";
        version = version;
        src = fetchFromGitHub {
          owner = owner;
          repo = name;
          rev = rev;
          sha256 = sha256;
        };
      };
    }) plugins);

  customPlugins = buildCustomPlugins customPluginData;
  customRC = builtins.readFile ../../dotfiles/init.vim;

  retrievePluginName = line:
    let fullName = lib.elemAt (lib.strings.splitString "'" line) 1;
        rawName = lib.elemAt (lib.strings.splitString "/" fullName) 1;
        name = builtins.replaceStrings ["."] ["-"] rawName; in
      name;
  isPluginLine = line:
    lib.strings.hasPrefix "\tPlug '" line;

  pluginNameList = (builtins.map retrievePluginName (builtins.filter isPluginLine (lib.strings.splitString "\n" customRC)))
    ++ [ "deoplete-nvim" ]; # Deoplete doesn't work with other neovim installations for some reason.
in

neovim.override {
  vimAlias = true;
  configure = {
    customRC = customRC;

    packages.plugins.start = builtins.map (name: lib.getAttr name (vimPlugins // customPlugins)) pluginNameList;
  };
}
