{ lib, buildVimPluginFrom2Nix, fetchurl }:

{
  abbreinder-nvim = buildVimPluginFrom2Nix {
    pname = "abbreinder-nvim";
    version = "2022-04-28";
    src = fetchurl {
      url = "https://github.com/0styx0/abbreinder.nvim/archive/5b2b5ff08a9ada42238d733aeebc6d3d96314d77.tar.gz";
      sha256 = "0hiab78j61gdn9zx4458lqllm9bqnkmrinw8p2mp8whvyi2asd40";
    };
    meta = with lib; {
      description = "Abbreviation reminder plugin for Neovim 0.5+";
      homepage = "https://github.com/0styx0/abbreinder.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  penvim = buildVimPluginFrom2Nix {
    pname = "penvim";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/Abstract-IDE/penvim/archive/028c19f81eba9eaf4fe4876c60e3491b3389322f.tar.gz";
      sha256 = "1nlhcm34hhlwnqphfngqkrzhlb73jnk9aaa3ig94iajmhx29x0i1";
    };
    meta = with lib; {
      description = "Project's root directory and documents Indentation detector with project based config loader";
      homepage = "https://github.com/Abstract-IDE/penvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-gfold-lua = buildVimPluginFrom2Nix {
    pname = "nvim-gfold-lua";
    version = "2022-05-24";
    src = fetchurl {
      url = "https://github.com/AckslD/nvim-gfold.lua/archive/ff1d0d2bf1c31707117e2109fe0e326cfe286be1.tar.gz";
      sha256 = "07w6q6aivf571fcpnpw5nq3lczjgdqqnkdhhrbvncz2zwhmlfa5i";
    };
    meta = with lib; {
      description = "nvim plugin using gfold to switch repo and have statusline component";
      homepage = "https://github.com/AckslD/nvim-gfold.lua";
      license = with licenses; [ mit ];
    };
  };
  nvim-neoclip-lua = buildVimPluginFrom2Nix {
    pname = "nvim-neoclip-lua";
    version = "2022-07-24";
    src = fetchurl {
      url = "https://github.com/AckslD/nvim-neoclip.lua/archive/74af02e289b3ea465bc8a4d7b9b83adc4e4b8c06.tar.gz";
      sha256 = "02dd1m2gp3aqxxa0q3s8i711q8i0n9bgx4nvq06s87aligf0dwl6";
    };
    meta = with lib; {
      description = "Clipboard manager neovim plugin with telescope integration";
      homepage = "https://github.com/AckslD/nvim-neoclip.lua";
    };
  };
  nvim-revJ-lua = buildVimPluginFrom2Nix {
    pname = "nvim-revJ-lua";
    version = "2022-04-11";
    src = fetchurl {
      url = "https://github.com/AckslD/nvim-revJ.lua/archive/fca94c6b401f3b0fa9554e1b0d5251f8180b15a2.tar.gz";
      sha256 = "137hb835vlqywbfha7n5z246iw5agz78k1gk8s8r0yivshggfhkl";
    };
    meta = with lib; {
      description = "Nvim-plugin for doing the opposite of join-line (J) of arguments written in lua";
      homepage = "https://github.com/AckslD/nvim-revJ.lua";
    };
  };
  nvim-expand-expr = buildVimPluginFrom2Nix {
    pname = "nvim-expand-expr";
    version = "2021-08-14";
    src = fetchurl {
      url = "https://github.com/AllenDang/nvim-expand-expr/archive/365cc2a0111228938fb46cffb9cc1a246d787cf0.tar.gz";
      sha256 = "1ws39d2y5gcj0df1jl8bwzwgjzsz7n88b090m0bxj6xmj8y0f7a3";
    };
    meta = with lib; {
      description = "Expand and repeat expression to multiple lines for neovim";
      homepage = "https://github.com/AllenDang/nvim-expand-expr";
      license = with licenses; [ mit ];
    };
  };
  code-runner-nvim = buildVimPluginFrom2Nix {
    pname = "code-runner-nvim";
    version = "2022-05-03";
    src = fetchurl {
      url = "https://github.com/CRAG666/code_runner.nvim/archive/7fe6cf83067cb1026e45683305684aaa9d685850.tar.gz";
      sha256 = "1m49mwjg2hfy3gdrnirq991vyrvsphn74fk4qy9irxmz82js6hph";
    };
    meta = with lib; {
      description = "Neovim plugin.The best code runner you could have, it is like the one in vscode but with super powers, it manages projects like in intellij but without being slow";
      homepage = "https://github.com/CRAG666/code_runner.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvcode-color-schemes-vim = buildVimPluginFrom2Nix {
    pname = "nvcode-color-schemes-vim";
    version = "2021-07-03";
    src = fetchurl {
      url = "https://github.com/ChristianChiarulli/nvcode-color-schemes.vim/archive/3a0e624a67ecd2c7f990bc3c25a1044e85782b10.tar.gz";
      sha256 = "1z07vzfwliqzl97afy5lxfcpx5sg10adv1dci8sph3kpvb6kgygh";
    };
    meta = with lib; {
      description = "A bunch of generated colorschemes (treesitter supported)";
      homepage = "https://github.com/ChristianChiarulli/nvcode-color-schemes.vim";
      license = with licenses; [ mit ];
    };
  };
  indent-o-matic = buildVimPluginFrom2Nix {
    pname = "indent-o-matic";
    version = "2022-06-14";
    src = fetchurl {
      url = "https://github.com/Darazaki/indent-o-matic/archive/bf37c6e4ccd17197d32dee69cffab4f5bbe4cbf2.tar.gz";
      sha256 = "1lx0v64c56f437qg5r9g9i4qqgkzh6yhqqxylgskyhpb54glwvxd";
    };
    meta = with lib; {
      description = "Dumb automatic fast indentation detection for Neovim written in Lua";
      homepage = "https://github.com/Darazaki/indent-o-matic";
      license = with licenses; [ mit ];
    };
  };
  cmp-npm = buildVimPluginFrom2Nix {
    pname = "cmp-npm";
    version = "2021-10-27";
    src = fetchurl {
      url = "https://github.com/David-Kunz/cmp-npm/archive/4b6166c3feeaf8dae162e33ee319dc5880e44a29.tar.gz";
      sha256 = "0znpsrgmidw3x9b8mxny9mv782g8i3z1y0gpy3swp6f1vcw4xgjc";
    };
    meta = with lib; {
      description = "An additional source for nvim-cmp to autocomplete packages and its versions";
      homepage = "https://github.com/David-Kunz/cmp-npm";
      license = with licenses; [ unlicense ];
    };
  };
  jester = buildVimPluginFrom2Nix {
    pname = "jester";
    version = "2022-07-12";
    src = fetchurl {
      url = "https://github.com/David-Kunz/jester/archive/53d9f6c268d8d6d7c6b14a3617b65df22499c0e9.tar.gz";
      sha256 = "1pihjg69qyw9pyc9f40wpbgpdzjd47khp8xir27wz1w6f3yadxb5";
    };
    meta = with lib; {
      description = "A Neovim plugin to easily run and debug Jest tests";
      homepage = "https://github.com/David-Kunz/jester";
      license = with licenses; [ unlicense ];
    };
  };
  nightfox-nvim = buildVimPluginFrom2Nix {
    pname = "nightfox-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/EdenEast/nightfox.nvim/archive/4899a1680e5b41436dc92a1f6e5f2a5bbc0b9454.tar.gz";
      sha256 = "1b0nf1wl8m8rlxm4l4bydz573s2disrnna79yl9cw8s54hvja3dz";
    };
    meta = with lib; {
      description = "🦊A highly customizable theme for vim and neovim with support for lsp, treesitter and a variety of plugins";
      homepage = "https://github.com/EdenEast/nightfox.nvim";
      license = with licenses; [ mit ];
    };
  };
  vs-tasks-nvim = buildVimPluginFrom2Nix {
    pname = "vs-tasks-nvim";
    version = "2022-06-20";
    src = fetchurl {
      url = "https://github.com/EthanJWright/vs-tasks.nvim/archive/8e369ba2b48f9e712eb652181d1bacc6eebcf1c6.tar.gz";
      sha256 = "07nmbmc22gndib1z1hd42sbyph9g6qgnqvhsg8scm19zvninwh6d";
    };
    meta = with lib; {
      description = "A telescope plugin that runs tasks similar to VS Code's task implementation";
      homepage = "https://github.com/EthanJWright/vs-tasks.nvim";
    };
  };
  everblush-nvim = buildVimPluginFrom2Nix {
    pname = "everblush-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/Everblush/everblush.nvim/archive/0442f317bf0405d7ec28d1d2148be2cea39f34ed.tar.gz";
      sha256 = "0gw68cb1dv0zh2b56vq82qh8cmz4438nd4rhsk87c5axif2caks3";
    };
    meta = with lib; {
      description = "A port of everblush.vim but written in lua";
      homepage = "https://github.com/Everblush/everblush.nvim";
    };
  };
  command-center-nvim = buildVimPluginFrom2Nix {
    pname = "command-center-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/FeiyouG/command_center.nvim/archive/659e968046760093d136e98fa614b833b8e82c51.tar.gz";
      sha256 = "1s4dii3lg7kw5pkbwsxssawl2svc8v6mchmr6m2nihk1h2rp51ja";
    };
    meta = with lib; {
      description = "Create and manage keybindings and commands in a more organized manner, and search them quickly through Telescope";
      homepage = "https://github.com/FeiyouG/command_center.nvim";
      license = with licenses; [ mit ];
    };
  };
  aquarium-vim = buildVimPluginFrom2Nix {
    pname = "aquarium-vim";
    version = "2022-06-22";
    src = fetchurl {
      url = "https://github.com/FrenzyExists/aquarium-vim/archive/1f9417b11146580b47f2ecae26b9f3a75bf5e526.tar.gz";
      sha256 = "0bmsz0ss8443f8hyrsm94kvfd4xf6y70l94crm7b2vkjjb835wi1";
    };
    meta = with lib; {
      description = "🌊 Aquarium, a simple vibrant dark theme for vim 🗒";
      homepage = "https://github.com/FrenzyExists/aquarium-vim";
      license = with licenses; [ mit ];
    };
  };
  rasi-vim = buildVimPluginFrom2Nix {
    pname = "rasi-vim";
    version = "2022-02-16";
    src = fetchurl {
      url = "https://github.com/Fymyte/rasi.vim/archive/a3c5eaf37f2f778f4d62dad2f1e3dbb4596ac6eb.tar.gz";
      sha256 = "1bqza91f74qq10m61yhy6876vq4mrzybjph7xrapvxk53w8mp3b5";
    };
    meta = with lib; {
      description = "Rofi config syntax highlighting for vim";
      homepage = "https://github.com/Fymyte/rasi.vim";
      license = with licenses; [ mit ];
    };
  };
  nvim-cartographer = buildVimPluginFrom2Nix {
    pname = "nvim-cartographer";
    version = "2022-04-18";
    src = fetchurl {
      url = "https://github.com/Iron-E/nvim-cartographer/archive/fbe977c9529019376db9426cccf04bfdadeafc69.tar.gz";
      sha256 = "17wz22d0lbyycq9j5n26lay3s6rqqih1zpba8m86isqaz7bbafwg";
    };
    meta = with lib; {
      description = "Create Neovim `:map`pings in Lua with ease!";
      homepage = "https://github.com/Iron-E/nvim-cartographer";
    };
  };
  nvim-highlite = buildVimPluginFrom2Nix {
    pname = "nvim-highlite";
    version = "2022-07-19";
    src = fetchurl {
      url = "https://github.com/Iron-E/nvim-highlite/archive/80e52a18be416790c20e035fa2816aa5e7e34cc9.tar.gz";
      sha256 = "0asc91i6qfswa8jvrhpgbfn6w9vdrm3fqmagmhvqj94ra0jpk1bs";
    };
    meta = with lib; {
      description = "A colorscheme template that is \"lite\" on logic for the developer";
      homepage = "https://github.com/Iron-E/nvim-highlite";
    };
  };
  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring";
    version = "2022-04-07";
    src = fetchurl {
      url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring/archive/88343753dbe81c227a1c1fd2c8d764afb8d36269.tar.gz";
      sha256 = "11r396jwpn4svav3d5m3chzl1pdi2yyggn92pvsvqmjgj65qwqzw";
    };
    meta = with lib; {
      description = "Neovim treesitter plugin for setting the commentstring based on the cursor location in a file";
      homepage = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring";
      license = with licenses; [ mit ];
    };
  };
  lean-nvim = buildVimPluginFrom2Nix {
    pname = "lean-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/Julian/lean.nvim/archive/60ac136bf74ddf39fb19a1b0cfd261dfced11b1d.tar.gz";
      sha256 = "005w4pyk6i2wslwx2s6pgp7y74v3san4n7zqs87wn3lm9szjzp17";
    };
    meta = with lib; {
      description = "neovim support for the Lean theorem prover";
      homepage = "https://github.com/Julian/lean.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-lsp-setup = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-setup";
    version = "2022-07-13";
    src = fetchurl {
      url = "https://github.com/junnplus/nvim-lsp-setup/archive/9c4532408f06709deab4ec66326c2060162c4b70.tar.gz";
      sha256 = "142cv2npn9cl35l5bgxy8s2rlxa4a7ahqgaagcn5m6703a1svgak";
    };
    meta = with lib; {
      description = "A simple wrapper for nvim-lspconfig and nvim-lsp-installer to easily setup LSP servers";
      homepage = "https://github.com/junnplus/nvim-lsp-setup";
      license = with licenses; [ asl20 ];
    };
  };
  LuaSnip = buildVimPluginFrom2Nix {
    pname = "LuaSnip";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/281a89e374eb04663e18e786db5f215092a56595.tar.gz";
      sha256 = "0dfkxw65lrb6s7q75jw2jrp80754wq042nfgwa9w22rwnsv0pbk6";
    };
    meta = with lib; {
      description = "Snippet Engine for Neovim written in Lua";
      homepage = "https://github.com/L3MON4D3/LuaSnip";
      license = with licenses; [ asl20 ];
    };
  };
  telescope-command-palette-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-command-palette-nvim";
    version = "2022-01-31";
    src = fetchurl {
      url = "https://github.com/LinArcX/telescope-command-palette.nvim/archive/1944d6312b29a0b41531ea3cf3912f03e4eb1705.tar.gz";
      sha256 = "0c9czxkkvqla9lkc6ivj8d7rrm6klbjvlafrykc906nym5qzncc2";
    };
    meta = with lib; {
      description = "Create key-bindings and watch them with telescope :telescope:";
      homepage = "https://github.com/LinArcX/telescope-command-palette.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nest-nvim = buildVimPluginFrom2Nix {
    pname = "nest-nvim";
    version = "2021-09-26";
    src = fetchurl {
      url = "https://github.com/LionC/nest.nvim/archive/e5da827a3adfb383b56587bdf4eb62fae4154364.tar.gz";
      sha256 = "11k3fczmyxaa8qzvplq5sn236i4y64qqd6n6dsljs3h780x9p0nk";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/LionC/nest.nvim";
      license = with licenses; [ mit ];
    };
  };
  OneTerm-nvim = buildVimPluginFrom2Nix {
    pname = "OneTerm-nvim";
    version = "2022-03-14";
    src = fetchurl {
      url = "https://github.com/LoricAndre/OneTerm.nvim/archive/5bff7afaaf4b9d2f41b9cddd8b1c4746759f07fb.tar.gz";
      sha256 = "1b37sc11ffli125f0plyr5b6hz4952w3iqwakbv89wliardmcf8x";
    };
    meta = with lib; {
      description = "One terminal plugin to rule them all ! (eventually)";
      homepage = "https://github.com/LoricAndre/OneTerm.nvim";
    };
  };
  everblush-vim = buildVimPluginFrom2Nix {
    pname = "everblush-vim";
    version = "2022-07-12";
    src = fetchurl {
      url = "https://github.com/Everblush/everblush.vim/archive/1d15981660ef6cfdae2cb45f8fcf95e3290d317d.tar.gz";
      sha256 = "0q2wfhzlv89q6qk2dk6hxq4wi0r7a4x15n7phs427gmwjqppzxhv";
    };
    meta = with lib; {
      description = "🎨 A beautiful and dark vim colorscheme. ";
      homepage = "https://github.com/Everblush/everblush.vim";
      license = with licenses; [ mit ];
    };
  };
  dracula-nvim = buildVimPluginFrom2Nix {
    pname = "dracula-nvim";
    version = "2022-07-08";
    src = fetchurl {
      url = "https://github.com/Mofiqul/dracula.nvim/archive/40d38e95bf006470b3efe837b2e0b9f66707c850.tar.gz";
      sha256 = "0rw2w55pnahp472322dwhilq6qjcsy8z2jpk4i9zmla9n77pkjhd";
    };
    meta = with lib; {
      description = "Dracula colorscheme for neovim written in Lua";
      homepage = "https://github.com/Mofiqul/dracula.nvim";
      license = with licenses; [ mit ];
    };
  };
  vscode-nvim = buildVimPluginFrom2Nix {
    pname = "vscode-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/Mofiqul/vscode.nvim/archive/f05cc62d61b0c17d5c190abc712a01a75ff051ec.tar.gz";
      sha256 = "0n7qn851lkfq9zspb90p9pjj2jxjqj3ac8ixynd7j7zxxmksj6gg";
    };
    meta = with lib; {
      description = "Neovim/Vim color scheme inspired by Dark+ and Light+ theme in Visual Studio Code";
      homepage = "https://github.com/Mofiqul/vscode.nvim";
      license = with licenses; [ mit ];
    };
  };
  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/nui.nvim/archive/26622d147762f2212bf30e0792df1d0164a73cd9.tar.gz";
      sha256 = "1nnkv3p5mpsqbjvgz0kpfvpq0a3mkgy7kn0ghmv3a8fkir1zz2va";
    };
    meta = with lib; {
      description = "UI Component Library for Neovim";
      homepage = "https://github.com/MunifTanjim/nui.nvim";
      license = with licenses; [ mit ];
    };
  };
  due-nvim = buildVimPluginFrom2Nix {
    pname = "due-nvim";
    version = "2022-04-15";
    src = fetchurl {
      url = "https://github.com/NFrid/due.nvim/archive/6580854faa9abfba1f4719b25ad6d3652e1df2b6.tar.gz";
      sha256 = "1hq0davwxkyix5mid51gylj83hdry2nig49dmalxha6r925isj64";
    };
    meta = with lib; {
      description = "Neovim plugin for displaying due date";
      homepage = "https://github.com/NFrid/due.nvim";
      license = with licenses; [ mit ];
    };
  };
  guess-indent-nvim = buildVimPluginFrom2Nix {
    pname = "guess-indent-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/NMAC427/guess-indent.nvim/archive/c37467baa1a51b74ed767cbe0540fce44e03d828.tar.gz";
      sha256 = "1qwrlm1jlxjb9fqndm9m0j6zac57acf8nnq1wzfkkzknxf8c2v5f";
    };
    meta = with lib; {
      description = "Automatic indentation style detection for Neovim";
      homepage = "https://github.com/NMAC427/guess-indent.nvim";
      license = with licenses; [ mit ];
    };
  };
  cheovim = buildVimPluginFrom2Nix {
    pname = "cheovim";
    version = "2021-08-25";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/cheovim/archive/6cbd7aeacd09c4f1b0edba75953740037c7d2d2c.tar.gz";
      sha256 = "14g0mjwf9i8ianpkq2ki4v7va8gvmf6vj0rxivkipl1c843xm2kk";
    };
    meta = with lib; {
      description = "Neovim configuration switcher written in Lua. Inspired by chemacs";
      homepage = "https://github.com/NTBBloodbath/cheovim";
      license = with licenses; [ gpl2Only ];
    };
  };
  doom-one-nvim = buildVimPluginFrom2Nix {
    pname = "doom-one-nvim";
    version = "2022-06-06";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/doom-one.nvim/archive/98b23b0eb3d47f908ae2d2b77dd7bad42f566340.tar.gz";
      sha256 = "14dc1kz1y325fmr8jdrdadnbj8bmyv1sx35ryknm6ihkwaznn1sk";
    };
    meta = with lib; {
      description = "doom-emacs' doom-one Lua port for Neovim";
      homepage = "https://github.com/NTBBloodbath/doom-one.nvim";
      license = with licenses; [ mit ];
    };
  };
  galaxyline-nvim = buildVimPluginFrom2Nix {
    pname = "galaxyline-nvim";
    version = "2022-01-21";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/galaxyline.nvim/archive/4d4f5fc8e20a10824117e5beea7ec6e445466a8f.tar.gz";
      sha256 = "0y6mcbwipvm5ifsfyyizn8y03phjrplxfqav1p48h1cnsdq34cd9";
    };
    meta = with lib; {
      description = "neovim statusline plugin written in lua ";
      homepage = "https://github.com/NTBBloodbath/galaxyline.nvim";
      license = with licenses; [ mit ];
    };
  };
  rest-nvim = buildVimPluginFrom2Nix {
    pname = "rest-nvim";
    version = "2022-05-13";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/rest.nvim/archive/d902996de965d5d491f122e69ba9d03f9c673eb0.tar.gz";
      sha256 = "1yf3x1bijf8hx8g7kac77n518982srqv7yv6dw1fvz4vmmzymcf2";
    };
    meta = with lib; {
      description = "A fast Neovim http client written in Lua";
      homepage = "https://github.com/NTBBloodbath/rest.nvim";
      license = with licenses; [ mit ];
    };
  };
  aniseed = buildVimPluginFrom2Nix {
    pname = "aniseed";
    version = "2022-05-14";
    src = fetchurl {
      url = "https://github.com/Olical/aniseed/archive/bfaefa11c9e6b36b17a7fe11f8f005198411c3e5.tar.gz";
      sha256 = "1iz964z4qyw6qih9bnnpwn2mhp084cpfiqda35g2ziz6my2zgnrq";
    };
    meta = with lib; {
      description = "Neovim configuration and plugins in Fennel (Lisp compiled to Lua)";
      homepage = "https://github.com/Olical/aniseed";
      license = with licenses; [ unlicense ];
    };
  };
  conjure = buildVimPluginFrom2Nix {
    pname = "conjure";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/Olical/conjure/archive/572c9717d82de38f5bc60c2942843ce9b941aed6.tar.gz";
      sha256 = "00k37j7pd06qwdfkw7v1w02z5ycjqyqpa02438v1xf1baq4z8g16";
    };
    meta = with lib; {
      description = "Interactive evaluation for Neovim (Clojure, Fennel, Janet, Racket, Hy, MIT Scheme, Guile)";
      homepage = "https://github.com/Olical/conjure";
      license = with licenses; [ unlicense ];
    };
  };
  nvim-hybrid = buildVimPluginFrom2Nix {
    pname = "nvim-hybrid";
    version = "2022-01-22";
    src = fetchurl {
      url = "https://github.com/PHSix/nvim-hybrid/archive/89206396ba22b2518f5db08d96e9aab800902163.tar.gz";
      sha256 = "028y6q7nfix9a73szv28rp14gl5xpi7w91jnmlrc3y4b6f9qzcjx";
    };
    meta = with lib; {
      description = "A neovim colorscheme write in lua";
      homepage = "https://github.com/PHSix/nvim-hybrid";
    };
  };
  AbbrevMan-nvim = buildVimPluginFrom2Nix {
    pname = "AbbrevMan-nvim";
    version = "2021-07-15";
    src = fetchurl {
      url = "https://github.com/Pocco81/AbbrevMan.nvim/archive/97b40b51b373d0d1c22f71dd8fce7f61f6bf46a5.tar.gz";
      sha256 = "158535q9ggkcr1crx0lahcr84gznx2n91plq4mb34wdnrqqyipmq";
    };
    meta = with lib; {
      description = "🍍 A NeoVim plugin for managing vim abbreviations";
      homepage = "https://github.com/Pocco81/AbbrevMan.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  AutoSave-nvim = buildVimPluginFrom2Nix {
    pname = "AutoSave-nvim";
    version = "2021-12-14";
    src = fetchurl {
      url = "https://github.com/Pocco81/AutoSave.nvim/archive/3d342d6fcebeede15b6511b13a38a522c6f33bf8.tar.gz";
      sha256 = "0mknfvb2cmh3ags8lxk0j2k36j3rf0xglafpakpswshvy10lvhvl";
    };
    meta = with lib; {
      description = "🦴 A NeoVim plugin for saving your work before the world collapses or you type :qa!";
      homepage = "https://github.com/Pocco81/AutoSave.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  dap-buddy-nvim = buildVimPluginFrom2Nix {
    pname = "dap-buddy-nvim";
    version = "2022-04-20";
    src = fetchurl {
      url = "https://github.com/Pocco81/dap-buddy.nvim/archive/bbda2b062e5519cde4e10b6e4240d3dd1f867b20.tar.gz";
      sha256 = "156j96wx16zpccvg2plik550gk7az27wpq7bjxq52fch8ixhm02v";
    };
    meta = with lib; {
      description = "🐞 Debug Adapter Protocol manager for Neovim";
      homepage = "https://github.com/Pocco81/dap-buddy.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  HighStr-nvim = buildVimPluginFrom2Nix {
    pname = "HighStr-nvim";
    version = "2021-08-17";
    src = fetchurl {
      url = "https://github.com/Pocco81/HighStr.nvim/archive/25ab3f02f6174394d93ae21914de0e552c255bb8.tar.gz";
      sha256 = "14cljmiqn29i1nzxri4xvqv9fccacx55c88l8nzllfa4add6fk5g";
    };
    meta = with lib; {
      description = "🦎 A NeoVim plugin for highlighting visual selections like in a normal document editor!";
      homepage = "https://github.com/Pocco81/HighStr.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  true-zen-nvim = buildVimPluginFrom2Nix {
    pname = "true-zen-nvim";
    version = "2022-07-01";
    src = fetchurl {
      url = "https://github.com/Pocco81/true-zen.nvim/archive/fd0af396aa06c4aaa7c021cffca3a64a66a4b11f.tar.gz";
      sha256 = "0rvms4iv559knnj1v18yl0flimllpl36rnwmm6zs0p2nh43ghmv4";
    };
    meta = with lib; {
      description = "🦝 Clean and elegant distraction-free writing for NeoVim";
      homepage = "https://github.com/Pocco81/true-zen.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-base16 = buildVimPluginFrom2Nix {
    pname = "nvim-base16";
    version = "2022-07-04";
    src = fetchurl {
      url = "https://github.com/RRethy/nvim-base16/archive/da2a27cbda9b086c201b36778e7cdfd00966627a.tar.gz";
      sha256 = "02sbd93l1lbr1mqv6wbl7b76gqa09f83j08l34ma9lyqzyh6707r";
    };
    meta = with lib; {
      description = "Neovim plugin for building a sync base16 colorscheme. Includes support for Treesitter and LSP highlight groups";
      homepage = "https://github.com/RRethy/nvim-base16";
    };
  };
  nvim-treesitter-textsubjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textsubjects";
    version = "2022-06-26";
    src = fetchurl {
      url = "https://github.com/RRethy/nvim-treesitter-textsubjects/archive/ed026cfdff93b2d63d9d8cd2525481d8f002f65e.tar.gz";
      sha256 = "0y1nmdkh1z5b5my4a1xk76j5wijmxr90kqjyigs3mypamwj45rmb";
    };
    meta = with lib; {
      description = "Location and syntax aware text objects which *do what you mean*";
      homepage = "https://github.com/RRethy/nvim-treesitter-textsubjects";
      license = with licenses; [ asl20 ];
    };
  };
  vim-illuminate = buildVimPluginFrom2Nix {
    pname = "vim-illuminate";
    version = "2022-07-09";
    src = fetchurl {
      url = "https://github.com/RRethy/vim-illuminate/archive/6bfa5dc069bd4aa8513a3640d0b73392094749be.tar.gz";
      sha256 = "11rp001msml480a4si3hcsvxnvanfnja7a88wbfxkq2qw44sr8hw";
    };
    meta = with lib; {
      description = "illuminate.vim - Vim plugin for automatically highlighting other uses of the word under the cursor. Integrates with Neovim's LSP client for intelligent highlighting";
      homepage = "https://github.com/RRethy/vim-illuminate";
    };
  };
  gruvy = buildVimPluginFrom2Nix {
    pname = "gruvy";
    version = "2022-01-09";
    src = fetchurl {
      url = "https://github.com/RishabhRD/gruvy/archive/42cc923376d980a955a57a417e5a1fd5f2f651a0.tar.gz";
      sha256 = "1imlrbs1xg7vyyx8d7qd8z9whxqw6bb91fqkmjm71ywsblhamala";
    };
    meta = with lib; {
      description = "Gruvbuddy port independent of colorbuddy";
      homepage = "https://github.com/RishabhRD/gruvy";
    };
  };
  lspactions = buildVimPluginFrom2Nix {
    pname = "lspactions";
    version = "2022-05-15";
    src = fetchurl {
      url = "https://github.com/RishabhRD/lspactions/archive/0ea962f11ef4d6e212bb0472ccf075aebd2d9e59.tar.gz";
      sha256 = "13s929w679bhnqgfprra5jc635b4frajhb53wybym8hi1gmn6ra2";
    };
    meta = with lib; {
      description = "handlers for required lsp actions";
      homepage = "https://github.com/RishabhRD/lspactions";
    };
  };
  lspactions-nvim06-compatible = buildVimPluginFrom2Nix {
    pname = "lspactions-nvim06-compatible";
    version = "2022-01-08";
    src = fetchurl {
      url = "https://github.com/RishabhRD/lspactions/archive/03953195a938b0a5d421d168461ff45e8e0874ed.tar.gz";
      sha256 = "0jhpbjz353ybcxnq144059mfw6lvxgjf49rdj7158dq2vb88qbcw";
    };
    meta = with lib; {
      description = "handlers for required lsp actions";
      homepage = "https://github.com/RishabhRD/lspactions";
    };
  };
  nvim-lsputils = buildVimPluginFrom2Nix {
    pname = "nvim-lsputils";
    version = "2022-01-29";
    src = fetchurl {
      url = "https://github.com/RishabhRD/nvim-lsputils/archive/ae1a4a62449863ad82c70713d5b6108f3a07917c.tar.gz";
      sha256 = "0saharnvjsd1j3lrfmj83lhzzaigici9lnhraqzxqr7n63ylw7wh";
    };
    meta = with lib; {
      description = "Better defaults for nvim-lsp actions";
      homepage = "https://github.com/RishabhRD/nvim-lsputils";
    };
  };
  nvim-rdark = buildVimPluginFrom2Nix {
    pname = "nvim-rdark";
    version = "2020-12-25";
    src = fetchurl {
      url = "https://github.com/RishabhRD/nvim-rdark/archive/7c32ab475b992ebf63dc6997bae61717f885d118.tar.gz";
      sha256 = "0si8dakdv9w4kjfm7s323xhkf294a08d6pdifhzvsnp79vc36s1f";
    };
    meta = with lib; {
      description = "A dark colorscheme for neovim written in lua";
      homepage = "https://github.com/RishabhRD/nvim-rdark";
    };
  };
  crates-nvim = buildVimPluginFrom2Nix {
    pname = "crates-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/Saecki/crates.nvim/archive/868f6e2439e0de3bfaed1e2ec13a5bf32a9b4a5b.tar.gz";
      sha256 = "0x5fwhv2mpcnj61s4jdiwiaqkidydz7q8wf224ljvn40jl4bwpz5";
    };
    meta = with lib; {
      description = "A neovim plugin that helps managing crates.io dependencies";
      homepage = "https://github.com/Saecki/crates.nvim";
      license = with licenses; [ mit ];
    };
  };
  neovim-session-manager = buildVimPluginFrom2Nix {
    pname = "neovim-session-manager";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/Shatur/neovim-session-manager/archive/7267e396e00b41cd038f818f36eddf772b39c8b2.tar.gz";
      sha256 = "0c5vda9cxsk8ycs4h3svpai98i4ssznx11zm0kq476c163j6iim6";
    };
    meta = with lib; {
      description = "A simple wrapper around :mksession";
      homepage = "https://github.com/Shatur/neovim-session-manager";
      license = with licenses; [ gpl3Only ];
    };
  };
  carbon-nvim = buildVimPluginFrom2Nix {
    pname = "carbon-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/SidOfc/carbon.nvim/archive/76a45ceb58e66e094546effdac15d1962995ee34.tar.gz";
      sha256 = "0n8nprz1a9ds2k9q8qksgglkc2nvnykhi2g33fkjw175hq7blmw7";
    };
    meta = with lib; {
      description = "The simple directory tree viewer for Neovim written in Lua";
      homepage = "https://github.com/SidOfc/carbon.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-navic = buildVimPluginFrom2Nix {
    pname = "nvim-navic";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/SmiteshP/nvim-navic/archive/94bf6fcb1dc27bdad230d9385da085e72c390019.tar.gz";
      sha256 = "0f6af5zxsan8wsj8z017w0dr47hz2fhk67gmyh5jkz3zxmfqa995";
    };
    meta = with lib; {
      description = "Simple winbar/statusline plugin that shows your current code context";
      homepage = "https://github.com/SmiteshP/nvim-navic";
      license = with licenses; [ asl20 ];
    };
  };
  one-nvim = buildVimPluginFrom2Nix {
    pname = "one-nvim";
    version = "2021-06-10";
    src = fetchurl {
      url = "https://github.com/Th3Whit3Wolf/one-nvim/archive/faf6fb3f98fccbe009c3466f657a8fff84a5f956.tar.gz";
      sha256 = "058cmkxsxpgaw705cr6q6zckh4lmh2r70945hzgq5cx0p9iwcwwd";
    };
    meta = with lib; {
      description = "Atom one theme";
      homepage = "https://github.com/Th3Whit3Wolf/one-nvim";
      license = with licenses; [ mit ];
    };
  };
  onebuddy = buildVimPluginFrom2Nix {
    pname = "onebuddy";
    version = "2021-04-01";
    src = fetchurl {
      url = "https://github.com/Th3Whit3Wolf/onebuddy/archive/7e16006e7dde15e3cb72889f736c49409db6ff42.tar.gz";
      sha256 = "08kap2mh0fm4vb89p60l3prpw3hgx954wxfgiiffyrz5b2p3cr1y";
    };
    meta = with lib; {
      description = "Light and dark atom one theme";
      homepage = "https://github.com/Th3Whit3Wolf/onebuddy";
      license = with licenses; [ mit ];
    };
  };
  space-nvim = buildVimPluginFrom2Nix {
    pname = "space-nvim";
    version = "2021-07-08";
    src = fetchurl {
      url = "https://github.com/Th3Whit3Wolf/space-nvim/archive/9c4f5857acf51aa6d4924f3f2ccabb079799e7f6.tar.gz";
      sha256 = "1sp1gs5g5lkhwymsb2jz7xzg34nbbfxyz74ryq8ggnbk238374bw";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/Th3Whit3Wolf/space-nvim";
      license = with licenses; [ mit ];
    };
  };
  drex-nvim = buildVimPluginFrom2Nix {
    pname = "drex-nvim";
    version = "2022-06-17";
    src = fetchurl {
      url = "https://github.com/TheBlob42/drex.nvim/archive/68faf4dfac55487bc85bfea5ed2a2808d2bad438.tar.gz";
      sha256 = "1nm29sa56dglzidlnbrlcpya2lx1nvmvpl5z4n1hrxc3j2rw4m8n";
    };
    meta = with lib; {
      description = "Another directory/file explorer for Neovim written in Lua ";
      homepage = "https://github.com/TheBlob42/drex.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  harpoon = buildVimPluginFrom2Nix {
    pname = "harpoon";
    version = "2022-05-08";
    src = fetchurl {
      url = "https://github.com/ThePrimeagen/harpoon/archive/d3d3d22b6207f46f8ca64946f4d781e975aec0fc.tar.gz";
      sha256 = "1kbqxkpx7j5f4z7y106qz458pscr38rx565nchyk6xsq8dyjpn1g";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/ThePrimeagen/harpoon";
      license = with licenses; [ mit ];
    };
  };
  vim-apm = buildVimPluginFrom2Nix {
    pname = "vim-apm";
    version = "2020-09-28";
    src = fetchurl {
      url = "https://github.com/ThePrimeagen/vim-apm/archive/2da35c35febbe98a6704495cd4e0b9526a0651e3.tar.gz";
      sha256 = "13q5yrch3d1ny0jh2pl3nsb8ng3h125llv3waqiw4phk7v5hl5b3";
    };
    meta = with lib; {
      description = "Vim APM, Actions per minute, is the greatest plugin since vim-slicedbread";
      homepage = "https://github.com/ThePrimeagen/vim-apm";
    };
  };
  vim-be-good = buildVimPluginFrom2Nix {
    pname = "vim-be-good";
    version = "2021-03-16";
    src = fetchurl {
      url = "https://github.com/ThePrimeagen/vim-be-good/archive/bc499a06c14c729b22a6cc7e730a9fbc44d4e737.tar.gz";
      sha256 = "16530gq2m6z68jc0gmy282dspgrvizk440md8r2q5bbfyvdp0vll";
    };
    meta = with lib; {
      description = "vim-be-good is a nvim plugin designed to make you better at Vim Movements. ";
      homepage = "https://github.com/ThePrimeagen/vim-be-good";
    };
  };
  neofs = buildVimPluginFrom2Nix {
    pname = "neofs";
    version = "2021-11-02";
    src = fetchurl {
      url = "https://github.com/TimUntersberger/neofs/archive/c75a7a149c6600f56e018fdcfd38e149d1d10f83.tar.gz";
      sha256 = "1pg0a3mwwcdpda5vxx59ygr8kpy5vf9xnl5ilwdrxpw6a4qlsxyr";
    };
    meta = with lib; {
      description = "A file manager for neovim";
      homepage = "https://github.com/TimUntersberger/neofs";
      license = with licenses; [ mit ];
    };
  };
  neogit = buildVimPluginFrom2Nix {
    pname = "neogit";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/TimUntersberger/neogit/archive/06e986fab0d0c31ba981b9f21c712dc72b3d237f.tar.gz";
      sha256 = "1n424951p6mm71frkm5lpx4dmyripdglc2p2zjx7998kxr9y9xlh";
    };
    meta = with lib; {
      description = "magit for neovim";
      homepage = "https://github.com/TimUntersberger/neogit";
      license = with licenses; [ mit ];
    };
  };
  persistent-breakpoints-nvim = buildVimPluginFrom2Nix {
    pname = "persistent-breakpoints-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/Weissle/persistent-breakpoints.nvim/archive/9f5717c3fbe7f425811248792c9da0505a390d35.tar.gz";
      sha256 = "149cjnj6ndqlx49qwvibbpb2325m0xbfx9rn1kikz61yzfr26n8x";
    };
    meta = with lib; {
      description = "Neovim plugin for persistent breakpoints";
      homepage = "https://github.com/Weissle/persistent-breakpoints.nvim";
      license = with licenses; [ mit ];
    };
  };
  scrollbar-nvim = buildVimPluginFrom2Nix {
    pname = "scrollbar-nvim";
    version = "2022-06-16";
    src = fetchurl {
      url = "https://github.com/Xuyuanp/scrollbar.nvim/archive/bc97c132e8367efecb2ecb937d385e7dc04eb5a1.tar.gz";
      sha256 = "1mp7yyh61kazr39xcm3r3zq24mbx1b34qb75q0g61r77wzql7dnc";
    };
    meta = with lib; {
      description = "scrollbar for neovim";
      homepage = "https://github.com/Xuyuanp/scrollbar.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  yanil = buildVimPluginFrom2Nix {
    pname = "yanil";
    version = "2022-03-28";
    src = fetchurl {
      url = "https://github.com/Xuyuanp/yanil/archive/bf01dbc9de2d822de422c4d1eb63ced78cc52388.tar.gz";
      sha256 = "11flnjdwgz9xad86r6nhv3v90k3c2qifyc564ffn4klc3dy65dqa";
    };
    meta = with lib; {
      description = "Yet Another Nerdtree In Lua";
      homepage = "https://github.com/Xuyuanp/yanil";
      license = with licenses; [ asl20 ];
    };
  };
  smart-pairs = buildVimPluginFrom2Nix {
    pname = "smart-pairs";
    version = "2022-03-22";
    src = fetchurl {
      url = "https://github.com/ZhiyuanLck/smart-pairs/archive/6e7a5a8e3906f7a8a8c5b8603d5264ff1b5d87c3.tar.gz";
      sha256 = "136v59y5kazkqq2nqwrdjazjy0qadv4r86q4nmrgmr65ywy8g4kl";
    };
    meta = with lib; {
      description = "Ultimate smart pairs written in lua!";
      homepage = "https://github.com/ZhiyuanLck/smart-pairs";
      license = with licenses; [ mit ];
    };
  };
  tabout-nvim = buildVimPluginFrom2Nix {
    pname = "tabout-nvim";
    version = "2022-05-07";
    src = fetchurl {
      url = "https://github.com/abecodes/tabout.nvim/archive/be655cc7ce0f5d6d24eeaf8b36e82693fd2facca.tar.gz";
      sha256 = "1psqskrc984jw84rx4nrf80m8j6xdcz9x6cfcyhf4hmwa814rr8k";
    };
    meta = with lib; {
      description = "tabout plugin for neovim";
      homepage = "https://github.com/abecodes/tabout.nvim";
      license = with licenses; [ unlicense ];
    };
  };
  neoline-vim = buildVimPluginFrom2Nix {
    pname = "neoline-vim";
    version = "2022-07-13";
    src = fetchurl {
      url = "https://github.com/adelarsq/neoline.vim/archive/f5e6ae3f954a8e45f7b88fe929b6b2e23e50f114.tar.gz";
      sha256 = "0hrlraindsrgvqzga2zd3mmmk6gy7m3m8yjzpz4bbaric5cg8prc";
    };
    meta = with lib; {
      description = "Status Line for Neovim focused on beauty and performance ✅🖤💙💛";
      homepage = "https://github.com/adelarsq/neoline.vim";
      license = with licenses; [ mit ];
    };
  };
  apprentice-nvim = buildVimPluginFrom2Nix {
    pname = "apprentice-nvim";
    version = "2022-04-26";
    src = fetchurl {
      url = "https://github.com/adisen99/apprentice.nvim/archive/e4356803211164c16928f31a4604e6bc131c0077.tar.gz";
      sha256 = "1fli9smjmwrb152c5rpidybszgmn6nzdvafzl9yxpd6p20c2lgj5";
    };
    meta = with lib; {
      description = "Apprentice color scheme for Neovim written in Lua";
      homepage = "https://github.com/adisen99/apprentice.nvim";
      license = with licenses; [ mit ];
    };
  };
  codeschool-nvim = buildVimPluginFrom2Nix {
    pname = "codeschool-nvim";
    version = "2022-04-26";
    src = fetchurl {
      url = "https://github.com/adisen99/codeschool.nvim/archive/3824cdd7d40c31a816f4d6b5d7f59568c3fa6e43.tar.gz";
      sha256 = "0smk1f4zfndxyzfvxvbch9ks76yv28m6mwbfh7j773305x3x122a";
    };
    meta = with lib; {
      description = "Codeschool colorscheme for neovim written in lua with treesitter and built-in lsp support";
      homepage = "https://github.com/adisen99/codeschool.nvim";
      license = with licenses; [ mit ];
    };
  };
  bufferline-nvim = buildVimPluginFrom2Nix {
    pname = "bufferline-nvim";
    version = "2022-07-24";
    src = fetchurl {
      url = "https://github.com/akinsho/bufferline.nvim/archive/c4dd9b4de03b891f648b098c25e4dc1bc48a13e5.tar.gz";
      sha256 = "1q1lxywsa3bvnd7bm5m4a76lr3qwm5mm4hmz6rq4bdrq4pk6ls9g";
    };
    meta = with lib; {
      description = "A snazzy bufferline for Neovim";
      homepage = "https://github.com/akinsho/bufferline.nvim";
      license = with licenses; [ unlicense ];
    };
  };
  dependency-assist-nvim = buildVimPluginFrom2Nix {
    pname = "dependency-assist-nvim";
    version = "2021-11-11";
    src = fetchurl {
      url = "https://github.com/akinsho/dependency-assist.nvim/archive/86d49a83f89a9a48e50556fef00961ea2e3ec28b.tar.gz";
      sha256 = "0d7pcz5747m4jqqsrvddv71qhnynah8rhdkyyggmxqxp0mndxvb8";
    };
    meta = with lib; {
      description = "A neovim plugin to help find/search for dependency information/versions";
      homepage = "https://github.com/akinsho/dependency-assist.nvim";
    };
  };
  flutter-tools-nvim = buildVimPluginFrom2Nix {
    pname = "flutter-tools-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/akinsho/flutter-tools.nvim/archive/789c41dddd602ae3d4d9e91f7c2f2461dc505e93.tar.gz";
      sha256 = "1hcqfj4h8pgj4pgx47qqkz4ajb7m3h0wxbvn7db3yfq4ja64a9gc";
    };
    meta = with lib; {
      description = "Tools to help create flutter apps in neovim using the native lsp";
      homepage = "https://github.com/akinsho/flutter-tools.nvim";
      license = with licenses; [ mit ];
    };
  };
  toggleterm-nvim = buildVimPluginFrom2Nix {
    pname = "toggleterm-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/akinsho/toggleterm.nvim/archive/cd12ed737d3de2757a540ddf4962a6de05881127.tar.gz";
      sha256 = "19fw28vd4pq4g5c4vg7ikm77vrz3njnm5ll4vb9573ml9z4sin73";
    };
    meta = with lib; {
      description = "A neovim lua plugin to help easily manage multiple terminal windows";
      homepage = "https://github.com/akinsho/toggleterm.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nim-nvim = buildVimPluginFrom2Nix {
    pname = "nim-nvim";
    version = "2021-10-07";
    src = fetchurl {
      url = "https://github.com/alaviss/nim.nvim/archive/dbc853fedb963a97b1c5fbac54a05ba4f5100f06.tar.gz";
      sha256 = "1bndr06478j900ra0zwcszgclk51x5032l2mfnqccwsipgd01gmq";
    };
    meta = with lib; {
      description = "Nim plugin for NeoVim";
      homepage = "https://github.com/alaviss/nim.nvim";
    };
  };
  nvim-tetris = buildVimPluginFrom2Nix {
    pname = "nvim-tetris";
    version = "2021-06-28";
    src = fetchurl {
      url = "https://github.com/alec-gibson/nvim-tetris/archive/d17c99fb527ada98ffb0212ffc87ccda6fd4f7d9.tar.gz";
      sha256 = "09ni6i5kmll3f905ripsj31p98p1sw4rbqvv0abx96yiy44mdlgf";
    };
    meta = with lib; {
      description = "Bringing emacs' greatest feature to neovim - Tetris!";
      homepage = "https://github.com/alec-gibson/nvim-tetris";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-lspupdate = buildVimPluginFrom2Nix {
    pname = "nvim-lspupdate";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/alexaandru/nvim-lspupdate/archive/8b809b7887790f1742b6f9de6d35c35f07c23ec2.tar.gz";
      sha256 = "03h8zr3m8jr1ck0d1bldly0hjvmjnx8h72xvnk2ak7248rxmqnwb";
    };
    meta = with lib; {
      description = "Updates installed LSP servers, automatically";
      homepage = "https://github.com/alexaandru/nvim-lspupdate";
      license = with licenses; [ mit ];
    };
  };
  bats-vim = buildVimPluginFrom2Nix {
    pname = "bats-vim";
    version = "2021-01-10";
    src = fetchurl {
      url = "https://github.com/aliou/bats.vim/archive/6a5d2ef22b0ede503d867770afd02ebb1f97b709.tar.gz";
      sha256 = "0nl1znlcdyly9a2mak9wckdmsk8iqsg9wnq7hd0zraz6bsj3mzvm";
    };
    meta = with lib; {
      description = "Syntax files for Bats (Bash Automated Testing System)";
      homepage = "https://github.com/aliou/bats.vim";
    };
  };
  luatab-nvim = buildVimPluginFrom2Nix {
    pname = "luatab-nvim";
    version = "2021-12-05";
    src = fetchurl {
      url = "https://github.com/alvarosevilla95/luatab.nvim/archive/79d53c11bd77274b49b50f1d6fdb10529d7354b7.tar.gz";
      sha256 = "0v4kxx2vchzh7pvx120cbrd8scfsa1zfzlwdj4v3wl951swiidpi";
    };
    meta = with lib; {
      description = "Tabline lua plugin for neovim";
      homepage = "https://github.com/alvarosevilla95/luatab.nvim";
      license = with licenses; [ mit ];
    };
  };
  fuzzy-nvim = buildVimPluginFrom2Nix {
    pname = "fuzzy-nvim";
    version = "2021-05-13";
    src = fetchurl {
      url = "https://github.com/amirrezaask/fuzzy.nvim/archive/0ed93b8e8c78ddbf4539a3bb464a60ce6ecaf6e6.tar.gz";
      sha256 = "1nw5ws0ff0nmniqad5jvmwdp3hn3awfh0m74d6acy3cdd9vqqhck";
    };
    meta = with lib; {
      description = "Fuzzy matching for Neovim";
      homepage = "https://github.com/amirrezaask/fuzzy.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-docs-view = buildVimPluginFrom2Nix {
    pname = "nvim-docs-view";
    version = "2022-06-21";
    src = fetchurl {
      url = "https://github.com/amrbashir/nvim-docs-view/archive/ea36462bb8301638b3cc34a1a536cb64f3ce043a.tar.gz";
      sha256 = "0b60j0jyl7rbdvvnqrx3j063jcsxvlmq04g93wh16wnzhkbc844w";
    };
    meta = with lib; {
      description = "A neovim plugin to display lsp hover documentation in a side panel";
      homepage = "https://github.com/amrbashir/nvim-docs-view";
      license = with licenses; [ mit ];
    };
  };
  nordic-nvim = buildVimPluginFrom2Nix {
    pname = "nordic-nvim";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/andersevenrud/nordic.nvim/archive/eb096c03853b8cc24457263c9ceed90256566118.tar.gz";
      sha256 = "07xfxkxcncimqmfg6lj7f2dq3iqkhckri68v1m2z86k7hkzmlkib";
    };
    meta = with lib; {
      description = "A nord-esque colorscheme for neovim";
      homepage = "https://github.com/andersevenrud/nordic.nvim";
      license = with licenses; [ mit ];
    };
  };
  textobj-diagnostic-nvim = buildVimPluginFrom2Nix {
    pname = "textobj-diagnostic-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/andrewferrier/textobj-diagnostic.nvim/archive/f3a9ca26f6971955b35b78afa5174f0f2a8ea05d.tar.gz";
      sha256 = "08i7wgzdhya7rf0x17s0kl68p7v10vcygyvvri5i4n0b5n29pr0i";
    };
    meta = with lib; {
      description = "NeoVim text object that finds diagnostics";
      homepage = "https://github.com/andrewferrier/textobj-diagnostic.nvim";
      license = with licenses; [ mit ];
    };
  };
  presence-nvim = buildVimPluginFrom2Nix {
    pname = "presence-nvim";
    version = "2022-06-27";
    src = fetchurl {
      url = "https://github.com/andweeb/presence.nvim/archive/660bd8815ef8da029fa0058f76ac7fa2ca8f9ec7.tar.gz";
      sha256 = "0jfnfm4sm5mzcf25wjfdl6gh6x6hwmmi7855bvq9p0lrd285pfjl";
    };
    meta = with lib; {
      description = "Discord Rich Presence for Neovim";
      homepage = "https://github.com/andweeb/presence.nvim";
    };
  };
  nvim-lspinstall = buildVimPluginFrom2Nix {
    pname = "nvim-lspinstall";
    version = "2021-07-23";
    src = fetchurl {
      url = "https://github.com/anott03/nvim-lspinstall/archive/1d9b385dc4d963b9ee93d4597f6010c4ada4b405.tar.gz";
      sha256 = "061spva2h74h0rgx07jvnp27gc30z9dj7n9sxa135q3hdkka7wv1";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/anott03/nvim-lspinstall";
    };
  };
  fold-preview-nvim = buildVimPluginFrom2Nix {
    pname = "fold-preview-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/anuvyklack/fold-preview.nvim/archive/4f9548763eec899a39ddf12795dcebcdee541a87.tar.gz";
      sha256 = "0mapisy65bx8zv42a9j3rd7p76kmja2vc9g0kr1nx22nhc386184";
    };
    meta = with lib; {
      description = "Preview folds in float window ";
      homepage = "https://github.com/anuvyklack/fold-preview.nvim";
    };
  };
  hydra-nvim = buildVimPluginFrom2Nix {
    pname = "hydra-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/anuvyklack/hydra.nvim/archive/e699886f8c68cfaa4b80192e2db46aabe3ae31b3.tar.gz";
      sha256 = "00iyw8b248cjxilvdi1pd0rp10j06dvk342br1ym22c5h2ncj875";
    };
    meta = with lib; {
      description = "Create custom submodes and menus";
      homepage = "https://github.com/anuvyklack/hydra.nvim";
    };
  };
  keymap-amend-nvim = buildVimPluginFrom2Nix {
    pname = "keymap-amend-nvim";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/anuvyklack/keymap-amend.nvim/archive/f40088186794470e904954bfa9b9bde3472f99c9.tar.gz";
      sha256 = "174hzf047j47l3ig8wqkcn231jh23ssw65c8vlzzk7m58nbsn4sw";
    };
    meta = with lib; {
      description = "Amend the existing keymap in Neovim";
      homepage = "https://github.com/anuvyklack/keymap-amend.nvim";
    };
  };
  pretty-fold-nvim = buildVimPluginFrom2Nix {
    pname = "pretty-fold-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/anuvyklack/pretty-fold.nvim/archive/a7d8b424abe0eedf50116c460fbe6dfd5783b1d5.tar.gz";
      sha256 = "1j4y59v9jb02nsc4hprwmqjpmrv3lvqhifgk499ad97xjdc2hliz";
    };
    meta = with lib; {
      description = "Foldtext customization and folded region preview in Neovim";
      homepage = "https://github.com/anuvyklack/pretty-fold.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  tmux-nvim = buildVimPluginFrom2Nix {
    pname = "tmux-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/aserowy/tmux.nvim/archive/3b6a1ee21131513695ff2b4bc22f74e68a52cea4.tar.gz";
      sha256 = "0jnacfzhjing0w2jsyzmbd3lyiwr56vj4bn0fv04l9k7snh3jk7s";
    };
    meta = with lib; {
      description = "tmux integration for nvim features pane movement and resizing from within nvim";
      homepage = "https://github.com/aserowy/tmux.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-picgo = buildVimPluginFrom2Nix {
    pname = "nvim-picgo";
    version = "2022-06-02";
    src = fetchurl {
      url = "https://github.com/askfiy/nvim-picgo/archive/b98177214ddf76f1f16c91768cbc7995e9d53e08.tar.gz";
      sha256 = "1hp1h5dw62lc4psrdjhx2y8aw5z11bi666iyb4cfp61jbw8bcw88";
    };
    meta = with lib; {
      description = "🥳🥳 A neovim plugin based on picgo-core, written in Lua. 🌲 Allows you to add pictures to various picture beds at any time, and they can be accessed from any corner of the Internet. 🎆";
      homepage = "https://github.com/askfiy/nvim-picgo";
      license = with licenses; [ gpl3Only ];
    };
  };
  urlview-nvim = buildVimPluginFrom2Nix {
    pname = "urlview-nvim";
    version = "2022-05-07";
    src = fetchurl {
      url = "https://github.com/axieax/urlview.nvim/archive/92a6ae6f33839222ce4ea58f5cdaf0a3f235caca.tar.gz";
      sha256 = "0pgj3lb8az0xsmgqhv82z3q2dgi1irg9n8dx9ky41jhabpgaiz5k";
    };
    meta = with lib; {
      description = "🔎 Neovim plugin for viewing all the URLs in a buffer";
      homepage = "https://github.com/axieax/urlview.nvim";
      license = with licenses; [ mit ];
    };
  };
  SchemaStore-nvim = buildVimPluginFrom2Nix {
    pname = "SchemaStore-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/b0o/SchemaStore.nvim/archive/ff0d80ed00726a9b20596d165511bd902867457f.tar.gz";
      sha256 = "191dxyvcmmv7ych4gx7y49w6vrhisvvbvyl3bnkv8dnqj99n1bxk";
    };
    meta = with lib; {
      description = "🛍 JSON schemas for Neovim";
      homepage = "https://github.com/b0o/SchemaStore.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  incline-nvim = buildVimPluginFrom2Nix {
    pname = "incline-nvim";
    version = "2022-05-21";
    src = fetchurl {
      url = "https://github.com/b0o/incline.nvim/archive/a43a25047f267b9526f17d7fcde176dfb5f872bd.tar.gz";
      sha256 = "1di5p8l87gmfc1h4ghpwv8ysz662a6a019kbi7gmp58lv901z9g6";
    };
    meta = with lib; {
      description = "🎈 Floating winbar statuslines for Neovim";
      homepage = "https://github.com/b0o/incline.nvim";
      license = with licenses; [ mit ];
    };
  };
  mapx-nvim = buildVimPluginFrom2Nix {
    pname = "mapx-nvim";
    version = "2022-02-24";
    src = fetchurl {
      url = "https://github.com/b0o/mapx.nvim/archive/c3dd43474a5fc2f266309bc04a69b74eb2524671.tar.gz";
      sha256 = "0cff34bmgd2jpk9mz1x66zlilksppqh89knnrwklg4mvd45lif4f";
    };
    meta = with lib; {
      description = "🗺 A better way to create key mappings in Neovim";
      homepage = "https://github.com/b0o/mapx.nvim";
      license = with licenses; [ mit ];
    };
  };
  kommentary = buildVimPluginFrom2Nix {
    pname = "kommentary";
    version = "2022-05-27";
    src = fetchurl {
      url = "https://github.com/b3nj5m1n/kommentary/archive/533d768a140b248443da8346b88e88db704212ab.tar.gz";
      sha256 = "055cmc3kc0bw9z497higg5k03f9swk9bsj5sh5ii53qfs7if8k0w";
    };
    meta = with lib; {
      description = "Neovim commenting plugin, written in lua";
      homepage = "https://github.com/b3nj5m1n/kommentary";
      license = with licenses; [ mit ];
    };
  };
  focus-nvim = buildVimPluginFrom2Nix {
    pname = "focus-nvim";
    version = "2022-07-24";
    src = fetchurl {
      url = "https://github.com/beauwilliams/focus.nvim/archive/6ff7636a6ab7603ec39abe921ad62d406fd7dfa2.tar.gz";
      sha256 = "1gqz3fnnb4z0ygqc4c42qb38jb38zx62viq7p5dn70wa5m5aj2c8";
    };
    meta = with lib; {
      description = "Auto-Focusing and Auto-Resizing Splits/Windows for Neovim written in Lua. A full suite of window management enhancements. Vim splits on steroids!";
      homepage = "https://github.com/beauwilliams/focus.nvim";
    };
  };
  statusline-lua = buildVimPluginFrom2Nix {
    pname = "statusline-lua";
    version = "2022-06-13";
    src = fetchurl {
      url = "https://github.com/beauwilliams/statusline.lua/archive/c19796fde64f00051054f92b5248f311acc79a16.tar.gz";
      sha256 = "09a2b4lizr0vd7x60ky91xiprdmx5bs3l88bq43amjfh4l7xc6gi";
    };
    meta = with lib; {
      description = "A zero-config minimal statusline for neovim written in lua featuring awesome integrations and blazing speed!";
      homepage = "https://github.com/beauwilliams/statusline.lua";
      license = with licenses; [ mit ];
    };
  };
  nvim-regexplainer = buildVimPluginFrom2Nix {
    pname = "nvim-regexplainer";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/bennypowers/nvim-regexplainer/archive/211d096308ae5d5921a9a0ae27f69220557ccc2f.tar.gz";
      sha256 = "1wdc678dm857mq0x731fzfyc9v0q1vd46yi14slp1sggb30nq6pb";
    };
    meta = with lib; {
      description = "Describe the regexp under the cursor";
      homepage = "https://github.com/bennypowers/nvim-regexplainer";
    };
  };
  nvim-luadev = buildVimPluginFrom2Nix {
    pname = "nvim-luadev";
    version = "2022-01-26";
    src = fetchurl {
      url = "https://github.com/bfredl/nvim-luadev/archive/2a2c242bd751c289cfc1bc27f357925f68eba098.tar.gz";
      sha256 = "1i4mg8rzbyg1rq8yrha1kq3hs4b0wvmsxbcnqjhfgrxdaqkwhx15";
    };
    meta = with lib; {
      description = "REPL/debug console for nvim lua plugins";
      homepage = "https://github.com/bfredl/nvim-luadev";
      license = with licenses; [ mit ];
    };
  };
  gloombuddy = buildVimPluginFrom2Nix {
    pname = "gloombuddy";
    version = "2021-04-16";
    src = fetchurl {
      url = "https://github.com/bkegley/gloombuddy/archive/d59866faf296b46cb6e54889b47f4b9a366ed093.tar.gz";
      sha256 = "1kz6d79srnzy6g1qhgcbz2x9b01dlsir083vw1f4l5r4ia342gmc";
    };
    meta = with lib; {
      description = "Gloom inspired theme for neovim";
      homepage = "https://github.com/bkegley/gloombuddy";
      license = with licenses; [ mit ];
    };
  };
  vim-moonfly-colors = buildVimPluginFrom2Nix {
    pname = "vim-moonfly-colors";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-moonfly-colors/archive/3cf7cfe5d89d9784aef4c5aacd2fce1575a6dbba.tar.gz";
      sha256 = "0shq812c64j5fn2d0yqdkyb037sxgdakqzs4v40j5vjknqli9qr2";
    };
    meta = with lib; {
      description = "A dark color scheme for Vim & Neovim";
      homepage = "https://github.com/bluz71/vim-moonfly-colors";
      license = with licenses; [ mit ];
    };
  };
  vim-nightfly-guicolors = buildVimPluginFrom2Nix {
    pname = "vim-nightfly-guicolors";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-nightfly-guicolors/archive/20cdb03eb85d4601d496d0cd662af62bcde6bbf6.tar.gz";
      sha256 = "0n2zhd55j9yg526v2vq9izk97glnaxd1vhsvkzywg5blm31zk955";
    };
    meta = with lib; {
      description = "Another dark color scheme for Vim & Neovim";
      homepage = "https://github.com/bluz71/vim-nightfly-guicolors";
      license = with licenses; [ mit ];
    };
  };
  nvim-gomove = buildVimPluginFrom2Nix {
    pname = "nvim-gomove";
    version = "2022-07-19";
    src = fetchurl {
      url = "https://github.com/booperlv/nvim-gomove/archive/2b44ae7ac0804f4e3959228122f7c85bef1964e3.tar.gz";
      sha256 = "19673h725xxdiapsr1jkv3cyvrh98jdisq0cl46n6i80f0hbs0cw";
    };
    meta = with lib; {
      description = "A complete plugin for moving and duplicating blocks and lines, with complete fold handling, reindenting, and undoing in one go";
      homepage = "https://github.com/booperlv/nvim-gomove";
      license = with licenses; [ mit ];
    };
  };
  snap = buildVimPluginFrom2Nix {
    pname = "snap";
    version = "2021-11-01";
    src = fetchurl {
      url = "https://github.com/camspiers/snap/archive/500f97650136d4c5a00179d7f80dd614e13efdbe.tar.gz";
      sha256 = "08kmbpqk5yn314fdh84gs2fck1zma4268g4b2kl9p5x3k5nqxa2c";
    };
    meta = with lib; {
      description = "A fast finder system for neovim";
      homepage = "https://github.com/camspiers/snap";
      license = with licenses; [ unlicense ];
    };
  };
  trim-nvim = buildVimPluginFrom2Nix {
    pname = "trim-nvim";
    version = "2022-06-16";
    src = fetchurl {
      url = "https://github.com/cappyzawa/trim.nvim/archive/ab366eb0dd7b3faeaf90a0ec40c993ff18d8c068.tar.gz";
      sha256 = "1c2znyq235x2g2cgiz88ncwv2p811m9xldgzx01qp9yl8swp1jhf";
    };
    meta = with lib; {
      description = "This plugin trims trailing whitespace and lines";
      homepage = "https://github.com/cappyzawa/trim.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  catppuccin = buildVimPluginFrom2Nix {
    pname = "catppuccin";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/7acc7503a1d74ce85bab40caedb1592d8602236d.tar.gz";
      sha256 = "0mlbayjzjq2yv698zjwwhilvd7ab8mnyxp1q708p3s5syxz4hknw";
    };
    meta = with lib; {
      description = "🍨 Soothing pastel theme for NeoVim";
      homepage = "https://github.com/catppuccin/nvim";
      license = with licenses; [ mit ];
    };
  };
  marks-nvim = buildVimPluginFrom2Nix {
    pname = "marks-nvim";
    version = "2022-06-18";
    src = fetchurl {
      url = "https://github.com/chentoast/marks.nvim/archive/bb257578fef656812d87375f950f4e4018a39ae4.tar.gz";
      sha256 = "0pigb4f849flr1gah535yd3kwymc4mymg8vhm3rb53vcj78v0rgi";
    };
    meta = with lib; {
      description = "A better user experience for viewing and interacting with Vim marks";
      homepage = "https://github.com/chentoast/marks.nvim";
      license = with licenses; [ mit ];
    };
  };
  distant-nvim = buildVimPluginFrom2Nix {
    pname = "distant-nvim";
    version = "2021-11-13";
    src = fetchurl {
      url = "https://github.com/chipsenkbeil/distant.nvim/archive/83e655a75155271a900faf6e8f86d11023d1bb7e.tar.gz";
      sha256 = "1wqwggqcl3hgrfr09cy0qm0n141a951dl511vp035v4jh040x720";
    };
    meta = with lib; {
      description = "🚧 (Alpha stage software) Edit files, run programs, and work with LSP on a remote machine from the comfort of your local environment 🚧";
      homepage = "https://github.com/chipsenkbeil/distant.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  impulse-nvim = buildVimPluginFrom2Nix {
    pname = "impulse-nvim";
    version = "2022-06-26";
    src = fetchurl {
      url = "https://github.com/chrsm/impulse.nvim/archive/f96742d0b5ece74fa5a8509b6ea51847fa473a67.tar.gz";
      sha256 = "0shk2ibfr8dfqq3ndbjy7404iyjl80ib6if5kzdn8ys4w7z1vfd0";
    };
    meta = with lib; {
      description = "neovim notion.so client";
      homepage = "https://github.com/chrsm/impulse.nvim";
      license = with licenses; [ mit ];
    };
  };
  paramount-ng-nvim = buildVimPluginFrom2Nix {
    pname = "paramount-ng-nvim";
    version = "2022-06-18";
    src = fetchurl {
      url = "https://github.com/chrsm/paramount-ng.nvim/archive/7caa69335cdc36f735af781d30faa9b1ce105610.tar.gz";
      sha256 = "1860r5yjsrzm2phgxgcr8mxab5prpzmg7yjfss9203cmdc6v7vri";
    };
    meta = with lib; {
      description = "neovim-first paramount colorscheme";
      homepage = "https://github.com/chrsm/paramount-ng.nvim";
      license = with licenses; [ mit ];
    };
  };
  jazz-nvim = buildVimPluginFrom2Nix {
    pname = "jazz-nvim";
    version = "2019-04-30";
    src = fetchurl {
      url = "https://github.com/clojure-vim/jazz.nvim/archive/4537586c70aee9fdc88ad0687c106cceefd0991e.tar.gz";
      sha256 = "0x6w4jvqk5fn9vzw3w0871xd8qvihrk86i5kw6mv33av2a9h8a94";
    };
    meta = with lib; {
      description = "Acid + Impromptu = Jazz";
      homepage = "https://github.com/clojure-vim/jazz.nvim";
    };
  };
  coc-svelte = buildVimPluginFrom2Nix {
    pname = "coc-svelte";
    version = "2022-03-14";
    src = fetchurl {
      url = "https://github.com/coc-extensions/coc-svelte/archive/7dda98527c0831e287ae8cd1c85cfc958c949d4a.tar.gz";
      sha256 = "1d3pyp1z2f4wzpdypjskpj0chnpjxsdrsw6l82wz62xz8v0l02f8";
    };
    meta = with lib; {
      description = "svelte support for (Neo)Vim";
      homepage = "https://github.com/coc-extensions/coc-svelte";
      license = with licenses; [ mit ];
    };
  };
  nvim-biscuits = buildVimPluginFrom2Nix {
    pname = "nvim-biscuits";
    version = "2022-06-26";
    src = fetchurl {
      url = "https://github.com/code-biscuits/nvim-biscuits/archive/75f5e457b97ac0ac11cd94f2f861eceae05b19b0.tar.gz";
      sha256 = "0z1fq8q0c7f62d4lj6sb43gd8vikx6y9cff9m7rag96nqrqqxsav";
    };
    meta = with lib; {
      description = "A neovim port of Assorted Biscuits. Ends up with more supported languages too";
      homepage = "https://github.com/code-biscuits/nvim-biscuits";
      license = with licenses; [ mit ];
    };
  };
  one-monokai-nvim = buildVimPluginFrom2Nix {
    pname = "one-monokai-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/cpea2506/one_monokai.nvim/archive/1a46380eecf07048d12b6512d37e8f0841d58b61.tar.gz";
      sha256 = "01089k71baq4crp5cjwkqrqwg6dx53q4gzp2nwrrpq3pqgsbghvl";
    };
    meta = with lib; {
      description = "One Monokai theme for Neovim";
      homepage = "https://github.com/cpea2506/one_monokai.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-go = buildVimPluginFrom2Nix {
    pname = "nvim-go";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/crispgm/nvim-go/archive/d412a533b0e681a0b245d91e91dc228d313364b1.tar.gz";
      sha256 = "13mzi4jmmvs3lp8b38f0lrgj7ig9kq8wl8bgz80x93rb2d4118fh";
    };
    meta = with lib; {
      description = "A minimal implementation of Golang development plugin for Neovim";
      homepage = "https://github.com/crispgm/nvim-go";
      license = with licenses; [ mit ];
    };
  };
  nvim-tabline = buildVimPluginFrom2Nix {
    pname = "nvim-tabline";
    version = "2022-02-21";
    src = fetchurl {
      url = "https://github.com/crispgm/nvim-tabline/archive/cb908965b67aac4093162523b8939a7c568adc30.tar.gz";
      sha256 = "1lha3czdb5vnr9rf2f992k8qsgdg1d4d61zr5kg8vm9gxfdnmdgc";
    };
    meta = with lib; {
      description = "nvim port of tabline.vim with Lua";
      homepage = "https://github.com/crispgm/nvim-tabline";
      license = with licenses; [ mit ];
    };
  };
  telescope-heading-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-heading-nvim";
    version = "2022-05-18";
    src = fetchurl {
      url = "https://github.com/crispgm/telescope-heading.nvim/archive/6f54230d738b1e582e3a4c983722ce795aca101c.tar.gz";
      sha256 = "1bmsqa2cwc8j2pr3nmrpbqcb5mg5l9gbfcjmva79hi21yl9lsfqg";
    };
    meta = with lib; {
      description = "An extension for telescope.nvim that allows you to switch between headings";
      homepage = "https://github.com/crispgm/telescope-heading.nvim";
      license = with licenses; [ mit ];
    };
  };
  bookmarks-nvim = buildVimPluginFrom2Nix {
    pname = "bookmarks-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/crusj/bookmarks.nvim/archive/31c74300271a702734a8eb17abf0a5359c6715b3.tar.gz";
      sha256 = "0n5rx86kxlspwclg56jp0hpscjfqx8vd85f9lw74slwpkvndzlrv";
    };
    meta = with lib; {
      description = "Remember file locations and sort by time and frequency";
      homepage = "https://github.com/crusj/bookmarks.nvim";
      license = with licenses; [ mit ];
    };
  };
  hierarchy-tree-go-nvim = buildVimPluginFrom2Nix {
    pname = "hierarchy-tree-go-nvim";
    version = "2022-06-22";
    src = fetchurl {
      url = "https://github.com/crusj/hierarchy-tree-go.nvim/archive/a35b3414b29d86eed86e7bdae206a6221e97a621.tar.gz";
      sha256 = "1v2a2axmkp9bfi9zjgj5jvz9b65hw6faq81qdwzd0nxa50b2fp08";
    };
    meta = with lib; {
      description = "Golang Hierarchy tree views";
      homepage = "https://github.com/crusj/hierarchy-tree-go.nvim";
      license = with licenses; [ mit ];
    };
  };
  structrue-go-nvim = buildVimPluginFrom2Nix {
    pname = "structrue-go-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/crusj/structrue-go.nvim/archive/884e63ad4502a8c9752cd72d488401b6bd554831.tar.gz";
      sha256 = "1cxbhynn7c2hmckih6fpacvw91f7qp9h3lgaxx9h3kvci2hrbp1k";
    };
    meta = with lib; {
      description = "A better structured display of golang symbols information";
      homepage = "https://github.com/crusj/structrue-go.nvim";
      license = with licenses; [ mit ];
    };
  };
  yaml-nvim = buildVimPluginFrom2Nix {
    pname = "yaml-nvim";
    version = "2022-07-04";
    src = fetchurl {
      url = "https://github.com/cuducos/yaml.nvim/archive/ee6143a61325ae06938fd210a86406bef6093471.tar.gz";
      sha256 = "1lpccyj5c2m4wkwlyh3sggj242qs2lc7iwf7cln30x1zvpjkiwww";
    };
    meta = with lib; {
      description = "🍒 YAML toolkit for Neovim users";
      homepage = "https://github.com/cuducos/yaml.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  telescope-tmuxinator-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-tmuxinator-nvim";
    version = "2021-08-19";
    src = fetchurl {
      url = "https://github.com/danielpieper/telescope-tmuxinator.nvim/archive/9b51e2dc870c46aa57e277bb70b2c1c000a7a857.tar.gz";
      sha256 = "0g39l6dc0wh0grzh4nc6q8w82plsdb9i1dqhkycbimnhmij1cf3k";
    };
    meta = with lib; {
      description = "Integration for tmuxinator with telescope.nvim";
      homepage = "https://github.com/danielpieper/telescope-tmuxinator.nvim";
      license = with licenses; [ mit ];
    };
  };
  neogen = buildVimPluginFrom2Nix {
    pname = "neogen";
    version = "2022-06-15";
    src = fetchurl {
      url = "https://github.com/danymat/neogen/archive/c5a0c39753808faa41dea009d41dd686732c6774.tar.gz";
      sha256 = "1s4dhzh0z483421aw8337x4av58vba6qn2nlbqb1v1hc7b5ypzvq";
    };
    meta = with lib; {
      description = "A better annotation generator. Supports multiple languages and annotation conventions";
      homepage = "https://github.com/danymat/neogen";
      license = with licenses; [ gpl3Only ];
    };
  };
  bubbly-nvim = buildVimPluginFrom2Nix {
    pname = "bubbly-nvim";
    version = "2022-05-31";
    src = fetchurl {
      url = "https://github.com/datwaft/bubbly.nvim/archive/d1303d951e905c36d33a272c77bcb7e479e637ab.tar.gz";
      sha256 = "0psc7m33r0ppfmxpnl0m6fmii49mh5a6w0xjbn3n1011b3z0i9wn";
    };
    meta = with lib; {
      description = "Bubbly statusline for neovim";
      homepage = "https://github.com/datwaft/bubbly.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-markdown-preview = buildVimPluginFrom2Nix {
    pname = "nvim-markdown-preview";
    version = "2022-05-21";
    src = fetchurl {
      url = "https://github.com/davidgranstrom/nvim-markdown-preview/archive/3d6f941beb223b23122973d077522e9e2ee33068.tar.gz";
      sha256 = "102jzk5f5nnfi4h6lrjd1mj3800cvxr0n7f50ivcp3gcvbhzbzy8";
    };
    meta = with lib; {
      description = "Markdown preview for neovim using pandoc and live-server";
      homepage = "https://github.com/davidgranstrom/nvim-markdown-preview";
      license = with licenses; [ gpl3Only ];
    };
  };
  osc-nvim = buildVimPluginFrom2Nix {
    pname = "osc-nvim";
    version = "2021-08-02";
    src = fetchurl {
      url = "https://github.com/davidgranstrom/osc.nvim/archive/cc27b8a5e3ffd4cb1d8c9eaa4a2082cbaf9e4c77.tar.gz";
      sha256 = "175xm7gf08sqcpwgv6yp3k79ppxm19ysvd1p5l1zpzf4p6rhv8h6";
    };
    meta = with lib; {
      description = "Open Sound Control for Neovim";
      homepage = "https://github.com/davidgranstrom/osc.nvim";
    };
  };
  scnvim = buildVimPluginFrom2Nix {
    pname = "scnvim";
    version = "2022-07-04";
    src = fetchurl {
      url = "https://github.com/davidgranstrom/scnvim/archive/746cc0db820d02a9c36b8f9ba2eac9725fa73107.tar.gz";
      sha256 = "0zaapid8pym2igyp48yyqrn4fmnglyk4j93sgjn1nisd5smxkyis";
    };
    meta = with lib; {
      description = "Neovim frontend for SuperCollider";
      homepage = "https://github.com/davidgranstrom/scnvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-snippy = buildVimPluginFrom2Nix {
    pname = "nvim-snippy";
    version = "2022-07-19";
    src = fetchurl {
      url = "https://github.com/dcampos/nvim-snippy/archive/dc5474332379c31ac8c74e1e5d1c7a27f0b8177e.tar.gz";
      sha256 = "0lgdzdmnggq7w0afdwrmb00l8zjlijq8akmyzrp9vz52dmqsz1zi";
    };
    meta = with lib; {
      description = "Snippet plugin for Neovim";
      homepage = "https://github.com/dcampos/nvim-snippy";
      license = with licenses; [ mit ];
    };
  };
  cinnamon-nvim = buildVimPluginFrom2Nix {
    pname = "cinnamon-nvim";
    version = "2022-07-13";
    src = fetchurl {
      url = "https://github.com/declancm/cinnamon.nvim/archive/7594df88c798df7a9cf9f4bf14e7fd145035d71d.tar.gz";
      sha256 = "0nly3kgf277kzh8w0wc1zqpf8a3l9brkwr5jk1k4g668n4y1pkf7";
    };
    meta = with lib; {
      description = "Smooth scrolling for ANY movement command 🤯. A Neovim plugin written in Lua!";
      homepage = "https://github.com/declancm/cinnamon.nvim";
    };
  };
  windex-nvim = buildVimPluginFrom2Nix {
    pname = "windex-nvim";
    version = "2022-07-12";
    src = fetchurl {
      url = "https://github.com/declancm/windex.nvim/archive/1e86cba6f6f55ced60d17d6c6ebd51388a637b86.tar.gz";
      sha256 = "163gvsx0nx3yd45yn9aqfiyhp0asfd7icagj4l2xkwbasbbyg0lx";
    };
    meta = with lib; {
      description = "🧼 Clean window maximizing, terminal toggling, window/tmux pane movements and more!";
      homepage = "https://github.com/declancm/windex.nvim";
      license = with licenses; [ mit ];
    };
  };
  bullets-vim = buildVimPluginFrom2Nix {
    pname = "bullets-vim";
    version = "2022-01-30";
    src = fetchurl {
      url = "https://github.com/dkarter/bullets.vim/archive/f3b4ae71f60b5723077a77cfe9e8776a3ca553ac.tar.gz";
      sha256 = "0alv78kn7j09d72kgxv3dq6vjdx2jrq16ngmvg2hjvjq88d1594z";
    };
    meta = with lib; {
      description = "🔫 Bullets.vim is a Vim/NeoVim plugin for automated bullet lists";
      homepage = "https://github.com/dkarter/bullets.vim";
    };
  };
  vim = buildVimPluginFrom2Nix {
    pname = "vim";
    version = "2022-03-24";
    src = fetchurl {
      url = "https://github.com/dracula/vim/archive/d7723a842a6cfa2f62cf85530ab66eb418521dc2.tar.gz";
      sha256 = "0x6k5sh1kh9m448zd3a9sfxkgl24hlxbip7gxk16xx9x2sljj9by";
    };
    meta = with lib; {
      description = "🧛🏻‍♂️ Dark theme for Vim";
      homepage = "https://github.com/dracula/vim";
      license = with licenses; [ mit ];
    };
  };
  tree-climber-nvim = buildVimPluginFrom2Nix {
    pname = "tree-climber-nvim";
    version = "2022-07-02";
    src = fetchurl {
      url = "https://github.com/drybalka/tree-climber.nvim/archive/06588baea4e8faca29645aeca7de4a76f8b83eba.tar.gz";
      sha256 = "0v0ick22phgczlgzf6x0caw1s7nf0mfcdmkz7908r33n4ralmny3";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/drybalka/tree-climber.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-scrollview = buildVimPluginFrom2Nix {
    pname = "nvim-scrollview";
    version = "2022-06-08";
    src = fetchurl {
      url = "https://github.com/dstein64/nvim-scrollview/archive/f8308c3c91b7879c3286554dda484bcf973df6ad.tar.gz";
      sha256 = "01yy6bbvqrb4im0d92v6hjh8bmcgr32mc382vk2anvz36z75lw0y";
    };
    meta = with lib; {
      description = "📜📶 A Neovim plugin that displays interactive vertical scrollbars";
      homepage = "https://github.com/dstein64/nvim-scrollview";
      license = with licenses; [ mit ];
    };
  };
  specs-nvim = buildVimPluginFrom2Nix {
    pname = "specs-nvim";
    version = "2021-11-12";
    src = fetchurl {
      url = "https://github.com/edluffy/specs.nvim/archive/e043580a65409ea071dfe34e94284959fd24e3be.tar.gz";
      sha256 = "09py0pgzjq7cign8mybma7ivmigb5irfjn4v102yd92a6g4d6r2b";
    };
    meta = with lib; {
      description = "👓 A fast and lightweight Neovim lua plugin to keep an eye on where your cursor has jumped";
      homepage = "https://github.com/edluffy/specs.nvim";
    };
  };
  goimpl-nvim = buildVimPluginFrom2Nix {
    pname = "goimpl-nvim";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/edolphin-ydf/goimpl.nvim/archive/df010c46af75f3231e5369e60dd39a69fbc9449b.tar.gz";
      sha256 = "1jmla4278ikmzy3m67aal2l837qscrd7d8525fj15mdq0asm1laf";
    };
    meta = with lib; {
      description = "Generate stub for interface on a type";
      homepage = "https://github.com/edolphin-ydf/goimpl.nvim";
    };
  };
  clipboard-image-nvim = buildVimPluginFrom2Nix {
    pname = "clipboard-image-nvim";
    version = "2022-06-13";
    src = fetchurl {
      url = "https://github.com/ekickx/clipboard-image.nvim/archive/ed2ddad45b0dc33c501dcf4c4750fcb2006b26af.tar.gz";
      sha256 = "1x7k0mdr1zcvs6xvhxfd5gxgqh9sb5vqiiyy0hdbhp9vjjazi8vn";
    };
    meta = with lib; {
      description = "Neovim Lua plugin to paste image from clipboard";
      homepage = "https://github.com/ekickx/clipboard-image.nvim";
      license = with licenses; [ mit ];
    };
  };
  dirbuf-nvim = buildVimPluginFrom2Nix {
    pname = "dirbuf-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/elihunter173/dirbuf.nvim/archive/4cd1a2c0b2c2fb9e06070c8152592630737eb55c.tar.gz";
      sha256 = "1xas0301kynhxq715a5yr9hhl39lm6xjc1k0knp524mfk6pif01m";
    };
    meta = with lib; {
      description = "A file manager for Neovim which lets you edit your filesystem like you edit text";
      homepage = "https://github.com/elihunter173/dirbuf.nvim";
      license = with licenses; [ agpl3Only ];
    };
  };
  carbon-now-nvim = buildVimPluginFrom2Nix {
    pname = "carbon-now-nvim";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/ellisonleao/carbon-now.nvim/archive/e64e29e5b89d20548e792b3d6c3995c08d7ee636.tar.gz";
      sha256 = "1b89fgwschm8dvj8qizzpn2nlymq5s9myfrjxjbb4f4d5r7a07wv";
    };
    meta = with lib; {
      description = "Create beautiful code snippets directly from your neovim terminal";
      homepage = "https://github.com/ellisonleao/carbon-now.nvim";
    };
  };
  glow-nvim = buildVimPluginFrom2Nix {
    pname = "glow-nvim";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/ellisonleao/glow.nvim/archive/764527caeb36cd68cbf3f6d905584750cb02229d.tar.gz";
      sha256 = "0yb6j0jj629c8xlljclmsn4m4j7jys13vn98hnw2afs7w3sqzp5s";
    };
    meta = with lib; {
      description = "A markdown preview directly in your neovim";
      homepage = "https://github.com/ellisonleao/glow.nvim";
      license = with licenses; [ mit ];
    };
  };
  gruvbox-nvim = buildVimPluginFrom2Nix {
    pname = "gruvbox-nvim";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/ellisonleao/gruvbox.nvim/archive/29c50f1327d9d84436e484aac362d2fa6bca590b.tar.gz";
      sha256 = "1mcw92nvgx1hnf7f82qywpbbc707y1fgq0izfv8dcdlq87fysz9s";
    };
    meta = with lib; {
      description = "Lua port of the most famous vim colorscheme";
      homepage = "https://github.com/ellisonleao/gruvbox.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-plugin-template = buildVimPluginFrom2Nix {
    pname = "nvim-plugin-template";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/ellisonleao/nvim-plugin-template/archive/6fa91d363ca817a3b2e83fb3862e0bc00f665eef.tar.gz";
      sha256 = "1viiybavmdzd0z00vy28f41hapbkl338yzczkwpgw2zxjcifbyak";
    };
    meta = with lib; {
      description = "A neovim plugin template for github repos";
      homepage = "https://github.com/ellisonleao/nvim-plugin-template";
    };
  };
  nvim-dev-container = buildVimPluginFrom2Nix {
    pname = "nvim-dev-container";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/esensar/nvim-dev-container/archive/4d01b653069ae00dcb8161b86ef337eca02b0bae.tar.gz";
      sha256 = "1wz03wqajrci4aynqwv27zm8hvhdm74zd65w967b08slh3fi3av5";
    };
    meta = with lib; {
      description = "Neovim dev container support - Mirror of https://codeberg.org/esensar/nvim-dev-container";
      homepage = "https://github.com/esensar/nvim-dev-container";
      license = with licenses; [ mit ];
    };
  };
  nvim-lastplace = buildVimPluginFrom2Nix {
    pname = "nvim-lastplace";
    version = "2022-07-05";
    src = fetchurl {
      url = "https://github.com/ethanholz/nvim-lastplace/archive/ecced899435c6bcdd81becb5efc6d5751d0dc4c8.tar.gz";
      sha256 = "04yxqwqhwzsxplgq9ql2y8g5ilikrk8kbc2xa6hzsw3rqdhgdfb3";
    };
    meta = with lib; {
      description = "A Lua rewrite of vim-lastplace";
      homepage = "https://github.com/ethanholz/nvim-lastplace";
      license = with licenses; [ mit ];
    };
  };
  vim-svelte = buildVimPluginFrom2Nix {
    pname = "vim-svelte";
    version = "2022-02-17";
    src = fetchurl {
      url = "https://github.com/evanleck/vim-svelte/archive/1080030d6a1bc6582389c133a07552ba0a442410.tar.gz";
      sha256 = "14f0bjpdl9i2khsh79hss1ksm4pabbl60c46dc5cdm9sp3lbylqv";
    };
    meta = with lib; {
      description = "Vim syntax highlighting and indentation for Svelte 3 components";
      homepage = "https://github.com/evanleck/vim-svelte";
    };
  };
  git-blame-nvim = buildVimPluginFrom2Nix {
    pname = "git-blame-nvim";
    version = "2022-06-15";
    src = fetchurl {
      url = "https://github.com/f-person/git-blame.nvim/archive/1bb73289929107309d2d90f7582ece5e9436bfd8.tar.gz";
      sha256 = "0b0md38ikjazcmlsfk04gb5jvrpgq2ydrxi0nx1hndrhqk27nkly";
    };
    meta = with lib; {
      description = "Git Blame plugin for Neovim written in Lua";
      homepage = "https://github.com/f-person/git-blame.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  cmp-spell = buildVimPluginFrom2Nix {
    pname = "cmp-spell";
    version = "2021-10-19";
    src = fetchurl {
      url = "https://github.com/f3fora/cmp-spell/archive/5602f1a0de7831f8dad5b0c6db45328fbd539971.tar.gz";
      sha256 = "1qmc643qpa3qapa40nri1s3fz3ccxil34dxazbz8250ipm8w2bp7";
    };
    meta = with lib; {
      description = "spell source for nvim-cmp based on vim's spellsuggest";
      homepage = "https://github.com/f3fora/cmp-spell";
    };
  };
  bufdelete-nvim = buildVimPluginFrom2Nix {
    pname = "bufdelete-nvim";
    version = "2022-05-22";
    src = fetchurl {
      url = "https://github.com/famiu/bufdelete.nvim/archive/46255e4a76c4fb450a94885527f5e58a7d96983c.tar.gz";
      sha256 = "0b58a10n0kj8fvlw1yk2pvgxlwy0p64czmfg2v158qhkf19d91qa";
    };
    meta = with lib; {
      description = "Delete Neovim buffers without losing window layout";
      homepage = "https://github.com/famiu/bufdelete.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  feline-nvim = buildVimPluginFrom2Nix {
    pname = "feline-nvim";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/feline-nvim/feline.nvim/archive/2962c8c4a67f41ef35c58aa367ff2afb7a9691d3.tar.gz";
      sha256 = "00yywah2z6pdh631r1p5n4x61g75jb9db3fwf211mkhh4iawsi79";
    };
    meta = with lib; {
      description = "A minimal, stylish and customizable statusline for Neovim written in Lua";
      homepage = "https://github.com/feline-nvim/feline.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  falcon = buildVimPluginFrom2Nix {
    pname = "falcon";
    version = "2021-12-19";
    src = fetchurl {
      url = "https://github.com/fenetikm/falcon/archive/01cc57decb4086644b07ba100f22fed770c91428.tar.gz";
      sha256 = "1n86bwq6fy8wbar5ydjz5y134nw6h443w781wvaw2z8psdxp9013";
    };
    meta = with lib; {
      description = "A colour scheme for terminals, Vim and friends";
      homepage = "https://github.com/fenetikm/falcon";
      license = with licenses; [ mit ];
    };
  };
  lsp-colors-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-colors-nvim";
    version = "2021-10-22";
    src = fetchurl {
      url = "https://github.com/folke/lsp-colors.nvim/archive/517fe3ab6b63f9907b093bc9443ef06b56f804f3.tar.gz";
      sha256 = "08bpig36ip46z39sxl8j7cfppsizqvhgwfc74fgd2r0kv3741cki";
    };
    meta = with lib; {
      description = "🌈  Plugin that creates missing LSP diagnostics highlight groups for color schemes that don't yet support the Neovim 0.5 builtin LSP client";
      homepage = "https://github.com/folke/lsp-colors.nvim";
    };
  };
  todo-comments-nvim = buildVimPluginFrom2Nix {
    pname = "todo-comments-nvim";
    version = "2022-01-19";
    src = fetchurl {
      url = "https://github.com/folke/todo-comments.nvim/archive/98b1ebf198836bdc226c0562b9f906584e6c400e.tar.gz";
      sha256 = "04a539jfiv25jayfd2rmx4pzk6ibjb9cdh0lzwihvrixkv1j746h";
    };
    meta = with lib; {
      description = "✅  Highlight, list and search todo comments in your projects";
      homepage = "https://github.com/folke/todo-comments.nvim";
    };
  };
  tokyonight-nvim = buildVimPluginFrom2Nix {
    pname = "tokyonight-nvim";
    version = "2021-12-31";
    src = fetchurl {
      url = "https://github.com/folke/tokyonight.nvim/archive/8223c970677e4d88c9b6b6d81bda23daf11062bb.tar.gz";
      sha256 = "1qjac1wkmix24bg3ms7c8fiklm6s5mm1hm4qc9n3yli608shfx2n";
    };
    meta = with lib; {
      description = "🏙  A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish";
      homepage = "https://github.com/folke/tokyonight.nvim";
      license = with licenses; [ mit ];
    };
  };
  trouble-nvim = buildVimPluginFrom2Nix {
    pname = "trouble-nvim";
    version = "2022-05-09";
    src = fetchurl {
      url = "https://github.com/folke/trouble.nvim/archive/da61737d860ddc12f78e638152834487eabf0ee5.tar.gz";
      sha256 = "0n37sp3c2p9si195gj21c1n1fqj5029fkxi06jvvsaimh24mra5y";
    };
    meta = with lib; {
      description = "🚦 A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing";
      homepage = "https://github.com/folke/trouble.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  twilight-nvim = buildVimPluginFrom2Nix {
    pname = "twilight-nvim";
    version = "2021-08-06";
    src = fetchurl {
      url = "https://github.com/folke/twilight.nvim/archive/8ab43c0fdc246fdd82382d7ef4ec383f8f755ef9.tar.gz";
      sha256 = "0ffggdlmky4xz4lcibc3nndnpy90xmmr537j71sgnd0iwapqb06w";
    };
    meta = with lib; {
      description = "🌅  Twilight is a Lua plugin for Neovim 0.5 that dims inactive portions of the code you're editing using TreeSitter";
      homepage = "https://github.com/folke/twilight.nvim";
    };
  };
  which-key-nvim = buildVimPluginFrom2Nix {
    pname = "which-key-nvim";
    version = "2022-05-04";
    src = fetchurl {
      url = "https://github.com/folke/which-key.nvim/archive/bd4411a2ed4dd8bb69c125e339d837028a6eea71.tar.gz";
      sha256 = "08vvjmhw1cgffjwqqwnmf576axlpzkdjbpvzrqlykxkyqxc82rx8";
    };
    meta = with lib; {
      description = "💥   Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing";
      homepage = "https://github.com/folke/which-key.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  zen-mode-nvim = buildVimPluginFrom2Nix {
    pname = "zen-mode-nvim";
    version = "2021-11-07";
    src = fetchurl {
      url = "https://github.com/folke/zen-mode.nvim/archive/f1cc53d32b49cf962fb89a2eb0a31b85bb270f7c.tar.gz";
      sha256 = "0322nmqj810i5plwxjalhwqnym7cmsd6x1j7bcbxw0dh3nlsp6z5";
    };
    meta = with lib; {
      description = "🧘  Distraction-free coding for Neovim";
      homepage = "https://github.com/folke/zen-mode.nvim";
    };
  };
  knap = buildVimPluginFrom2Nix {
    pname = "knap";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/frabjous/knap/archive/df49ebb4d21b76bdd548e72ec11619373581c79c.tar.gz";
      sha256 = "0cvr4aqj5yj21qby3jvlp6y4m31fw7g045ql5fgabfy89q8dpsji";
    };
    meta = with lib; {
      description = "Neovim plugin for creating live-updating-as-you-type previews of LaTeX, markdown, and other files in the viewer of your choice";
      homepage = "https://github.com/frabjous/knap";
      license = with licenses; [ gpl3Only ];
    };
  };
  JpFormat-vim = buildVimPluginFrom2Nix {
    pname = "JpFormat-vim";
    version = "2019-07-12";
    src = fetchurl {
      url = "https://github.com/fuenor/JpFormat.vim/archive/02736fc184e15efa8a233caaec037aabb90ad706.tar.gz";
      sha256 = "021ivm7dhy67fi3mb9zjrzhfwg2k08cab9a55rz9af1fkdq51a8v";
    };
    meta = with lib; {
      description = "gq and text formatter for japanese text";
      homepage = "https://github.com/fuenor/JpFormat.vim";
    };
  };
  cryptoprice-nvim = buildVimPluginFrom2Nix {
    pname = "cryptoprice-nvim";
    version = "2022-03-18";
    src = fetchurl {
      url = "https://github.com/gaborvecsei/cryptoprice.nvim/archive/09bdffc47b3a959bc6d9065fb25b120fc84cdea3.tar.gz";
      sha256 = "1w39h0hfw2apay2lf90f83lpbiqakzina38w2ja2m2b1sb2a6nln";
    };
    meta = with lib; {
      description = "NeoVim plugin with which you can check the price of your favourite cryptos";
      homepage = "https://github.com/gaborvecsei/cryptoprice.nvim";
    };
  };
  memento-nvim = buildVimPluginFrom2Nix {
    pname = "memento-nvim";
    version = "2022-03-18";
    src = fetchurl {
      url = "https://github.com/gaborvecsei/memento.nvim/archive/7e5e5a86ccaec2892fc2d8197fc01a25d1cf8951.tar.gz";
      sha256 = "1758ghxl7z4hrvz76hp4lwg5z1dih24hn6z6cxq84wbbfgzjd7wj";
    };
    meta = with lib; {
      description = "A NeoVim plugin which remembers where you've been";
      homepage = "https://github.com/gaborvecsei/memento.nvim";
    };
  };
  cutlass-nvim = buildVimPluginFrom2Nix {
    pname = "cutlass-nvim";
    version = "2022-05-16";
    src = fetchurl {
      url = "https://github.com/gbprod/cutlass.nvim/archive/7611e52cd27b3bd2f391c56352271d8d272fc637.tar.gz";
      sha256 = "0anfwyl0bqwdvs5bfrnqx2w5hh9slr4s5aakmbsn28akspdlr8v3";
    };
    meta = with lib; {
      description = "Plugin that adds a 'cut' operation separate from 'delete' ";
      homepage = "https://github.com/gbprod/cutlass.nvim";
      license = with licenses; [ wtfpl ];
    };
  };
  phpactor-nvim = buildVimPluginFrom2Nix {
    pname = "phpactor-nvim";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/gbprod/phpactor.nvim/archive/b476310e709febce8a3d1c56ce65c99ca20abcd9.tar.gz";
      sha256 = "0hd6y6cp64q9m172fgg93fj6ybjknlcyf1f9vw94vrwinx6sp1my";
    };
    meta = with lib; {
      description = "Lua version of the Phpactor vim plugin to take advantage of the latest Neovim features";
      homepage = "https://github.com/gbprod/phpactor.nvim";
    };
  };
  stay-in-place-nvim = buildVimPluginFrom2Nix {
    pname = "stay-in-place-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/gbprod/stay-in-place.nvim/archive/18572d2a734cb0fa40a521698d0507da41552ee7.tar.gz";
      sha256 = "0brn3f1bicnb6jq0qqvgq2h4xj1h3ga27pj6p9jai5w3qp5kj413";
    };
    meta = with lib; {
      description = "Neovim plugin that prevent cursor from moving when using shift and filter actions";
      homepage = "https://github.com/gbprod/stay-in-place.nvim";
      license = with licenses; [ wtfpl ];
    };
  };
  substitute-nvim = buildVimPluginFrom2Nix {
    pname = "substitute-nvim";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/gbprod/substitute.nvim/archive/a2307c36b2504feaa2664acb6fad5f39bbe123d4.tar.gz";
      sha256 = "1xwg65r8cqjcinynjwbvrmwq8kcjag9vi68w5n643ycwl0b3ba5s";
    };
    meta = with lib; {
      description = "Neovim plugin introducing a new operators motions to quickly replace and exchange text";
      homepage = "https://github.com/gbprod/substitute.nvim";
      license = with licenses; [ wtfpl ];
    };
  };
  yanky-nvim = buildVimPluginFrom2Nix {
    pname = "yanky-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/gbprod/yanky.nvim/archive/57380fe70758dae6aeac5a304a0b28b3cff3cb5c.tar.gz";
      sha256 = "13ah9wac4idqj2979kypd2dy02dp2xa3lv53ll6n6a9l61y6vkq7";
    };
    meta = with lib; {
      description = "Improved Yank and Put functionalities for Neovim";
      homepage = "https://github.com/gbprod/yanky.nvim";
    };
  };
  wilder-nvim = buildVimPluginFrom2Nix {
    pname = "wilder-nvim";
    version = "2022-06-27";
    src = fetchurl {
      url = "https://github.com/gelguy/wilder.nvim/archive/86f5fb0962bc5954babf267ded6b144d992aef85.tar.gz";
      sha256 = "09gqkrycgq7phc81mlkxl01dyipj6c9a5jgbqdrb2ihz5xxm67bl";
    };
    meta = with lib; {
      description = "A more adventurous wildmenu";
      homepage = "https://github.com/gelguy/wilder.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-commaround = buildVimPluginFrom2Nix {
    pname = "nvim-commaround";
    version = "2022-01-14";
    src = fetchurl {
      url = "https://github.com/gennaro-tedesco/nvim-commaround/archive/46f84e191f44dd7023128e296905fb882a74435f.tar.gz";
      sha256 = "04rgsrjjn58wys0z6riw8njr4194q4qqap03na7l8mz88mbcsi3j";
    };
    meta = with lib; {
      description = "nvim plugin to toggle comments on and off";
      homepage = "https://github.com/gennaro-tedesco/nvim-commaround";
      license = with licenses; [ mit ];
    };
  };
  nvim-jqx = buildVimPluginFrom2Nix {
    pname = "nvim-jqx";
    version = "2022-02-10";
    src = fetchurl {
      url = "https://github.com/gennaro-tedesco/nvim-jqx/archive/26bf7cc5e1942dac9f825dff90e180620c264fe7.tar.gz";
      sha256 = "1p026xj958qpzzxaqj27pfjwd68zpp1xjkhmaqzwypn90pv69cxf";
    };
    meta = with lib; {
      description = "Populate the quickfix with json entries";
      homepage = "https://github.com/gennaro-tedesco/nvim-jqx";
    };
  };
  nvim-peekup = buildVimPluginFrom2Nix {
    pname = "nvim-peekup";
    version = "2021-07-05";
    src = fetchurl {
      url = "https://github.com/gennaro-tedesco/nvim-peekup/archive/e8ad8c7160e1f8ed2a7e4e071110b8b18866b463.tar.gz";
      sha256 = "0p3syg5nk0lqkgcn8yvz7syq7hwm053c4v2j85bcx8wj3xvk16w4";
    };
    meta = with lib; {
      description = "👀 dynamically show content of vim registers";
      homepage = "https://github.com/gennaro-tedesco/nvim-peekup";
      license = with licenses; [ mit ];
    };
  };
  fzf-lsp-nvim = buildVimPluginFrom2Nix {
    pname = "fzf-lsp-nvim";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/gfanto/fzf-lsp.nvim/archive/f8988d7d738a0e9e7aba2f0a9512df6356bbda07.tar.gz";
      sha256 = "138jcq7vfw5awvm4ksgy64yanz791wxkgpyjskhzhxj91ffj1d9m";
    };
    meta = with lib; {
      description = "Enable the power of fzf fuzzy search for the neovim built in lsp";
      homepage = "https://github.com/gfanto/fzf-lsp.nvim";
      license = with licenses; [ mit ];
    };
  };
  leap-nvim = buildVimPluginFrom2Nix {
    pname = "leap-nvim";
    version = "2022-07-24";
    src = fetchurl {
      url = "https://github.com/ggandor/leap.nvim/archive/4e6e6afe81052483bf0900dc2bb8882194b7be50.tar.gz";
      sha256 = "00qs2gxiw67h4az5scbb8c2md851gqcwvcm8s62v8ymmfqkl8jk2";
    };
    meta = with lib; {
      description = "🦘 A unified, minimal, extensible interface for lightning-fast movements in the visible editor area";
      homepage = "https://github.com/ggandor/leap.nvim";
      license = with licenses; [ mit ];
    };
  };
  lightspeed-nvim = buildVimPluginFrom2Nix {
    pname = "lightspeed-nvim";
    version = "2022-07-04";
    src = fetchurl {
      url = "https://github.com/ggandor/lightspeed.nvim/archive/a4b4277d143270c6a7d85ef2e1574a1bbeab6677.tar.gz";
      sha256 = "1dkg3czcifycidjkbv65pagr1zfhbl6pqq9jfjvl8hjnfggv2pah";
    };
    meta = with lib; {
      description = "🌌 Next-generation motion plugin using incremental input processing, allowing for unparalleled speed with minimal cognitive effort";
      homepage = "https://github.com/ggandor/lightspeed.nvim";
      license = with licenses; [ mit ];
    };
  };
  cybu-nvim = buildVimPluginFrom2Nix {
    pname = "cybu-nvim";
    version = "2022-06-25";
    src = fetchurl {
      url = "https://github.com/ghillb/cybu.nvim/archive/aee926d1bc069194ae32e0e490d52fa3c1ed1bb7.tar.gz";
      sha256 = "0ai8qah02axghvlx85yzxp3k2k9d7zlxj7yhxi1lk9wly3g89msr";
    };
    meta = with lib; {
      description = "Neovim plugin that offers context when cycling buffers in the form of a customizable notification window";
      homepage = "https://github.com/ghillb/cybu.nvim";
      license = with licenses; [ mit ];
    };
  };
  copilot-vim = buildVimPluginFrom2Nix {
    pname = "copilot-vim";
    version = "2022-06-17";
    src = fetchurl {
      url = "https://github.com/github/copilot.vim/archive/c2e75a3a7519c126c6fdb35984976df9ae13f564.tar.gz";
      sha256 = "0k84wix78gmv9ln7zbhzdfrjlz69qw2paf5736sz2g462hm40gwv";
    };
    meta = with lib; {
      description = "Neovim plugin for GitHub Copilot";
      homepage = "https://github.com/github/copilot.vim";
    };
  };
  firenvim = buildVimPluginFrom2Nix {
    pname = "firenvim";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/glacambre/firenvim/archive/f679455c294c62eddee86959cfc9f1b1f79fe97d.tar.gz";
      sha256 = "1r281hp2myqizb8jg0v9yx3qngrj4j5dd1bla32wjwjw5jfdha8l";
    };
    meta = with lib; {
      description = "Embed Neovim in Chrome, Firefox, Thunderbird & others";
      homepage = "https://github.com/glacambre/firenvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  dashboard-nvim = buildVimPluginFrom2Nix {
    pname = "dashboard-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/glepnir/dashboard-nvim/archive/6e48e4fd8b03b47d09c686b38e968d5dcd261c8d.tar.gz";
      sha256 = "0d4m7gwybiingpnv6q6b43xdybmpl4rmhlma40hf4998iirc4bjw";
    };
    meta = with lib; {
      description = "vim dashboard";
      homepage = "https://github.com/glepnir/dashboard-nvim";
      license = with licenses; [ mit ];
    };
  };
  indent-guides-nvim = buildVimPluginFrom2Nix {
    pname = "indent-guides-nvim";
    version = "2021-03-26";
    src = fetchurl {
      url = "https://github.com/glepnir/indent-guides.nvim/archive/e261e5a43b5a05557a66b760a4132a6c502cc0e4.tar.gz";
      sha256 = "0yx3w60hp1gjk0wc4ilkazmiqa8r2yhhys0x6csmhzxdk7wpi8bz";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/glepnir/indent-guides.nvim";
      license = with licenses; [ mit ];
    };
  };
  prodoc-nvim = buildVimPluginFrom2Nix {
    pname = "prodoc-nvim";
    version = "2021-01-23";
    src = fetchurl {
      url = "https://github.com/glepnir/prodoc.nvim/archive/106fa335972687ebaa272e9e94aa3059b7b2b0eb.tar.gz";
      sha256 = "19zn15frydgxhz16dfqch03x9ivl6k2b5dll0j73qcbrnac36718";
    };
    meta = with lib; {
      description = "a neovim comment and  annotation plugin using coroutine";
      homepage = "https://github.com/glepnir/prodoc.nvim";
      license = with licenses; [ mit ];
    };
  };
  zephyr-nvim = buildVimPluginFrom2Nix {
    pname = "zephyr-nvim";
    version = "2022-06-22";
    src = fetchurl {
      url = "https://github.com/glepnir/zephyr-nvim/archive/1eea36117a8ca4f3250c0223e78a690cdc720f9e.tar.gz";
      sha256 = "0ldv1400r86qdx57qv2iqv5hl3g8kq5v2qqi93p1j8s61x2lsikr";
    };
    meta = with lib; {
      description = "A dark neovim colorscheme written in lua";
      homepage = "https://github.com/glepnir/zephyr-nvim";
      license = with licenses; [ mit ];
    };
  };
  alpha-nvim = buildVimPluginFrom2Nix {
    pname = "alpha-nvim";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/goolord/alpha-nvim/archive/d688f46090a582be8f9d7b70b4cf999b780e993d.tar.gz";
      sha256 = "18r6rz5jwc4mhijpfrj5pd1p1104ndc8kipnmjg9np3mp2cpgc5r";
    };
    meta = with lib; {
      description = "a lua powered greeter like vim-startify / dashboard-nvim";
      homepage = "https://github.com/goolord/alpha-nvim";
      license = with licenses; [ mit ];
    };
  };
  editorconfig-nvim = buildVimPluginFrom2Nix {
    pname = "editorconfig-nvim";
    version = "2022-07-18";
    src = fetchurl {
      url = "https://github.com/gpanders/editorconfig.nvim/archive/764577498694a1035c7d592149458c5799db69d4.tar.gz";
      sha256 = "0b6p57pmj9l032335iz759s5p8rgpnwqpxfs0rhxy5klsf7r6zkq";
    };
    meta = with lib; {
      description = "EditorConfig plugin for Neovim";
      homepage = "https://github.com/gpanders/editorconfig.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  fcitx-nvim = buildVimPluginFrom2Nix {
    pname = "fcitx-nvim";
    version = "2022-06-25";
    src = fetchurl {
      url = "https://github.com/h-hg/fcitx.nvim/archive/dcb6b70888aa893d3d223bb777d4117bbdac06a7.tar.gz";
      sha256 = "06h1ryjzcznd0w2i973p9kvcwgjdrxf133jh2cgc8xf87z7diwk1";
    };
    meta = with lib; {
      description = "A Neovim plugin writing in Lua to switch and restore fcitx state for each buffer";
      homepage = "https://github.com/h-hg/fcitx.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-context-vt = buildVimPluginFrom2Nix {
    pname = "nvim-context-vt";
    version = "2022-04-19";
    src = fetchurl {
      url = "https://github.com/haringsrob/nvim_context_vt/archive/2407c8c304138e18c0ef42e4dbebb56a3813bbd5.tar.gz";
      sha256 = "06535df0slaqn34wfm3c769i77qm4s4np55xlb2k59hbpzifk1n6";
    };
    meta = with lib; {
      description = "Virtual text context for neovim treesitter";
      homepage = "https://github.com/haringsrob/nvim_context_vt";
      license = with licenses; [ mit ];
    };
  };
  ataraxis-lua = buildVimPluginFrom2Nix {
    pname = "ataraxis-lua";
    version = "2022-07-03";
    src = fetchurl {
      url = "https://github.com/henriquehbr/ataraxis.lua/archive/80c49c37bba3927fbb2cb6477a0e40d2d7002d9f.tar.gz";
      sha256 = "1iqspkbbg5sdvcg8na5v3l7r4zhg2hpikl6rd873jflnav9gkdip";
    };
    meta = with lib; {
      description = "A simple zen mode for improving code readability on neovim";
      homepage = "https://github.com/henriquehbr/ataraxis.lua";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-startup-lua = buildVimPluginFrom2Nix {
    pname = "nvim-startup-lua";
    version = "2022-07-03";
    src = fetchurl {
      url = "https://github.com/henriquehbr/nvim-startup.lua/archive/e7fb9e34e72f7e63c7e0a2a5175603316a5607a1.tar.gz";
      sha256 = "12h7vw3c26s4mq34vv0gikwwp0mqwsifki95xsbdahiiznbjfhlc";
    };
    meta = with lib; {
      description = "Displays neovim startup time";
      homepage = "https://github.com/henriquehbr/nvim-startup.lua";
      license = with licenses; [ mit ];
    };
  };
  nvimux = buildVimPluginFrom2Nix {
    pname = "nvimux";
    version = "2022-05-02";
    src = fetchurl {
      url = "https://github.com/hkupty/nvimux/archive/a2cd0cab0acf6c37d999e0cfd199a9fa126a8dcf.tar.gz";
      sha256 = "0gx8d2p2w1wlcxka2rir0rmyj1zc8nlhb97v092bp8vkvad1am8s";
    };
    meta = with lib; {
      description = "Neovim as a TMUX replacement";
      homepage = "https://github.com/hkupty/nvimux";
      license = with licenses; [ asl20 ];
    };
  };
  vim-emacscommandline = buildVimPluginFrom2Nix {
    pname = "vim-emacscommandline";
    version = "2017-11-24";
    src = fetchurl {
      url = "https://github.com/houtsnip/vim-emacscommandline/archive/3363eeb1f958bd0630448fdaa5f19ba7a834b343.tar.gz";
      sha256 = "0xvx1ds4vjyly5ls56h3wrrww7bplsdwqjljchnjpqlnji2ylxh2";
    };
    meta = with lib; {
      description = "Emacs-style mappings for command-line mode in vim";
      homepage = "https://github.com/houtsnip/vim-emacscommandline";
    };
  };
  cmp-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2022-06-15";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-buffer/archive/62fc67a2b0205136bc3e312664624ba2ab4a9323.tar.gz";
      sha256 = "0vlp44fksx7vc7q3zrmp9i9am4cd6c1fk7qyxizr7lxpls2gjrzx";
    };
    meta = with lib; {
      description = "nvim-cmp source for buffer words";
      homepage = "https://github.com/hrsh7th/cmp-buffer";
      license = with licenses; [ mit ];
    };
  };
  cmp-nvim-lsp = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2022-05-16";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lsp/archive/affe808a5c56b71630f17aa7c38e15c59fd648a8.tar.gz";
      sha256 = "0cxrqcj3jw6d8mksdnjpwak7anw18i2xikv10knj3ynq4n0spq37";
    };
    meta = with lib; {
      description = "nvim-cmp source for neovim builtin LSP client";
      homepage = "https://github.com/hrsh7th/cmp-nvim-lsp";
      license = with licenses; [ mit ];
    };
  };
  cmp-nvim-lua = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lua";
    version = "2021-10-11";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-nvim-lua/archive/d276254e7198ab7d00f117e88e223b4bd8c02d21.tar.gz";
      sha256 = "0jjig1mwqcpm8j92hyracfwgy0kl4l2npls2kqa8ys37chhjhr30";
    };
    meta = with lib; {
      description = "nvim-cmp source for nvim lua";
      homepage = "https://github.com/hrsh7th/cmp-nvim-lua";
    };
  };
  cmp-path = buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/hrsh7th/cmp-path/archive/447c87cdd6e6d6a1d2488b1d43108bfa217f56e1.tar.gz";
      sha256 = "1pdiaynm56jfhm10kd2svjc8i2vfdais1njqly221qwmd9qg2840";
    };
    meta = with lib; {
      description = "nvim-cmp source for path";
      homepage = "https://github.com/hrsh7th/cmp-path";
      license = with licenses; [ mit ];
    };
  };
  nvim-cmp = buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/hrsh7th/nvim-cmp/archive/706371f1300e7c0acb98b346f80dad2dd9b5f679.tar.gz";
      sha256 = "0s7hcas95rnjcw0dg6sp1sfgcrrqszmhz3yzrld2b6six1glwgnp";
    };
    meta = with lib; {
      description = "A completion plugin for neovim coded in Lua";
      homepage = "https://github.com/hrsh7th/nvim-cmp";
      license = with licenses; [ mit ];
    };
  };
  vim-hy = buildVimPluginFrom2Nix {
    pname = "vim-hy";
    version = "2022-07-18";
    src = fetchurl {
      url = "https://github.com/hylang/vim-hy/archive/650574a6095c8d911b471a9f5814129a373728af.tar.gz";
      sha256 = "0f50jr1gkf9k9pw3dpmig45s5cgqal8rzm19vqdx6cpcbx04zs2d";
    };
    meta = with lib; {
      description = "Vim files and plugins for Hy";
      homepage = "https://github.com/hylang/vim-hy";
    };
  };
  coc-tailwindcss = buildVimPluginFrom2Nix {
    pname = "coc-tailwindcss";
    version = "2020-08-19";
    src = fetchurl {
      url = "https://github.com/iamcco/coc-tailwindcss/archive/5f41aa1feb36e39b95ccd83be6a37ee8c475f9fb.tar.gz";
      sha256 = "1i8a3pabywsamf78kj95480dsid25p0rx4w2b3jafb4pzak6jjdz";
    };
    meta = with lib; {
      description = "tailwindcss class name completion for (neo)vim";
      homepage = "https://github.com/iamcco/coc-tailwindcss";
      license = with licenses; [ mit ];
    };
  };
  fzf-lua = buildVimPluginFrom2Nix {
    pname = "fzf-lua";
    version = "2022-07-19";
    src = fetchurl {
      url = "https://github.com/ibhagwan/fzf-lua/archive/8dade5e9989eb4b99f3551384e090afa9da8b633.tar.gz";
      sha256 = "0spwhv3gmb8f9zni0by2mx623bp0fvli9l7h48bkd9xxlq43hcm7";
    };
    meta = with lib; {
      description = "Improved fzf.vim written in lua";
      homepage = "https://github.com/ibhagwan/fzf-lua";
      license = with licenses; [ agpl3Only ];
    };
  };
  vim-fish-inkch = buildVimPluginFrom2Nix {
    pname = "vim-fish-inkch";
    version = "2022-03-06";
    src = fetchurl {
      url = "https://github.com/inkch/vim-fish/archive/e648eaf250be676eef02b3e2c9e25eabfdb2ed75.tar.gz";
      sha256 = "0ysfc4mg8jh9i10k6jzaic9fhmwaqhlr600x7ikyps84fdajddhn";
    };
    meta = with lib; {
      description = "Vim support for editing fish scripts";
      homepage = "https://github.com/inkch/vim-fish";
      license = with licenses; [ mit ];
    };
  };
  fm-nvim = buildVimPluginFrom2Nix {
    pname = "fm-nvim";
    version = "2022-07-02";
    src = fetchurl {
      url = "https://github.com/is0n/fm-nvim/archive/e5df86a5d92dbe6887fc02487b2045ad1a8595c5.tar.gz";
      sha256 = "0li59kk7sqjh6jpdja996njlv5h0n2mf5iz175jks0812dfi0m8x";
    };
    meta = with lib; {
      description = "🗂 Neovim plugin that lets you use your favorite terminal file managers (and fuzzy finders) from within Neovim";
      homepage = "https://github.com/is0n/fm-nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  jaq-nvim = buildVimPluginFrom2Nix {
    pname = "jaq-nvim";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/is0n/jaq-nvim/archive/051842d30357100e397dc6e904f813841c8edcb7.tar.gz";
      sha256 = "19k8004c841h52b6y71m6xnh7d294a1zaagwyqjdrxl0x6kqvna1";
    };
    meta = with lib; {
      description = "⚙️ Just Another Quickrun Plugin for Neovim in Lua";
      homepage = "https://github.com/is0n/jaq-nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  modus-theme-vim = buildVimPluginFrom2Nix {
    pname = "modus-theme-vim";
    version = "2022-07-19";
    src = fetchurl {
      url = "https://github.com/ishan9299/modus-theme-vim/archive/841a8c3ca72b3ead86b5946ed9b6094e274d49b3.tar.gz";
      sha256 = "159fdv7z0axh5k66j5xdnkjcv8lhsk6x8vwgk8wfm7r7jxwf7rq2";
    };
    meta = with lib; {
      description = "Port of modus-themes in neovim";
      homepage = "https://github.com/ishan9299/modus-theme-vim";
      license = with licenses; [ mit ];
    };
  };
  nvim-solarized-lua = buildVimPluginFrom2Nix {
    pname = "nvim-solarized-lua";
    version = "2022-06-13";
    src = fetchurl {
      url = "https://github.com/ishan9299/nvim-solarized-lua/archive/faba49ba6b53759b89fc34d12ed7319f8c2e27e0.tar.gz";
      sha256 = "1njzcmqavbrjwgzcz3md55091bxwbjppr1rc9h28swc4mvsp5729";
    };
    meta = with lib; {
      description = "solarized colorscheme in lua for nvim 0.5";
      homepage = "https://github.com/ishan9299/nvim-solarized-lua";
      license = with licenses; [ mit ];
    };
  };
  fidget-nvim = buildVimPluginFrom2Nix {
    pname = "fidget-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/j-hui/fidget.nvim/archive/492492e7d50452a9ace8346d31f6d6da40439f0e.tar.gz";
      sha256 = "1z6287n46pncws643clqi2j3km8vfg091aiv3v2gh3dzn154zjwc";
    };
    meta = with lib; {
      description = "Standalone UI for nvim-lsp progress";
      homepage = "https://github.com/j-hui/fidget.nvim";
      license = with licenses; [ mit ];
    };
  };
  mkdnflow-nvim = buildVimPluginFrom2Nix {
    pname = "mkdnflow-nvim";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/jakewvincent/mkdnflow.nvim/archive/52ccc538d3ae4f64a8927e55b68dc25079ba5952.tar.gz";
      sha256 = "01f1xcaghlx3278rmyzvhmxdlv531a8lvyn0qlvdcgww53s88xn3";
    };
    meta = with lib; {
      description = "Tools for the fluent navigation and management of markdown notebooks";
      homepage = "https://github.com/jakewvincent/mkdnflow.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  texmagic-nvim = buildVimPluginFrom2Nix {
    pname = "texmagic-nvim";
    version = "2022-05-15";
    src = fetchurl {
      url = "https://github.com/jakewvincent/texmagic.nvim/archive/3c0d3b63c62486f02807663f5c5948e8b237b182.tar.gz";
      sha256 = "0kmvziz350vrpb25bcmaf1q0dac1hj3vrb5llf93rdvnr2rnwdz0";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/jakewvincent/texmagic.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-magic = buildVimPluginFrom2Nix {
    pname = "nvim-magic";
    version = "2022-02-03";
    src = fetchurl {
      url = "https://github.com/jameshiew/nvim-magic/archive/778ad035534278e5b3b5e31983af7d1e04f557a0.tar.gz";
      sha256 = "1y6w755dyp1nhha19ijkxcdap9rmnb7bsdvvi50xba1w2h2v9hnz";
    };
    meta = with lib; {
      description = ":genie: Pluggable framework for using AI code assistance in Neovim";
      homepage = "https://github.com/jameshiew/nvim-magic";
      license = with licenses; [ mit ];
    };
  };
  nvim-remote-containers = buildVimPluginFrom2Nix {
    pname = "nvim-remote-containers";
    version = "2022-03-07";
    src = fetchurl {
      url = "https://github.com/jamestthompson3/nvim-remote-containers/archive/d635bea9c24be1656c7e16e4b46ecb39b4b70093.tar.gz";
      sha256 = "11353wfdgy77cdwyawr0ndiydgiq36nnx6mwh5lpza61vi2hk4dn";
    };
    meta = with lib; {
      description = "Develop inside docker containers, just like VSCode";
      homepage = "https://github.com/jamestthompson3/nvim-remote-containers";
    };
  };
  carrot-nvim = buildVimPluginFrom2Nix {
    pname = "carrot-nvim";
    version = "2022-05-31";
    src = fetchurl {
      url = "https://github.com/jbyuki/carrot.nvim/archive/baf7a805acecf54ca6458340451d0e0f7d2df24b.tar.gz";
      sha256 = "0v71yhadaq9w4yqb7bzcya1pc9x1nwnifpqiz1r1wgkvl4y2b31l";
    };
    meta = with lib; {
      description = "Evaluate Neovim Lua inside Markdown";
      homepage = "https://github.com/jbyuki/carrot.nvim";
      license = with licenses; [ mit ];
    };
  };
  instant-nvim = buildVimPluginFrom2Nix {
    pname = "instant-nvim";
    version = "2022-06-25";
    src = fetchurl {
      url = "https://github.com/jbyuki/instant.nvim/archive/294b6d08143b3db8f9db7f606829270149e1a786.tar.gz";
      sha256 = "1zlzhvhlsy4m84m3z3xhvxz3ri54awf5df17wff5xgfp9430nfcz";
    };
    meta = with lib; {
      description = "collaborative editing in Neovim using built-in capabilities";
      homepage = "https://github.com/jbyuki/instant.nvim";
      license = with licenses; [ mit ];
    };
  };
  nabla-nvim = buildVimPluginFrom2Nix {
    pname = "nabla-nvim";
    version = "2022-04-30";
    src = fetchurl {
      url = "https://github.com/jbyuki/nabla.nvim/archive/8d499bd042f814d1b046d1625916bd7f7c88dd85.tar.gz";
      sha256 = "10khy6fvrgyx4njmvyw537jfa5pzc2ssbz1b17293x8n17yx0qgd";
    };
    meta = with lib; {
      description = "take your scientific notes :pencil2: in Neovim";
      homepage = "https://github.com/jbyuki/nabla.nvim";
      license = with licenses; [ mit ];
    };
  };
  one-small-step-for-vimkind = buildVimPluginFrom2Nix {
    pname = "one-small-step-for-vimkind";
    version = "2021-10-26";
    src = fetchurl {
      url = "https://github.com/jbyuki/one-small-step-for-vimkind/archive/59ec6f57545a42e68995994bfa57479da5e68b74.tar.gz";
      sha256 = "0h60d9y918w5qf5icrh6iqjvf26jk6pp7wcfxw335hmhk74q9yf3";
    };
    meta = with lib; {
      description = "Debug adapter for Neovim plugins";
      homepage = "https://github.com/jbyuki/one-small-step-for-vimkind";
      license = with licenses; [ mit ];
    };
  };
  venn-nvim = buildVimPluginFrom2Nix {
    pname = "venn-nvim";
    version = "2022-04-27";
    src = fetchurl {
      url = "https://github.com/jbyuki/venn.nvim/archive/71856b548e3206e33bad10acea294ca8b44327ee.tar.gz";
      sha256 = "0196ljdhxk3pj60rj2s0z2cbda9p9dgjczkynp9gvrqn4bkpqnq6";
    };
    meta = with lib; {
      description = "Draw ASCII diagrams in Neovim";
      homepage = "https://github.com/jbyuki/venn.nvim";
      license = with licenses; [ mit ];
    };
  };
  possession-nvim = buildVimPluginFrom2Nix {
    pname = "possession-nvim";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/jedrzejboczar/possession.nvim/archive/c138bbcd55d58d21ce12ceea8075dad29bea8c9f.tar.gz";
      sha256 = "04y8v88z143c6025cjr5fcnx76q9viqb1bzksngawvbnf6lwlsv8";
    };
    meta = with lib; {
      description = "Flexible session management for Neovim";
      homepage = "https://github.com/jedrzejboczar/possession.nvim";
      license = with licenses; [ mit ];
    };
  };
  toggletasks-nvim = buildVimPluginFrom2Nix {
    pname = "toggletasks-nvim";
    version = "2022-05-30";
    src = fetchurl {
      url = "https://github.com/jedrzejboczar/toggletasks.nvim/archive/4329ad580799f25c0a923a2d1e71a585ae0bbc48.tar.gz";
      sha256 = "1dywvvxc4gj6r9bgvgf98cg403ymlfgxkhxsyxf6bh1fbzqrffjq";
    };
    meta = with lib; {
      description = "Neovim task runner: JSON/YAML + toggleterm.nvim + telescope.nvim";
      homepage = "https://github.com/jedrzejboczar/toggletasks.nvim";
      license = with licenses; [ mit ];
    };
  };
  auto-pandoc-nvim = buildVimPluginFrom2Nix {
    pname = "auto-pandoc-nvim";
    version = "2022-03-12";
    src = fetchurl {
      url = "https://github.com/jghauser/auto-pandoc.nvim/archive/c64fcb360d55f753c1fd0bb5811968280cfbc1d9.tar.gz";
      sha256 = "0g9qw0giyjs9hz4r2klqxg4spw2s467x393hylnn0pjiq2mbrw0n";
    };
    meta = with lib; {
      description = "A neovim plugin leveraging pandoc to help you convert your markdown files. It takes pandoc options from yaml blocks";
      homepage = "https://github.com/jghauser/auto-pandoc.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  fold-cycle-nvim = buildVimPluginFrom2Nix {
    pname = "fold-cycle-nvim";
    version = "2022-07-19";
    src = fetchurl {
      url = "https://github.com/jghauser/fold-cycle.nvim/archive/07c58335aea48382d49e757c11ea92b78c0cab4b.tar.gz";
      sha256 = "00di9p3wl4bx0hl7f2c7c37qfg7yy4dnfs76lpb847l72fsnrwq8";
    };
    meta = with lib; {
      description = "This neovim plugin allows you to cycle folds open or closed";
      homepage = "https://github.com/jghauser/fold-cycle.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  follow-md-links-nvim = buildVimPluginFrom2Nix {
    pname = "follow-md-links-nvim";
    version = "2022-05-31";
    src = fetchurl {
      url = "https://github.com/jghauser/follow-md-links.nvim/archive/87ce2a2324106c3c5d9ed8f35eb6b948191f3060.tar.gz";
      sha256 = "1h4034by6qi7wr8wca0vnds521rad54m37gg9npdxmdz8qcni5vv";
    };
    meta = with lib; {
      description = "Easily follow markdown links with this neovim plugin";
      homepage = "https://github.com/jghauser/follow-md-links.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  kitty-runner-nvim = buildVimPluginFrom2Nix {
    pname = "kitty-runner-nvim";
    version = "2022-05-12";
    src = fetchurl {
      url = "https://github.com/jghauser/kitty-runner.nvim/archive/1cfe36cb3ce682344a8eabbb4d7e9a1b5e0bc02d.tar.gz";
      sha256 = "07z6j6a63k2db2zjz20mklpcgkpibsxagp3g5aymsg3yqx26r72m";
    };
    meta = with lib; {
      description = "A neovim plugin allowing you to easily send lines from the current buffer to another kitty terminal";
      homepage = "https://github.com/jghauser/kitty-runner.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  mkdir-nvim = buildVimPluginFrom2Nix {
    pname = "mkdir-nvim";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/jghauser/mkdir.nvim/archive/c55d1dee4f099528a1853b28bb28caa802eba217.tar.gz";
      sha256 = "09ykc0cp8hw4q1gjnh1dshbrr187gnl8j6vifkllw1xwwf88iki9";
    };
    meta = with lib; {
      description = "This neovim plugin creates missing folders on save";
      homepage = "https://github.com/jghauser/mkdir.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  ariake-vim-colors = buildVimPluginFrom2Nix {
    pname = "ariake-vim-colors";
    version = "2021-02-23";
    src = fetchurl {
      url = "https://github.com/jim-at-jibba/ariake-vim-colors/archive/9fb35f1255e475631c9df24ecc5485a40360cc7b.tar.gz";
      sha256 = "00q6mwdfav3z2hk3a80ppk4risdjfg77wdq8sbw78prdpl0xrb22";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/jim-at-jibba/ariake-vim-colors";
    };
  };
  nterm-nvim = buildVimPluginFrom2Nix {
    pname = "nterm-nvim";
    version = "2022-05-10";
    src = fetchurl {
      url = "https://github.com/jlesquembre/nterm.nvim/archive/cd7b7035d09144ee4ea49244bf5cb8ed68e499f8.tar.gz";
      sha256 = "1wfc0bly595ibylmcvcqsfb8gaxlp6na08yfsgdpfi4jw6ggs0rc";
    };
    meta = with lib; {
      description = "neovim plugin to interact with the terminal";
      homepage = "https://github.com/jlesquembre/nterm.nvim";
      license = with licenses; [ epl20 ];
    };
  };
  nvim-smartbufs = buildVimPluginFrom2Nix {
    pname = "nvim-smartbufs";
    version = "2021-06-14";
    src = fetchurl {
      url = "https://github.com/johann2357/nvim-smartbufs/archive/dddbfe258e41651554848d0e3421b35c1a0dcc37.tar.gz";
      sha256 = "0h6jjhwwk11j3iwrj7ycb5v7yrnzib04m14bvhkrb932f9gizr3n";
    };
    meta = with lib; {
      description = "Smart buffer management in neovim";
      homepage = "https://github.com/johann2357/nvim-smartbufs";
      license = with licenses; [ mit ];
    };
  };
  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/null-ls.nvim/archive/9c396ab880bec1097dc4d124c0961cdfa2aa3848.tar.gz";
      sha256 = "05fkmh45vgsnflcva027yb5bsav68gg4qjbg9vy5q7czb6s4sy38";
    };
    meta = with lib; {
      description = "Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua";
      homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
    };
  };
  nvim-lsp-ts-utils = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-ts-utils";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils/archive/0a6a16ef292c9b61eac6dad00d52666c7f84b0e7.tar.gz";
      sha256 = "0620igpp4dqhsxb6wizbmdd2ir38yi7n5hikcz2c9779b8dar305";
    };
    meta = with lib; {
      description = "Utilities to improve the TypeScript development experience for Neovim's built-in LSP client";
      homepage = "https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils";
      license = with licenses; [ unlicense ];
    };
  };
  mdeval-nvim = buildVimPluginFrom2Nix {
    pname = "mdeval-nvim";
    version = "2022-06-03";
    src = fetchurl {
      url = "https://github.com/jubnzv/mdeval.nvim/archive/b2beafe64dc84327604e5b5d86bb212b479fda07.tar.gz";
      sha256 = "1gf1z2cv030hhl9f45hiqx1fk8rd9k0v29c1k7km4q94y4hacxc0";
    };
    meta = with lib; {
      description = "Neovim plugin that evaluates code blocks inside documents";
      homepage = "https://github.com/jubnzv/mdeval.nvim";
      license = with licenses; [ mit ];
    };
  };
  virtual-types-nvim = buildVimPluginFrom2Nix {
    pname = "virtual-types-nvim";
    version = "2022-03-17";
    src = fetchurl {
      url = "https://github.com/jubnzv/virtual-types.nvim/archive/31da847fa54b801f309a08123935626adda4aaad.tar.gz";
      sha256 = "0a522w2vc67rqjlh2sbnl0lmh3a04kw8z3wv60xwm7sf5xrs6d9i";
    };
    meta = with lib; {
      description = "Neovim plugin that shows type annotations as virtual text";
      homepage = "https://github.com/jubnzv/virtual-types.nvim";
      license = with licenses; [ mit ];
    };
  };
  telescope-zoxide = buildVimPluginFrom2Nix {
    pname = "telescope-zoxide";
    version = "2022-07-04";
    src = fetchurl {
      url = "https://github.com/jvgrootveld/telescope-zoxide/archive/dbd9674e31e5caccae054a4ccee24ff8d1f2053f.tar.gz";
      sha256 = "0vms8y1jrvjrz1ixbjfxymhv4mwkx1wnb2z75mcvnxh82940wrgk";
    };
    meta = with lib; {
      description = "An extension for telescope.nvim that allows you operate zoxide within Neovim";
      homepage = "https://github.com/jvgrootveld/telescope-zoxide";
      license = with licenses; [ mit ];
    };
  };
  nvim-juliana = buildVimPluginFrom2Nix {
    pname = "nvim-juliana";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/kaiuri/nvim-juliana/archive/2ff244b699bd57cd61526828eae05d1b2f2f2b5b.tar.gz";
      sha256 = "1avwsqr1sq0zan18ypyn7m7s7cm8qacvd2wwlj6gznj74qnq0lxv";
    };
    meta = with lib; {
      description = "Port of Sublime's Mariana Theme to Neovim for short attention span devs";
      homepage = "https://github.com/kaiuri/nvim-juliana";
      license = with licenses; [ mit ];
    };
  };
  vim-textobj-indent = buildVimPluginFrom2Nix {
    pname = "vim-textobj-indent";
    version = "2013-01-18";
    src = fetchurl {
      url = "https://github.com/kana/vim-textobj-indent/archive/deb76867c302f933c8f21753806cbf2d8461b548.tar.gz";
      sha256 = "1ymm9xwf4xw0731kjn7skkprc5nvzwh880g738kqm7zam6mmnj65";
    };
    meta = with lib; {
      description = "Vim plugin: Text objects for indented blocks of lines";
      homepage = "https://github.com/kana/vim-textobj-indent";
    };
  };
  neoscroll-nvim = buildVimPluginFrom2Nix {
    pname = "neoscroll-nvim";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/karb94/neoscroll.nvim/archive/54c5c419f6ee2b35557b3a6a7d631724234ba97a.tar.gz";
      sha256 = "0g7403m1mxhgb6927fkjgkpc9k3qbh2xbiqd01cq6w2mgb0xn4sd";
    };
    meta = with lib; {
      description = "Smooth scrolling neovim plugin written in lua";
      homepage = "https://github.com/karb94/neoscroll.nvim";
      license = with licenses; [ mit ];
    };
  };
  close-buffers-nvim = buildVimPluginFrom2Nix {
    pname = "close-buffers-nvim";
    version = "2021-11-14";
    src = fetchurl {
      url = "https://github.com/kazhala/close-buffers.nvim/archive/3acbcad1211572342632a6c0151f839e7dead27f.tar.gz";
      sha256 = "19iwjbglyq4r99bhbj337qd251893g3x4qh6h2fsj8skqn9a3aaj";
    };
    meta = with lib; {
      description = ":bookmark_tabs: Delete multiple vim buffers based on different conditions";
      homepage = "https://github.com/kazhala/close-buffers.nvim";
      license = with licenses; [ mit ];
    };
  };
  lazygit-nvim = buildVimPluginFrom2Nix {
    pname = "lazygit-nvim";
    version = "2022-06-14";
    src = fetchurl {
      url = "https://github.com/kdheepak/lazygit.nvim/archive/9c73fd69a4c1cb3b3fc35b741ac968e331642600.tar.gz";
      sha256 = "19hvzr0h0gjz4zjh4mkmpszav88kd3d9g2qqwp81ax5717fnixmq";
    };
    meta = with lib; {
      description = "Plugin for calling lazygit from within neovim";
      homepage = "https://github.com/kdheepak/lazygit.nvim";
      license = with licenses; [ mit ];
    };
  };
  monochrome-nvim = buildVimPluginFrom2Nix {
    pname = "monochrome-nvim";
    version = "2021-07-14";
    src = fetchurl {
      url = "https://github.com/kdheepak/monochrome.nvim/archive/2de78d9688ea4a177bcd9be554ab9192337d35ff.tar.gz";
      sha256 = "115jkwnv4208vyrgxvjlrzdqqzm6fl7alzz60dnjnrsmn303nwfk";
    };
    meta = with lib; {
      description = "A monochrome colorscheme for neovim";
      homepage = "https://github.com/kdheepak/monochrome.nvim";
      license = with licenses; [ mit ];
    };
  };
  tabline-nvim = buildVimPluginFrom2Nix {
    pname = "tabline-nvim";
    version = "2022-06-13";
    src = fetchurl {
      url = "https://github.com/kdheepak/tabline.nvim/archive/5d76dc8616b4b7b892229cc05cd0f4cd0200077a.tar.gz";
      sha256 = "0bpdkyb8xai1130wvq1v4pnr0iyqslcr72ha6nxw5rzmwm2xhsdl";
    };
    meta = with lib; {
      description = "A \"buffer and tab\" tabline for neovim";
      homepage = "https://github.com/kdheepak/tabline.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-bqf = buildVimPluginFrom2Nix {
    pname = "nvim-bqf";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/kevinhwang91/nvim-bqf/archive/8b62211ad7529c314e80b22968eef6ba275c781c.tar.gz";
      sha256 = "00i684llxiijxpxb6q4s8bwp9n25wxz64qzjanxsm4vbymlhcdni";
    };
    meta = with lib; {
      description = "Better quickfix window in Neovim, polish old quickfix window";
      homepage = "https://github.com/kevinhwang91/nvim-bqf";
      license = with licenses; [ bsd3 ];
    };
  };
  nvim-hlslens = buildVimPluginFrom2Nix {
    pname = "nvim-hlslens";
    version = "2022-07-07";
    src = fetchurl {
      url = "https://github.com/kevinhwang91/nvim-hlslens/archive/75b20ce89908bc56eeab5c7b4d0a77e9e054d2e4.tar.gz";
      sha256 = "0y9gi2zr5il5qimlcinpmvl06bc7lj0cksqlydly22acfcpg11yv";
    };
    meta = with lib; {
      description = "Hlsearch Lens for Neovim";
      homepage = "https://github.com/kevinhwang91/nvim-hlslens";
      license = with licenses; [ bsd3 ];
    };
  };
  nvim-ufo = buildVimPluginFrom2Nix {
    pname = "nvim-ufo";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/kevinhwang91/nvim-ufo/archive/3cf2f3cfd53ac4f1db4559e178b63b77506036d9.tar.gz";
      sha256 = "1c5c5bbvwm0h56a9jmqzwp5ax1pi09i49m66d4yjvv3wdrs8crsi";
    };
    meta = with lib; {
      description = "Not UFO in the sky, but an ultra fold in Neovim";
      homepage = "https://github.com/kevinhwang91/nvim-ufo";
      license = with licenses; [ bsd3 ];
    };
  };
  rnvimr = buildVimPluginFrom2Nix {
    pname = "rnvimr";
    version = "2022-05-19";
    src = fetchurl {
      url = "https://github.com/kevinhwang91/rnvimr/archive/5877509cfdbf3a0382ff24198a3f730b476f8262.tar.gz";
      sha256 = "1ci03r42yghmwqp30b81gv2d0dd8p21v1fp5vpmvsgbf5726c4aq";
    };
    meta = with lib; {
      description = "Make Ranger running in a floating window to communicate with Neovim via RPC";
      homepage = "https://github.com/kevinhwang91/rnvimr";
      license = with licenses; [ bsd3 ];
    };
  };
  lspsaga-nvim = buildVimPluginFrom2Nix {
    pname = "lspsaga-nvim";
    version = "2022-07-05";
    src = fetchurl {
      url = "https://github.com/kkharji/lspsaga.nvim/archive/ea39528f8eab7af4bcd8b0f88abfad86e3ea2995.tar.gz";
      sha256 = "0liqv0pwbwv8kgk1z26hrzh5i8cb645v12kwhdqrj6678rm3zch5";
    };
    meta = with lib; {
      description = "The neovim language-server-client UI";
      homepage = "https://github.com/kkharji/lspsaga.nvim";
      license = with licenses; [ mit ];
    };
  };
  sqlite-lua = buildVimPluginFrom2Nix {
    pname = "sqlite-lua";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/kkharji/sqlite.lua/archive/56c5aacd5e31496d9b3cd3d1b0e570bb9a65d35b.tar.gz";
      sha256 = "0c9jv72rl4vb7hh9hd2rw80jfrmhaj2jifgl7jvpmdqlyv01ldk2";
    };
    meta = with lib; {
      description = "SQLite/LuaJIT binding for lua and neovim";
      homepage = "https://github.com/kkharji/sqlite.lua";
      license = with licenses; [ mit ];
    };
  };
  nvim-config-local = buildVimPluginFrom2Nix {
    pname = "nvim-config-local";
    version = "2022-03-26";
    src = fetchurl {
      url = "https://github.com/klen/nvim-config-local/archive/af59d6344e555917209f7304709bbff7cea9b5cc.tar.gz";
      sha256 = "071wz8lhcvsv8qmms0pb3bz0w7h9gilqn1635qi5d3hay4wh62yc";
    };
    meta = with lib; {
      description = "Secure load local config files for neovim";
      homepage = "https://github.com/klen/nvim-config-local";
      license = with licenses; [ mit ];
    };
  };
  nvim-test = buildVimPluginFrom2Nix {
    pname = "nvim-test";
    version = "2022-06-05";
    src = fetchurl {
      url = "https://github.com/klen/nvim-test/archive/32f162c27045fc712664b9ddbd33d3c550cb2bfc.tar.gz";
      sha256 = "03lg4z04ncv0nnqx2za97yjm0nbzcmqrykj970afnjjzlvsms5lk";
    };
    meta = with lib; {
      description = "A Neovim wrapper for running tests";
      homepage = "https://github.com/klen/nvim-test";
      license = with licenses; [ mit ];
    };
  };
  kmonad-vim = buildVimPluginFrom2Nix {
    pname = "kmonad-vim";
    version = "2022-03-20";
    src = fetchurl {
      url = "https://github.com/kmonad/kmonad-vim/archive/37978445197ab00edeb5b731e9ca90c2b141723f.tar.gz";
      sha256 = "0q4z72angj2kr6mfxh6bqi76xhy8qpkwkr4vk2c6xf0n3vvihbjh";
    };
    meta = with lib; {
      description = "Vim editing support for kmonad config files";
      homepage = "https://github.com/kmonad/kmonad-vim";
      license = with licenses; [ gpl3Only ];
    };
  };
  peepsight-nvim = buildVimPluginFrom2Nix {
    pname = "peepsight-nvim";
    version = "2022-06-07";
    src = fetchurl {
      url = "https://github.com/koenverburg/peepsight.nvim/archive/8d662c53951ce31161be700f9f120f7f5134320a.tar.gz";
      sha256 = "11xpjk80pcxns24i41lpz95a31vf3vqmvfl9hm9hz2d8s09qhw0v";
    };
    meta = with lib; {
      description = "Focus on one function at a time";
      homepage = "https://github.com/koenverburg/peepsight.nvim";
    };
  };
  vacuumline-nvim = buildVimPluginFrom2Nix {
    pname = "vacuumline-nvim";
    version = "2022-03-13";
    src = fetchurl {
      url = "https://github.com/konapun/vacuumline.nvim/archive/5f207f81d399004085df64fec4aeb5136422beba.tar.gz";
      sha256 = "1srq6607gxqxwg3glcb7h95b0d02qx96zkmfa1k4c81m05rj64d8";
    };
    meta = with lib; {
      description = "A prebuilt configuration for galaxyline inspired by airline";
      homepage = "https://github.com/konapun/vacuumline.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-lightbulb = buildVimPluginFrom2Nix {
    pname = "nvim-lightbulb";
    version = "2022-06-08";
    src = fetchurl {
      url = "https://github.com/kosayoda/nvim-lightbulb/archive/1e2844b68a07d3e7ad9e6cc9a2aebc347488ec1b.tar.gz";
      sha256 = "0nn44kq13mxfzwvv44hgdk1fb3wga92ah2xgg5sk02xhw0705276";
    };
    meta = with lib; {
      description = "VSCode 💡 for neovim's built-in LSP";
      homepage = "https://github.com/kosayoda/nvim-lightbulb";
      license = with licenses; [ mit ];
    };
  };
  rasmus-nvim = buildVimPluginFrom2Nix {
    pname = "rasmus-nvim";
    version = "2022-06-21";
    src = fetchurl {
      url = "https://github.com/kvrohit/rasmus.nvim/archive/d1ac6152b3fb4e8a1be372d344fc753e5fbb88ba.tar.gz";
      sha256 = "1i950l5ng66f46in6ffvmvr1vask7vnshc4znr9dkyvyn04rrpql";
    };
    meta = with lib; {
      description = "A color scheme for Neovim";
      homepage = "https://github.com/kvrohit/rasmus.nvim";
    };
  };
  substrata-nvim = buildVimPluginFrom2Nix {
    pname = "substrata-nvim";
    version = "2022-06-21";
    src = fetchurl {
      url = "https://github.com/kvrohit/substrata.nvim/archive/aea8143ceab98ffcb02934773cc3b4249425f76c.tar.gz";
      sha256 = "06mr5wbnsz1wm4g5w9z1qcghbx6ksszgzxa1wdh8xky5mvqk5r0f";
    };
    meta = with lib; {
      description = " A cold, dark color scheme for Neovim";
      homepage = "https://github.com/kvrohit/substrata.nvim";
    };
  };
  blue-moon = buildVimPluginFrom2Nix {
    pname = "blue-moon";
    version = "2022-07-18";
    src = fetchurl {
      url = "https://github.com/kyazdani42/blue-moon/archive/02263fe9831211046a66112c290eb452d7815b86.tar.gz";
      sha256 = "0kld4h7wpqqc3qq9q92cm5m1vwfqfxg5jb2khv2g8b908fjmya8b";
    };
    meta = with lib; {
      description = "A dark color scheme for Neovim derived from palenight and carbonight";
      homepage = "https://github.com/kyazdani42/blue-moon";
    };
  };
  nvim-tree-lua = buildVimPluginFrom2Nix {
    pname = "nvim-tree-lua";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/kyazdani42/nvim-tree.lua/archive/64cc3c17e1a8d00d0fafcb61349b2a7d57234e53.tar.gz";
      sha256 = "19fyqjzf2crcglabw7k95r6sfcqqfp9n1bk1hgfmyrn50f8d9n3p";
    };
    meta = with lib; {
      description = "A file explorer tree for neovim written in lua";
      homepage = "https://github.com/kyazdani42/nvim-tree.lua";
    };
  };
  nvim-web-devicons = buildVimPluginFrom2Nix {
    pname = "nvim-web-devicons";
    version = "2022-07-05";
    src = fetchurl {
      url = "https://github.com/kyazdani42/nvim-web-devicons/archive/2d02a56189e2bde11edd4712fea16f08a6656944.tar.gz";
      sha256 = "18i0fhlxg2racnhclrqc6mhg40lxjbcln3sq5lzwlzzl7rd8qakd";
    };
    meta = with lib; {
      description = "lua `fork` of vim-web-devicons for neovim";
      homepage = "https://github.com/kyazdani42/nvim-web-devicons";
    };
  };
  nvim-surround = buildVimPluginFrom2Nix {
    pname = "nvim-surround";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/kylechui/nvim-surround/archive/306a92830ede75d7d3a48ba04c7e603b73c3f377.tar.gz";
      sha256 = "1m1f0cpcrywyax2fk5mba8yn186njp3mjkq1kky6l5yy5vwhxv38";
    };
    meta = with lib; {
      description = "Add/change/delete surrounding delimiter pairs with ease. Written with :heart: in Lua";
      homepage = "https://github.com/kylechui/nvim-surround";
      license = with licenses; [ mit ];
    };
  };
  cobalt2-nvim = buildVimPluginFrom2Nix {
    pname = "cobalt2-nvim";
    version = "2022-07-24";
    src = fetchurl {
      url = "https://github.com/lalitmee/cobalt2.nvim/archive/44063cb536dcd44f4db392c9b52adbc8af7c7539.tar.gz";
      sha256 = "01l5zm7ysjn7h7z25jqv6phyrpp70rxa94qsih4zaqxjzszyyxh2";
    };
    meta = with lib; {
      description = "cobalt2 theme for neovim in Lua using colorbuddy";
      homepage = "https://github.com/lalitmee/cobalt2.nvim";
      license = with licenses; [ mit ];
    };
  };
  gh-nvim = buildVimPluginFrom2Nix {
    pname = "gh-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/ldelossa/gh.nvim/archive/bafa232e0df29c88ea017ed13c076ac1d16bfa73.tar.gz";
      sha256 = "1x3iafq3kijfc987f4jgm7bm3pc54vwdg2shrlrnqlqwpizwv596";
    };
    meta = with lib; {
      description = "A fully featured GitHub integration for performing code reviews in Neovim";
      homepage = "https://github.com/ldelossa/gh.nvim";
    };
  };
  vimdark = buildVimPluginFrom2Nix {
    pname = "vimdark";
    version = "2022-03-20";
    src = fetchurl {
      url = "https://github.com/ldelossa/vimdark/archive/ffd7240f8346cb61ab80eda84b78f8983a3c69bf.tar.gz";
      sha256 = "0jz1w3gw64sj6pw6l3ahdwg97f7bagnyib4c8k5fbfx860q899rp";
    };
    meta = with lib; {
      description = "A dark theme for vim based on vim-monotonic and chrome's dark reader";
      homepage = "https://github.com/ldelossa/vimdark";
      license = with licenses; [ mit ];
    };
  };
  vim-svelte-plugin = buildVimPluginFrom2Nix {
    pname = "vim-svelte-plugin";
    version = "2022-04-22";
    src = fetchurl {
      url = "https://github.com/leafOfTree/vim-svelte-plugin/archive/81fdbd57f5e60c2654249c1bbc3072720eeaa27f.tar.gz";
      sha256 = "0352ba1m5nj50iqwi2959fa0i6sjaxlyq3gdffbwpk375ydlmnh1";
    };
    meta = with lib; {
      description = "Vim syntax and indent plugin for .svelte files";
      homepage = "https://github.com/leafOfTree/vim-svelte-plugin";
      license = with licenses; [ unlicense ];
    };
  };
  gitsigns-nvim = buildVimPluginFrom2Nix {
    pname = "gitsigns-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/lewis6991/gitsigns.nvim/archive/8b817e76b6399634f3f49e682d6e409844241858.tar.gz";
      sha256 = "1cxrnc5csi2kg8jpbgwag0gcc4kgk1aqx5sypldxj3hmq25dkbz0";
    };
    meta = with lib; {
      description = "Git integration for buffers";
      homepage = "https://github.com/lewis6991/gitsigns.nvim";
      license = with licenses; [ mit ];
    };
  };
  spellsitter-nvim = buildVimPluginFrom2Nix {
    pname = "spellsitter-nvim";
    version = "2022-07-09";
    src = fetchurl {
      url = "https://github.com/lewis6991/spellsitter.nvim/archive/eb74c4b1f4240cf1a7860877423195cec6311bd5.tar.gz";
      sha256 = "02l52jfiz8wklxlf346lqzcxp7bk754l821izkc53dv7zwzpp21m";
    };
    meta = with lib; {
      description = "Treesitter powered spellchecker";
      homepage = "https://github.com/lewis6991/spellsitter.nvim";
      license = with licenses; [ mit ];
    };
  };
  sherbet-nvim = buildVimPluginFrom2Nix {
    pname = "sherbet-nvim";
    version = "2022-07-24";
    src = fetchurl {
      url = "https://github.com/lewpoly/sherbet.nvim/archive/f974a1cdda53e63f22b1ff5272f1e450aeaf6de3.tar.gz";
      sha256 = "1mmj0nm0llhqbr6g7sra6zw8r9s72snwxa6zj790knssapcmq8d4";
    };
    meta = with lib; {
      description = "Neovim colorscheme written in Lua";
      homepage = "https://github.com/lewpoly/sherbet.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  key-menu-nvim = buildVimPluginFrom2Nix {
    pname = "key-menu-nvim";
    version = "2022-06-15";
    src = fetchurl {
      url = "https://github.com/linty-org/key-menu.nvim/archive/6fcb95126c882d285f32d6f34f0e61d82fd516c1.tar.gz";
      sha256 = "0hyrgk82zp9sbpz8dppw4wa0m3i0wdizdkjwamkf7fsf118624ac";
    };
    meta = with lib; {
      description = "Key mapping hints in a floating window";
      homepage = "https://github.com/linty-org/key-menu.nvim";
    };
  };
  readline-nvim = buildVimPluginFrom2Nix {
    pname = "readline-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/linty-org/readline.nvim/archive/bc50b41d7f945fba85408168b178018da0effa71.tar.gz";
      sha256 = "0s9n89zdi7ym3y51s946xn3skf19dhg21gq9h96and4pv49fzwys";
    };
    meta = with lib; {
      description = "Readline motions and deletions in Neovim";
      homepage = "https://github.com/linty-org/readline.nvim";
    };
  };
  kimbox = buildVimPluginFrom2Nix {
    pname = "kimbox";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/lmburns/kimbox/archive/a3daaa81b7a6410f83e24f575bae545553741e0f.tar.gz";
      sha256 = "1piwh030sgp8ccaafixi4cwxirgahk86gfsaax67xskcmnsf6hgf";
    };
    meta = with lib; {
      description = "Kimbie Dark Neovim colorscheme";
      homepage = "https://github.com/lmburns/kimbox";
    };
  };
  github-colors = buildVimPluginFrom2Nix {
    pname = "github-colors";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/lourenci/github-colors/archive/d817e6f5e536315876c7d338f9d7bf51a1a12e9d.tar.gz";
      sha256 = "0q933blbjhsg1si25rx67zzbw5mg1f0zmayj3pc5fn4cd5qqbbym";
    };
    meta = with lib; {
      description = "Yet another GitHub colorscheme";
      homepage = "https://github.com/lourenci/github-colors";
      license = with licenses; [ mit ];
    };
  };
  gruvbox-baby = buildVimPluginFrom2Nix {
    pname = "gruvbox-baby";
    version = "2022-07-18";
    src = fetchurl {
      url = "https://github.com/luisiacc/gruvbox-baby/archive/4334547b6e98c77d065d2b0e801523a8f84792d9.tar.gz";
      sha256 = "169iw5mijccykc486bc6gnilyahx84jc43r6yv3fx3llsfqc89x7";
    };
    meta = with lib; {
      description = "Gruvbox theme for neovim with full 🎄TreeSitter support. ";
      homepage = "https://github.com/luisiacc/gruvbox-baby";
      license = with licenses; [ mit ];
    };
  };
  cmp-rg = buildVimPluginFrom2Nix {
    pname = "cmp-rg";
    version = "2022-01-13";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/cmp-rg/archive/fd92d70ff36b30924401b0cf7d4ce7344c8235f7.tar.gz";
      sha256 = "0xwn0x6wh33ryzivrl1g8kwy7w7p0q9cim6as9sbcnfav5sv5ddn";
    };
    meta = with lib; {
      description = "ripgrep source for nvim-cmp";
      homepage = "https://github.com/lukas-reineke/cmp-rg";
      license = with licenses; [ mit ];
    };
  };
  cmp-under-comparator = buildVimPluginFrom2Nix {
    pname = "cmp-under-comparator";
    version = "2021-11-11";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/cmp-under-comparator/archive/6857f10272c3cfe930cece2afa2406e1385bfef8.tar.gz";
      sha256 = "0qnf0ph6babwrmmdmymr4yxlsvhf2izygm3n2743w7ikqjf4k48h";
    };
    meta = with lib; {
      description = "nvim-cmp comparator function for completion items that start with one or more underlines";
      homepage = "https://github.com/lukas-reineke/cmp-under-comparator";
      license = with licenses; [ mit ];
    };
  };
  indent-blankline-nvim = buildVimPluginFrom2Nix {
    pname = "indent-blankline-nvim";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/indent-blankline.nvim/archive/4a58fe6e9854ccfe6c6b0f59abb7cb8301e23025.tar.gz";
      sha256 = "0k4z8gzh1a1fy8fyn6bws1zmq7vmymx118mjfx2fvf1ypvkgr5i3";
    };
    meta = with lib; {
      description = "Indent guides  for Neovim";
      homepage = "https://github.com/lukas-reineke/indent-blankline.nvim";
      license = with licenses; [ mit ];
    };
  };
  lsp-format-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-format-nvim";
    version = "2022-05-21";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/lsp-format.nvim/archive/a5a54eeb36d7001b4a6f0874dde6afd167319ac9.tar.gz";
      sha256 = "1c4c0ccn023aa95c726rxs1has4yvnnd2q43z1z8q87amk5cahrq";
    };
    meta = with lib; {
      description = "A wrapper around Neovims native LSP formatting";
      homepage = "https://github.com/lukas-reineke/lsp-format.nvim";
    };
  };
  nnn-nvim = buildVimPluginFrom2Nix {
    pname = "nnn-nvim";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/luukvbaal/nnn.nvim/archive/668d0dab6af17a3f0f054701385e8ea69916f438.tar.gz";
      sha256 = "1342jw93731gmp7waw13lbf7490dvv70fbbjgnnynn2c3jnvxhqd";
    };
    meta = with lib; {
      description = "File manager for Neovim powered by nnn";
      homepage = "https://github.com/luukvbaal/nnn.nvim";
      license = with licenses; [ bsd3 ];
    };
  };
  stabilize-nvim = buildVimPluginFrom2Nix {
    pname = "stabilize-nvim";
    version = "2022-07-09";
    src = fetchurl {
      url = "https://github.com/luukvbaal/stabilize.nvim/archive/f7c4d93d6822df1770a90b7fdb46f6df5c94052e.tar.gz";
      sha256 = "1lbh5afv0zn0ggg0wg7x97hbny6vh03mc3iy4anw819f3wwlnjxk";
    };
    meta = with lib; {
      description = "Neovim plugin to stabilize window open/close events";
      homepage = "https://github.com/luukvbaal/stabilize.nvim";
      license = with licenses; [ bsd2 ];
    };
  };
  attempt-nvim = buildVimPluginFrom2Nix {
    pname = "attempt-nvim";
    version = "2022-06-11";
    src = fetchurl {
      url = "https://github.com/m-demare/attempt.nvim/archive/0b3628aa348061f4da17e090bbd34b55a46eea2f.tar.gz";
      sha256 = "0nz5z724n36nicwn5z0cds6hk7c7jbm3vy63yck2wfrx9r06y9bw";
    };
    meta = with lib; {
      description = "Manage temporary buffers";
      homepage = "https://github.com/m-demare/attempt.nvim";
      license = with licenses; [ mit ];
    };
  };
  hlargs-nvim = buildVimPluginFrom2Nix {
    pname = "hlargs-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/m-demare/hlargs.nvim/archive/9d2bee73dc60811b6bb5509dfeedeaf9be45e92f.tar.gz";
      sha256 = "1c2jqn2zjh7g52al37ima9pxrlslibhq1mijbrdmqk9a1lny6xx5";
    };
    meta = with lib; {
      description = "Highlight arguments' definitions and usages, using Treesitter";
      homepage = "https://github.com/m-demare/hlargs.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  baleia-nvim = buildVimPluginFrom2Nix {
    pname = "baleia-nvim";
    version = "2022-05-17";
    src = fetchurl {
      url = "https://github.com/m00qek/baleia.nvim/archive/af6a17b21336599df8f17a8c1186b414330b8b44.tar.gz";
      sha256 = "14iv3axi67jvf4vjxrsbgrzan6xhqfcbywyrg7329apsynml56bd";
    };
    meta = with lib; {
      description = "Integration  Colorize text with ANSI escape sequences (8, 16, 256 or TrueColor)";
      homepage = "https://github.com/m00qek/baleia.nvim";
    };
  };
  plugin-template-nvim = buildVimPluginFrom2Nix {
    pname = "plugin-template-nvim";
    version = "2022-06-10";
    src = fetchurl {
      url = "https://github.com/m00qek/plugin-template.nvim/archive/b988d049ac9484acd5feb32bff883a14e1e5e52b.tar.gz";
      sha256 = "1mzijw3jfrkxzffqilqb0axp66dgw7d491rjy3cb3j75ass7pwfw";
    };
    meta = with lib; {
      description = "A template to create Neovim plugins written in Lua";
      homepage = "https://github.com/m00qek/plugin-template.nvim";
    };
  };
  reaper-nvim = buildVimPluginFrom2Nix {
    pname = "reaper-nvim";
    version = "2021-01-29";
    src = fetchurl {
      url = "https://github.com/madskjeldgaard/reaper-nvim/archive/dc30b618bb0e2c47b7e0dce781527627291b3365.tar.gz";
      sha256 = "06c0mcfki8yqkd30airpqq62wc26zkmb87qacwca4l2aycvxl42v";
    };
    meta = with lib; {
      description = "Reaper plugin for neovim. Remote control your daw with almost 4000 actions without leaving your favourite text editor";
      homepage = "https://github.com/madskjeldgaard/reaper-nvim";
    };
  };
  material-nvim = buildVimPluginFrom2Nix {
    pname = "material-nvim";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/marko-cerovac/material.nvim/archive/94414171611bed8603a35f78f75cd543e591c178.tar.gz";
      sha256 = "0lkf26iq79cgnd6hnm08kgagajha3lv2knjv49s0xl3avl92ljfw";
    };
    meta = with lib; {
      description = ":trident: Material colorscheme for NeoVim written in Lua with built-in support for native LSP, TreeSitter and many more plugins";
      homepage = "https://github.com/marko-cerovac/material.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  JABS-nvim = buildVimPluginFrom2Nix {
    pname = "JABS-nvim";
    version = "2022-07-06";
    src = fetchurl {
      url = "https://github.com/matbme/JABS.nvim/archive/840dcf3a1b2a028d27367132d51634f82e57a855.tar.gz";
      sha256 = "1sfh02z42adij1ggdvkd8hvh2cifswnjg4z350ma9zza8p5wvbap";
    };
    meta = with lib; {
      description = "Just Another Buffer Switcher for Neovim";
      homepage = "https://github.com/matbme/JABS.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  autoclose-nvim = buildVimPluginFrom2Nix {
    pname = "autoclose-nvim";
    version = "2022-05-03";
    src = fetchurl {
      url = "https://github.com/max-0406/autoclose.nvim/archive/a44dbc13c5f8ed87d88132284aa3136f51fc714c.tar.gz";
      sha256 = "1lc3qcz7p0q92a037fsmv1g8bpb1951q6jmc57il6v62rfkxrkxg";
    };
    meta = with lib; {
      description = "A minimalist autoclose plugin for neovim written by Lua";
      homepage = "https://github.com/max-0406/autoclose.nvim";
      license = with licenses; [ mit ];
    };
  };
  better-escape-nvim = buildVimPluginFrom2Nix {
    pname = "better-escape-nvim";
    version = "2022-03-28";
    src = fetchurl {
      url = "https://github.com/max397574/better-escape.nvim/archive/d5ee0cef56a7e41a86048c14f25e964876ac20c1.tar.gz";
      sha256 = "16nblb5qmwlvzkfdcal3myhda0cnn10irmqqk01lii3pql16ysn3";
    };
    meta = with lib; {
      description = "Escape from insert mode without delay when typing";
      homepage = "https://github.com/max397574/better-escape.nvim";
    };
  };
  tidy-nvim = buildVimPluginFrom2Nix {
    pname = "tidy-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/mcauley-penney/tidy.nvim/archive/4dcb51102eefa3485957add8d8c8cfa4953718d1.tar.gz";
      sha256 = "1nnq0c9zwkglf8ynjic09115chinn7jzaxjk6hxfam9xk8061yjh";
    };
    meta = with lib; {
      description = "A small Neovim plugin to remove trailing whitespace and empty lines at end of file on every save";
      homepage = "https://github.com/mcauley-penney/tidy.nvim";
    };
  };
  zenbones-nvim = buildVimPluginFrom2Nix {
    pname = "zenbones-nvim";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/mcchrish/zenbones.nvim/archive/000a1ef90d3b31217d309c029b145b20c0ac2b25.tar.gz";
      sha256 = "1by4jc98m51q7nab3y73yjsk9gqmn385l6hw1bwzax4d88zspw1p";
    };
    meta = with lib; {
      description = "🪨 A collection of contrast-based Vim/Neovim colorschemes";
      homepage = "https://github.com/mcchrish/zenbones.nvim";
      license = with licenses; [ mit ];
    };
  };
  neovim = buildVimPluginFrom2Nix {
    pname = "neovim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/meliora-theme/neovim/archive/b253d01f10c60d008709a08a90c74034c7672f93.tar.gz";
      sha256 = "1jxyhix8iamr7x70gd7cff9pb3dq7h5wzxqcl6ii147274j5simw";
    };
    meta = with lib; {
      description = "Warm and cozy theme for Neovim";
      homepage = "https://github.com/meliora-theme/neovim";
      license = with licenses; [ mit ];
    };
  };
  jellybeans-nvim = buildVimPluginFrom2Nix {
    pname = "jellybeans-nvim";
    version = "2022-03-21";
    src = fetchurl {
      url = "https://github.com/metalelf0/jellybeans-nvim/archive/f77b75443adf6461ded30de0243f49771f933d06.tar.gz";
      sha256 = "0x4v8db1irf7yg4yma960najbcl9b8aqvnvyfs3n5186dwnm3rz7";
    };
    meta = with lib; {
      description = "A port of jellybeans colorscheme for neovim";
      homepage = "https://github.com/metalelf0/jellybeans-nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-dap = buildVimPluginFrom2Nix {
    pname = "nvim-dap";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/mfussenegger/nvim-dap/archive/b3998a9a1848330ca467c3c88ee96f6b3fc48812.tar.gz";
      sha256 = "14cb0lp9fh9wm48l3q6w24cqfkq7w8h6lnskzzy1g1xdzk5nfmxb";
    };
    meta = with lib; {
      description = "Debug Adapter Protocol client implementation for Neovim";
      homepage = "https://github.com/mfussenegger/nvim-dap";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-lint = buildVimPluginFrom2Nix {
    pname = "nvim-lint";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/mfussenegger/nvim-lint/archive/4d0abb94776f860ed0eef7c2d7aae96a804cbee5.tar.gz";
      sha256 = "0fb0l47vx8c6kr12lk7vrkqxsvk3lzmmifv9psbm7qjadfllcnzs";
    };
    meta = with lib; {
      description = "An asynchronous linter plugin for Neovim complementary to the built-in Language Server Protocol support";
      homepage = "https://github.com/mfussenegger/nvim-lint";
    };
  };
  nvim-treehopper = buildVimPluginFrom2Nix {
    pname = "nvim-treehopper";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/mfussenegger/nvim-treehopper/archive/231ad18b9b8591a35d0f4161ab922ff28aea6645.tar.gz";
      sha256 = "1rsicyhaxa21s7wwk06hk3kyzs2294p07sd9vd0i8zshg6m16m5k";
    };
    meta = with lib; {
      description = "Region selection with hints on the AST nodes of a document powered by treesitter";
      homepage = "https://github.com/mfussenegger/nvim-treehopper";
      license = with licenses; [ gpl3Only ];
    };
  };
  formatter-nvim = buildVimPluginFrom2Nix {
    pname = "formatter-nvim";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/mhartington/formatter.nvim/archive/27ea7a8cf689e0b5dd742bada416c00f64450360.tar.gz";
      sha256 = "1w4csmad91f792gmkmzqflxsqmr20bx362mc8cdyn05nmxmc049r";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/mhartington/formatter.nvim";
      license = with licenses; [ mit ];
    };
  };
  oceanic-next = buildVimPluginFrom2Nix {
    pname = "oceanic-next";
    version = "2021-02-05";
    src = fetchurl {
      url = "https://github.com/mhartington/oceanic-next/archive/5ef31a34204f84714885ae9036f66a626036c3dc.tar.gz";
      sha256 = "04shp4czh86gmjznq4qvhgr6ikpdnsahx2py61i0ryp888hab4ik";
    };
    meta = with lib; {
      description = "Oceanic Next theme for neovim";
      homepage = "https://github.com/mhartington/oceanic-next";
    };
  };
  sniprun = buildVimPluginFrom2Nix {
    pname = "sniprun";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/michaelb/sniprun/archive/589f307aaf6d3b7c7fbec50176c00f679a3d5b6d.tar.gz";
      sha256 = "07k0hxh85qz7pkfia291ac4vg9ad16z1zc7dypxvxzm1vzdwf4h1";
    };
    meta = with lib; {
      description = "A neovim plugin to run lines/blocs of code (independently of the rest of the file), supporting multiples languages";
      homepage = "https://github.com/michaelb/sniprun";
      license = with licenses; [ mit ];
    };
  };
  zk-nvim = buildVimPluginFrom2Nix {
    pname = "zk-nvim";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/mickael-menu/zk-nvim/archive/73affbc95fba3655704e4993a8929675bc9942a1.tar.gz";
      sha256 = "13prsrqpalrx43q010l49206clf2xmbkmq66lgk7gvrb511ik0sf";
    };
    meta = with lib; {
      description = "Neovim extension for zk";
      homepage = "https://github.com/mickael-menu/zk-nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-luaref = buildVimPluginFrom2Nix {
    pname = "nvim-luaref";
    version = "2022-02-17";
    src = fetchurl {
      url = "https://github.com/milisims/nvim-luaref/archive/9cd3ed50d5752ffd56d88dd9e395ddd3dc2c7127.tar.gz";
      sha256 = "02x1z1swcpbzyzsam7s1xlb9b0iyy49qk9wrnl47c21wbhdrhlfx";
    };
    meta = with lib; {
      description = "Add a vim :help reference for lua ";
      homepage = "https://github.com/milisims/nvim-luaref";
      license = with licenses; [ mit ];
    };
  };
  iswap-nvim = buildVimPluginFrom2Nix {
    pname = "iswap-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/mizlan/iswap.nvim/archive/61824661c84e9b2ad6765338088d52a28a032aab.tar.gz";
      sha256 = "1z3412n9wqwhjabixac2idwzdyrx1cvdhv2bfaikslqf6v3dsnim";
    };
    meta = with lib; {
      description = "Interactively select and swap function arguments, list elements, and more. Powered by tree-sitter";
      homepage = "https://github.com/mizlan/iswap.nvim";
      license = with licenses; [ mit ];
    };
  };
  iron-nvim-mnacamura = buildVimPluginFrom2Nix {
    pname = "iron-nvim-mnacamura";
    version = "2021-12-19";
    src = fetchurl {
      url = "https://github.com/mnacamura/iron.nvim/archive/0b8748a1e3194b1239372111c1902cf7a14e10fc.tar.gz";
      sha256 = "1mavmzfm8nrb1a33a2im35plmhlc5lzf940rvi5svpwh93dhd7ma";
    };
    meta = with lib; {
      description = "A fork of IRON, Interactive Repl Over Neovim";
      homepage = "https://github.com/mnacamura/iron.nvim";
      license = with licenses; [ bsd3 ];
    };
  };
  nvim-srcerite = buildVimPluginFrom2Nix {
    pname = "nvim-srcerite";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/mnacamura/nvim-srcerite/archive/ab4f02b3786b595fb3d0604ed784c6564d2d1004.tar.gz";
      sha256 = "0xn8k85mmkhiy2508sbyiqqqhw17a38vp6p2rvla79h0hkz7k67g";
    };
    meta = with lib; {
      description = "A colorscheme for Neovim inspired by Srcery";
      homepage = "https://github.com/mnacamura/nvim-srcerite";
    };
  };
  vim-fennel-syntax = buildVimPluginFrom2Nix {
    pname = "vim-fennel-syntax";
    version = "2021-07-08";
    src = fetchurl {
      url = "https://github.com/mnacamura/vim-fennel-syntax/archive/de616bba32ddd1ecbef30e76aca80d1fbcf8e95c.tar.gz";
      sha256 = "1xiyjr66nhg9bv6nkvl90vas85i5qizlbbpqsss235qxx3yf9w9i";
    };
    meta = with lib; {
      description = "Vim syntax highlighting for Fennel";
      homepage = "https://github.com/mnacamura/vim-fennel-syntax";
      license = with licenses; [ mit ];
    };
  };
  vim-r7rs-syntax = buildVimPluginFrom2Nix {
    pname = "vim-r7rs-syntax";
    version = "2021-07-09";
    src = fetchurl {
      url = "https://github.com/mnacamura/vim-r7rs-syntax/archive/e5f1d0cf9974154f00aa9a249dadce9c7bfc5c65.tar.gz";
      sha256 = "0iz6n1c8h6yijd40lzmfjlxa7fym3hh7b57yavfz39bgzihz24nj";
    };
    meta = with lib; {
      description = "Vim syntax highlighting for R7RS Scheme and Gauche";
      homepage = "https://github.com/mnacamura/vim-r7rs-syntax";
      license = with licenses; [ mit ];
    };
  };
  dial-nvim = buildVimPluginFrom2Nix {
    pname = "dial-nvim";
    version = "2022-06-18";
    src = fetchurl {
      url = "https://github.com/monaqa/dial.nvim/archive/6e6e7bfcef241d5bde01ee08d2b64ea8579af83f.tar.gz";
      sha256 = "069vsdjhfk94fp7yq09w90zsb629ri5rciiqsj5rvfn9sq4fq2nj";
    };
    meta = with lib; {
      description = "enhanced increment/decrement plugin for Neovim";
      homepage = "https://github.com/monaqa/dial.nvim";
      license = with licenses; [ mit ];
    };
  };
  matchparen-nvim = buildVimPluginFrom2Nix {
    pname = "matchparen-nvim";
    version = "2022-06-09";
    src = fetchurl {
      url = "https://github.com/monkoose/matchparen.nvim/archive/e2ada0bf3f6f67997df54fc9c8a7359ec0477119.tar.gz";
      sha256 = "01jcq5lpim72kf6s1nsia4vb536gkv3vjvlycbary6nvrp1javqb";
    };
    meta = with lib; {
      description = "alternative to matchparen neovim plugin ";
      homepage = "https://github.com/monkoose/matchparen.nvim";
      license = with licenses; [ mit ];
    };
  };
  legendary-nvim = buildVimPluginFrom2Nix {
    pname = "legendary-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/mrjones2014/legendary.nvim/archive/b0bcc7681ba884d1222faa8f2a56a438a02fc7c7.tar.gz";
      sha256 = "18nb8fxly8b0zcnxmmrs80b709d6pzpglk3x38givx3ljkc5dnl3";
    };
    meta = with lib; {
      description = "🗺️ A legend for your keymaps, commands, and autocmds, with which-key.nvim integration";
      homepage = "https://github.com/mrjones2014/legendary.nvim";
      license = with licenses; [ mit ];
    };
  };
  coq-nvim = buildVimPluginFrom2Nix {
    pname = "coq-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/ms-jpq/coq_nvim/archive/2b28f71eb8f71a7f2d82dc98aa9d55c6832896ee.tar.gz";
      sha256 = "06y28yz2x4fhxgsyi3j9c20f4v5av6zvfp1x57j4ns3ak88ig9gj";
    };
    meta = with lib; {
      description = "Fast as FUCK nvim completion. SQLite, concurrent scheduler, hundreds of hours of optimization";
      homepage = "https://github.com/ms-jpq/coq_nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  numb-nvim = buildVimPluginFrom2Nix {
    pname = "numb-nvim";
    version = "2022-03-20";
    src = fetchurl {
      url = "https://github.com/nacro90/numb.nvim/archive/453c50ab921fa066fb073d2fd0f826cb036eaf7b.tar.gz";
      sha256 = "1yk8m47q8vqgbf6gpsg6hbgy5idlii21lrizpsfyc8kj0nxdnxgc";
    };
    meta = with lib; {
      description = "Peek lines just when you intend";
      homepage = "https://github.com/nacro90/numb.nvim";
      license = with licenses; [ mit ];
    };
  };
  luv-vimdocs = buildVimPluginFrom2Nix {
    pname = "luv-vimdocs";
    version = "2022-05-08";
    src = fetchurl {
      url = "https://github.com/nanotee/luv-vimdocs/archive/4b37ef2755906e7f8b9a066b718d502684b55274.tar.gz";
      sha256 = "137jk7nskdj41fga0jm966zkbk1mi1ffm2xcsr6shjf2f3gfs6ma";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/nanotee/luv-vimdocs";
      license = with licenses; [ asl20 ];
    };
  };
  nvim-lsp-basics = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-basics";
    version = "2022-05-08";
    src = fetchurl {
      url = "https://github.com/nanotee/nvim-lsp-basics/archive/632714bd3ab355eb6e725b5a78cd8730f12d14d2.tar.gz";
      sha256 = "1zsbmqz1j022mkg95kvhf7nnxjphlzgsq6fs1gj1hqizp4rgjg3h";
    };
    meta = with lib; {
      description = "Basic wrappers for LSP features";
      homepage = "https://github.com/nanotee/nvim-lsp-basics";
      license = with licenses; [ mit ];
    };
  };
  sqls-nvim = buildVimPluginFrom2Nix {
    pname = "sqls-nvim";
    version = "2022-07-08";
    src = fetchurl {
      url = "https://github.com/nanotee/sqls.nvim/archive/a0048b7018c99b68456f91b4aa42ce288f0c0774.tar.gz";
      sha256 = "0jph3hfcmkf11m1hxc91h6j590hw0pnc1gkx3wmsqd0w4m1z40qp";
    };
    meta = with lib; {
      description = "Neovim plugin for sqls that leverages the built-in LSP client";
      homepage = "https://github.com/nanotee/sqls.nvim";
      license = with licenses; [ mit ];
    };
  };
  tabby-nvim = buildVimPluginFrom2Nix {
    pname = "tabby-nvim";
    version = "2022-07-13";
    src = fetchurl {
      url = "https://github.com/nanozuki/tabby.nvim/archive/c473f1ac3db262605b716afcb570f46f27fe8eb3.tar.gz";
      sha256 = "0rshax12bq8zf2yxc990l3ixfbhxmzy1cdnqky5qj1d73nhagwmc";
    };
    meta = with lib; {
      description = "A minimal, configurable, neovim style tabline. Use your nvim tabs as workspace multiplexer";
      homepage = "https://github.com/nanozuki/tabby.nvim";
      license = with licenses; [ mit ];
    };
  };
  xresources-nvim = buildVimPluginFrom2Nix {
    pname = "xresources-nvim";
    version = "2021-11-23";
    src = fetchurl {
      url = "https://github.com/nekonako/xresources-nvim/archive/745b4df924a6c4a7d8026a3fb3a7fa5f78e6f582.tar.gz";
      sha256 = "1xnw9cf81x5rwiql78ghhda0jjcap9qxrvzv9101kljwzz3klzvj";
    };
    meta = with lib; {
      description = "🎨 Neovim colorscheme based on your xresources color";
      homepage = "https://github.com/nekonako/xresources-nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  nvim-lspconfig = buildVimPluginFrom2Nix {
    pname = "nvim-lspconfig";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/neovim/nvim-lspconfig/archive/ba25b747a3cff70c1532c2f28fcc912cf7b938ea.tar.gz";
      sha256 = "0yjgnjka0wl1bma0dri7k0zx0ql3mka1dbncavc93srl3ap70mzn";
    };
    meta = with lib; {
      description = "Quickstart configs for Nvim LSP";
      homepage = "https://github.com/neovim/nvim-lspconfig";
    };
  };
  neomux = buildVimPluginFrom2Nix {
    pname = "neomux";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/nikvdp/neomux/archive/7fa6754f3c781ca99fd533217443b1e4f86611d4.tar.gz";
      sha256 = "028hcvhvap4p3gqg4h43arizpwzp1vs6dvrhh6s0by10d902867s";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/nikvdp/neomux";
      license = with licenses; [ mit ];
    };
  };
  numbers-nvim = buildVimPluginFrom2Nix {
    pname = "numbers-nvim";
    version = "2022-04-25";
    src = fetchurl {
      url = "https://github.com/nkakouros-original/numbers.nvim/archive/01c50eb6cd66ca61e7009b19a71603cc55768fb1.tar.gz";
      sha256 = "0wsmngndz4qg2m06x11y3798wl0yvqqxrjlq9aal4dhxn645dw2a";
    };
    meta = with lib; {
      description = "Toggles relativenumbers when not needed";
      homepage = "https://github.com/nkakouros-original/numbers.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-cokeline = buildVimPluginFrom2Nix {
    pname = "nvim-cokeline";
    version = "2022-06-21";
    src = fetchurl {
      url = "https://github.com/noib3/nvim-cokeline/archive/8d5022789014a605d5a2ec02ed5133eb85874aff.tar.gz";
      sha256 = "04x2s9gxycbcgw93m79387kbwz2is76271sbfbynxhy223nch5iz";
    };
    meta = with lib; {
      description = ":nose: A Neovim bufferline for people with addictive personalities";
      homepage = "https://github.com/noib3/nvim-cokeline";
      license = with licenses; [ mit ];
    };
  };
  nvim-compleet = buildVimPluginFrom2Nix {
    pname = "nvim-compleet";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/noib3/nvim-compleet/archive/ff15b269d702f4e47d406b2c4a44bc8dc981306b.tar.gz";
      sha256 = "0w52020xq4li9qmnk1zjj3ldy2bj9ib5xmjhigc40x7vx3dgnssh";
    };
    meta = with lib; {
      description = ":zap: An async autocompletion framework for Neovim";
      homepage = "https://github.com/noib3/nvim-compleet";
      license = with licenses; [ mit ];
    };
  };
  nvim-base16-lua = buildVimPluginFrom2Nix {
    pname = "nvim-base16-lua";
    version = "2019-10-16";
    src = fetchurl {
      url = "https://github.com/norcalli/nvim-base16.lua/archive/b336f40462b3ca1ad16a17c195b83731a2942d9a.tar.gz";
      sha256 = "1nxs9xk37x2vkcijhrd8svslphjvlpj4bm0jw2yswrk3nxjjjj94";
    };
    meta = with lib; {
      description = "Programmatic lua library for setting base16 themes in Neovim";
      homepage = "https://github.com/norcalli/nvim-base16.lua";
    };
  };
  nvim-colorizer-lua = buildVimPluginFrom2Nix {
    pname = "nvim-colorizer-lua";
    version = "2020-06-11";
    src = fetchurl {
      url = "https://github.com/norcalli/nvim-colorizer.lua/archive/36c610a9717cc9ec426a07c8e6bf3b3abcb139d6.tar.gz";
      sha256 = "10s2ld62ckqq1gvkf9ifci5mx8xxs92axhn47nbdfa86al1ywcgp";
    };
    meta = with lib; {
      description = "The fastest Neovim colorizer";
      homepage = "https://github.com/norcalli/nvim-colorizer.lua";
    };
  };
  nvim-terminal-lua = buildVimPluginFrom2Nix {
    pname = "nvim-terminal-lua";
    version = "2019-10-17";
    src = fetchurl {
      url = "https://github.com/norcalli/nvim-terminal.lua/archive/095f98aaa7265628a72cd2706350c091544b5602.tar.gz";
      sha256 = "18j89r81pljn3l01xvvdzrlw8ppid5jilc3zi00crbfd6ffqhb44";
    };
    meta = with lib; {
      description = "A high performance filetype mode for Neovim which leverages conceal and highlights your buffer with the correct color codes";
      homepage = "https://github.com/norcalli/nvim-terminal.lua";
      license = with licenses; [ mit ];
    };
  };
  snippets-nvim = buildVimPluginFrom2Nix {
    pname = "snippets-nvim";
    version = "2020-09-09";
    src = fetchurl {
      url = "https://github.com/norcalli/snippets.nvim/archive/7b5fd8071d4fb6fa981a899aae56b55897c079fd.tar.gz";
      sha256 = "0r6cwwc80kp58vfwp3ly4h5cmyy7n9wxcf4az150a16mazif6bvn";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/norcalli/snippets.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  cmdbuf-nvim = buildVimPluginFrom2Nix {
    pname = "cmdbuf-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/notomo/cmdbuf.nvim/archive/ddd408e0e85d1b5b31497923fb446ae6a7edd39c.tar.gz";
      sha256 = "042v4yfnnk79yvvjvpif64yhf9xj720zhnvwyr61g7lxy8nic6nw";
    };
    meta = with lib; {
      description = "Alternative command-line window plugin for neovim";
      homepage = "https://github.com/notomo/cmdbuf.nvim";
      license = with licenses; [ mit ];
    };
  };
  gesture-nvim = buildVimPluginFrom2Nix {
    pname = "gesture-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/notomo/gesture.nvim/archive/a6c51c45e9a493cc3c1feae461ea5d23b1aa7cd6.tar.gz";
      sha256 = "17670lpidka3308kq6s3vf8ycl9z52ak922bashkwvkb01gz8zij";
    };
    meta = with lib; {
      description = "Mouse gesture plugin for neovim";
      homepage = "https://github.com/notomo/gesture.nvim";
      license = with licenses; [ mit ];
    };
  };
  kosmikoa-nvim = buildVimPluginFrom2Nix {
    pname = "kosmikoa-nvim";
    version = "2021-11-19";
    src = fetchurl {
      url = "https://github.com/novakne/kosmikoa.nvim/archive/a32b908fb2018f0f0ed1b92ff334db0d317f5dd7.tar.gz";
      sha256 = "0dq260294w6398rc98vlhcxkszha3s0j1kz1wf7ln6in7qs8av9j";
    };
    meta = with lib; {
      description = "A dark color scheme for Neovim with support for LSP, Treesitter. This mirror is deprecated. Use the repo at https://sr.ht/~novakane/kosmikoa.nvim/";
      homepage = "https://github.com/novakne/kosmikoa.nvim";
      license = with licenses; [ mit ];
    };
  };
  Comment-nvim = buildVimPluginFrom2Nix {
    pname = "Comment-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/78ab4e9785b6da9b7a539df3bd6f70300dc9482b.tar.gz";
      sha256 = "0127v0kqsm7zf47i7phy3fj91ywvi2mp9cmc3pq8d5hv3h1gq6yh";
    };
    meta = with lib; {
      description = ":brain: :muscle: // Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more";
      homepage = "https://github.com/numToStr/Comment.nvim";
      license = with licenses; [ mit ];
    };
  };
  FTerm-nvim = buildVimPluginFrom2Nix {
    pname = "FTerm-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/numToStr/FTerm.nvim/archive/efd10656724a269e21ba68d65e2b058a4e606424.tar.gz";
      sha256 = "04z6yxm1vlbaayrpp5vwhb03dbkyzf7wa08n7dkk70yi3ddbvc4r";
    };
    meta = with lib; {
      description = ":fire: No-nonsense floating terminal plugin for neovim :fire:";
      homepage = "https://github.com/numToStr/FTerm.nvim";
      license = with licenses; [ mit ];
    };
  };
  Navigator-nvim = buildVimPluginFrom2Nix {
    pname = "Navigator-nvim";
    version = "2022-04-29";
    src = fetchurl {
      url = "https://github.com/numToStr/Navigator.nvim/archive/0c57f67a34eff7fd20785861926b7fe6bd76e2c2.tar.gz";
      sha256 = "1307yqd16n7y9nyva1m2ns242210jn4fbsf423pgslkrkbv779ln";
    };
    meta = with lib; {
      description = ":sparkles: Smoothly navigate between neovim splits and tmux panes :sparkles:";
      homepage = "https://github.com/numToStr/Navigator.nvim";
      license = with licenses; [ mit ];
    };
  };
  lsp-status-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-status-nvim";
    version = "2021-12-08";
    src = fetchurl {
      url = "https://github.com/nvim-lua/lsp-status.nvim/archive/4073f766f1303fb602802075e558fe43e382cc92.tar.gz";
      sha256 = "0by37fb7mn98c5q65yc469j3972zav8ycxfsrr8h293p4zc3g7d6";
    };
    meta = with lib; {
      description = "Utility functions for getting diagnostic status and progress messages from LSP servers, for use in the Neovim statusline";
      homepage = "https://github.com/nvim-lua/lsp-status.nvim";
      license = with licenses; [ mit ];
    };
  };
  lsp-extensions-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-extensions-nvim";
    version = "2022-07-07";
    src = fetchurl {
      url = "https://github.com/nvim-lua/lsp_extensions.nvim/archive/92c08d4914d5d272fae13c499aafc9f14eb05ada.tar.gz";
      sha256 = "1v9j9rmfq70pklilczmp8bf60vcb6yb9qd5b5sz5hl1rrsypgy5q";
    };
    meta = with lib; {
      description = "Repo to hold a bunch of info & extension callbacks for built-in LSP. Use at your own risk :wink:";
      homepage = "https://github.com/nvim-lua/lsp_extensions.nvim";
      license = with licenses; [ mit ];
    };
  };
  plenary-nvim = buildVimPluginFrom2Nix {
    pname = "plenary-nvim";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/nvim-lua/plenary.nvim/archive/986ad71ae930c7d96e812734540511b4ca838aa2.tar.gz";
      sha256 = "0h2ffmvl43pzq1rlv34pq76gc7bjq25azqkm4fwi0g5r4h05ifmk";
    };
    meta = with lib; {
      description = "plenary: full; complete; entire; absolute; unqualified. All the lua functions I don't want to write twice";
      homepage = "https://github.com/nvim-lua/plenary.nvim";
      license = with licenses; [ mit ];
    };
  };
  popup-nvim = buildVimPluginFrom2Nix {
    pname = "popup-nvim";
    version = "2021-11-18";
    src = fetchurl {
      url = "https://github.com/nvim-lua/popup.nvim/archive/b7404d35d5d3548a82149238289fa71f7f6de4ac.tar.gz";
      sha256 = "0rycfq1qax3p2bpz94l7f0zg9rfd847c9np5rwr1psg86iapyk0y";
    };
    meta = with lib; {
      description = "[WIP] An implementation of the Popup API from vim in Neovim. Hope to upstream when complete";
      homepage = "https://github.com/nvim-lua/popup.nvim";
      license = with licenses; [ mit ];
    };
  };
  lualine-nvim = buildVimPluginFrom2Nix {
    pname = "lualine-nvim";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/nvim-lualine/lualine.nvim/archive/5f68f070e4f7158517afc55f125a6f5ed1f7db47.tar.gz";
      sha256 = "1ix6clvmpwa94cx94dw4cmi92lpzh2v6phd32q90wwjra7ygrvvc";
    };
    meta = with lib; {
      description = "A blazing fast and easy to configure neovim statusline plugin written in pure lua";
      homepage = "https://github.com/nvim-lualine/lualine.nvim";
      license = with licenses; [ mit ];
    };
  };
  neo-tree-nvim = buildVimPluginFrom2Nix {
    pname = "neo-tree-nvim";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/nvim-neo-tree/neo-tree.nvim/archive/3f8997e7e2819eb75e42386bcf761382766f265d.tar.gz";
      sha256 = "0nzfyb7hm7jqprcahjhdhz89j7vdni0q5qs2dbvblf33d3i3q5ki";
    };
    meta = with lib; {
      description = "Neovim plugin to manage the file system and other tree like structures";
      homepage = "https://github.com/nvim-neo-tree/neo-tree.nvim";
      license = with licenses; [ mit ];
    };
  };
  neorg = buildVimPluginFrom2Nix {
    pname = "neorg";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/nvim-neorg/neorg/archive/2c4305eb32b10710a043380069c5538632160260.tar.gz";
      sha256 = "02y2iiz6lxdz7nid06xkbpfhp3xxx7k62bcrypfq0f0v1k83nwd1";
    };
    meta = with lib; {
      description = "Modernity meets insane extensibility. The future of organizing your life in Neovim";
      homepage = "https://github.com/nvim-neorg/neorg";
      license = with licenses; [ gpl3Only ];
    };
  };
  neotest = buildVimPluginFrom2Nix {
    pname = "neotest";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/nvim-neotest/neotest/archive/aab54ae5e1651cc8221638376969af58408d7218.tar.gz";
      sha256 = "1rgkjh7z0fzi4b81i5qbfadmdn8738mic45rkwd5vq7jx22prxi3";
    };
    meta = with lib; {
      description = "An extensible framework for interacting with tests within NeoVim";
      homepage = "https://github.com/nvim-neotest/neotest";
      license = with licenses; [ mit ];
    };
  };
  orgmode = buildVimPluginFrom2Nix {
    pname = "orgmode";
    version = "2022-07-09";
    src = fetchurl {
      url = "https://github.com/nvim-orgmode/orgmode/archive/8cc6fa4599aeae171d3051570a10c94269acf05f.tar.gz";
      sha256 = "0x9vdb837j922nk7jsc0z6fzyhs8f4k2mvrm0gap5zxlh15yfihp";
    };
    meta = with lib; {
      description = "Orgmode clone written in Lua for Neovim 0.7+";
      homepage = "https://github.com/nvim-orgmode/orgmode";
      license = with licenses; [ mit ];
    };
  };
  telescope-bibtex-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-bibtex-nvim";
    version = "2022-05-01";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope-bibtex.nvim/archive/cd2640e74657f154b50e2278a279ad02ba523e97.tar.gz";
      sha256 = "1333j9p5q2q8zaagpx4kdwj7i8sc9ywjw5386ni6g5b68796nlww";
    };
    meta = with lib; {
      description = "A telescope.nvim extension to search and paste bibtex entries into your TeX files";
      homepage = "https://github.com/nvim-telescope/telescope-bibtex.nvim";
      license = with licenses; [ mit ];
    };
  };
  telescope-media-files-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-media-files-nvim";
    version = "2021-10-21";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope-media-files.nvim/archive/513e4ee385edd72bf0b35a217b7e39f84b6fe93c.tar.gz";
      sha256 = "1wqarqbbj2xc8p496s6k9cg3vsippwpvdqd4438rfnb31cd74ypa";
    };
    meta = with lib; {
      description = "Telescope extension to preview media files using Ueberzug";
      homepage = "https://github.com/nvim-telescope/telescope-media-files.nvim";
      license = with licenses; [ mit ];
    };
  };
  telescope-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope.nvim/archive/b5833a682c511885887373aad76272ad70f7b3c2.tar.gz";
      sha256 = "0jdqz9nbcq713aha3q9v7yx6p2j5sz0cmbm62j0xsdpz70fmf0h4";
    };
    meta = with lib; {
      description = "Find, Filter, Preview, Pick. All lua, all the time";
      homepage = "https://github.com/nvim-telescope/telescope.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-treesitter = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter/archive/42891dccf82438ed021cd4ad338ff2412fb31dfd.tar.gz";
      sha256 = "1aa4w85gs98ibkkcd92dfrfmp0rj8yxp4fab5kxxac7vi7wyx1iv";
    };
    meta = with lib; {
      description = "Nvim Treesitter configurations and abstraction layer";
      homepage = "https://github.com/nvim-treesitter/nvim-treesitter";
      license = with licenses; [ asl20 ];
    };
  };
  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2022-07-09";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter-context/archive/0d086d23c0742404e9bd52977712619a621c3da9.tar.gz";
      sha256 = "0ccwzy50jdjqfd7gz17b6g8mn9hiv2il791j273ywpax6xkbf5yx";
    };
    meta = with lib; {
      description = "Show code context";
      homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context";
      license = with licenses; [ mit ];
    };
  };
  nvim-treesitter-textobjects = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-textobjects";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects/archive/40f20e6788e6ce850802cbd2ca029fbb66b5d043.tar.gz";
      sha256 = "1i54i8h03saibgj20kajix4wpnbmjvgzac9n41lwy8inmrkb0s4z";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects";
      license = with licenses; [ asl20 ];
    };
  };
  vn-night-nvim = buildVimPluginFrom2Nix {
    pname = "vn-night-nvim";
    version = "2022-06-04";
    src = fetchurl {
      url = "https://github.com/nxvu699134/vn-night.nvim/archive/79edbafd73e47fa2909cf3791fbe9e8b78b55156.tar.gz";
      sha256 = "0y1knkiwzsblwcgka16zrrk65f9s3krkc0qj46j8mysff6025cx5";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/nxvu699134/vn-night.nvim";
      license = with licenses; [ mit ];
    };
  };
  NeoNoName-lua = buildVimPluginFrom2Nix {
    pname = "NeoNoName-lua";
    version = "2022-06-20";
    src = fetchurl {
      url = "https://github.com/nyngwang/NeoNoName.lua/archive/f3497cd3a0a6644e4c7ef3fc394071fddea267fc.tar.gz";
      sha256 = "00vdvkzylg0fslppnhv3nnlpyxvzyhxksb476g301hkxlgvabx41";
    };
    meta = with lib; {
      description = "Enhanced buffer delete written in pure lua";
      homepage = "https://github.com/nyngwang/NeoNoName.lua";
    };
  };
  NeoRoot-lua = buildVimPluginFrom2Nix {
    pname = "NeoRoot-lua";
    version = "2022-04-19";
    src = fetchurl {
      url = "https://github.com/nyngwang/NeoRoot.lua/archive/998b3c08bf91c523c6fa502ca0dabf14c24d67ae.tar.gz";
      sha256 = "16nqc1ypnj366vdvp99gawd5lhqp094w2a72mabfi3gpslxg8m19";
    };
    meta = with lib; {
      description = "Yet another light-weight rooter written in Lua";
      homepage = "https://github.com/nyngwang/NeoRoot.lua";
    };
  };
  neuron-nvim = buildVimPluginFrom2Nix {
    pname = "neuron-nvim";
    version = "2022-02-27";
    src = fetchurl {
      url = "https://github.com/oberblastmeister/neuron.nvim/archive/c44032ece3cb71a9ce45043d246828cd1cef002c.tar.gz";
      sha256 = "108ismvmw03rgfnbkkbvfqas3aar0cs2cg8w8k9cfwxj78ahc59h";
    };
    meta = with lib; {
      description = "Make neovim the best note taking application";
      homepage = "https://github.com/oberblastmeister/neuron.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-hardline = buildVimPluginFrom2Nix {
    pname = "nvim-hardline";
    version = "2022-06-18";
    src = fetchurl {
      url = "https://github.com/ojroques/nvim-hardline/archive/9658c92328e0806fe951908bed305cbcc77e1c9b.tar.gz";
      sha256 = "0jfzdh2ydd3vn04xdjlvc7fsz67y8dhnzkj4y43rn1p739xwclxm";
    };
    meta = with lib; {
      description = "A simple Neovim statusline";
      homepage = "https://github.com/ojroques/nvim-hardline";
      license = with licenses; [ bsd2 ];
    };
  };
  nvim-lspfuzzy = buildVimPluginFrom2Nix {
    pname = "nvim-lspfuzzy";
    version = "2022-05-22";
    src = fetchurl {
      url = "https://github.com/ojroques/nvim-lspfuzzy/archive/9ad50ac644a438799dc452dfeeed9437aa5aa8b6.tar.gz";
      sha256 = "0q6pwzk22j9d033q1ppgvhmdgd28680vvi8h8mm30f8brl1pgcr8";
    };
    meta = with lib; {
      description = "A Neovim plugin to make the LSP client use FZF";
      homepage = "https://github.com/ojroques/nvim-lspfuzzy";
      license = with licenses; [ bsd2 ];
    };
  };
  onedarkpro-nvim = buildVimPluginFrom2Nix {
    pname = "onedarkpro-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/olimorris/onedarkpro.nvim/archive/2c439754e1a60d42197e79461bf04e358213a654.tar.gz";
      sha256 = "0qqcp9rxdprgiwahah0f44mglrzk0imj35wzrsm73qwqp7dcqmam";
    };
    meta = with lib; {
      description = "🎨 OneDarkPro theme for Neovim. Completely customisable colors, styles and highlights. Supports custom highlights by filetype!";
      homepage = "https://github.com/olimorris/onedarkpro.nvim";
      license = with licenses; [ mit ];
    };
  };
  persisted-nvim = buildVimPluginFrom2Nix {
    pname = "persisted-nvim";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/olimorris/persisted.nvim/archive/0f5f24f4c4998f20a1b8417dcf12a653a3c60913.tar.gz";
      sha256 = "0v65ky46mx38dffx0wf8y6ppimcnaji9ws2z0r7ym2hbfkacqjs6";
    };
    meta = with lib; {
      description = "💾 Simple session management for Neovim with git branching, autosave/autoload and Telescope support";
      homepage = "https://github.com/olimorris/persisted.nvim";
      license = with licenses; [ mit ];
    };
  };
  diaglist-nvim = buildVimPluginFrom2Nix {
    pname = "diaglist-nvim";
    version = "2022-01-11";
    src = fetchurl {
      url = "https://github.com/onsails/diaglist.nvim/archive/6c43beac1ff07f6ef00f063090b5a6c9ed11b800.tar.gz";
      sha256 = "0bn2krf8xvd1hq3g0h0w3j95hhigs7ffa421p45bd9174pqrvrqn";
    };
    meta = with lib; {
      description = "Live render workspace diagnostics in quickfix with current buf errors on top, buffer diagnostics in loclist";
      homepage = "https://github.com/onsails/diaglist.nvim";
    };
  };
  lspkind-nvim = buildVimPluginFrom2Nix {
    pname = "lspkind-nvim";
    version = "2022-04-18";
    src = fetchurl {
      url = "https://github.com/onsails/lspkind.nvim/archive/57e5b5dfbe991151b07d272a06e365a77cc3d0e7.tar.gz";
      sha256 = "0ighrb7svcfqh5lsyp43nlbv8j08ji2f8j8vbmp214x9lykxfnbr";
    };
    meta = with lib; {
      description = "vscode-like pictograms for neovim lsp completion items";
      homepage = "https://github.com/onsails/lspkind.nvim";
      license = with licenses; [ mit ];
    };
  };
  cphelper-nvim = buildVimPluginFrom2Nix {
    pname = "cphelper-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/p00f/cphelper.nvim/archive/27f19bb5defc68200aa1894a78e814453d8136b9.tar.gz";
      sha256 = "0f0kl0sim0hj6dz873kkfj26k2zf15cngsb8wpvx7hxcdh45v15f";
    };
    meta = with lib; {
      description = "Neovim helper for competitive programming. https://sr.ht/~p00f/cphelper.nvim preferred";
      homepage = "https://github.com/p00f/cphelper.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-ts-rainbow = buildVimPluginFrom2Nix {
    pname = "nvim-ts-rainbow";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/p00f/nvim-ts-rainbow/archive/9dd019e84dc3b470dfdb5b05e3bb26158fef8a0c.tar.gz";
      sha256 = "1zdj43n1kbpmfl865ixxbp78bnh3nc66068xy729d9lrckrfnksf";
    };
    meta = with lib; {
      description = "Rainbow parentheses for neovim using tree-sitter. https://sr.ht/~p00f/nvim-ts-rainbow preferred";
      homepage = "https://github.com/p00f/nvim-ts-rainbow";
      license = with licenses; [ asl20 ];
    };
  };
  cmp-git = buildVimPluginFrom2Nix {
    pname = "cmp-git";
    version = "2022-05-11";
    src = fetchurl {
      url = "https://github.com/petertriho/cmp-git/archive/60e3de62b925ea05c7aa37883408859c72d498fb.tar.gz";
      sha256 = "1i3l0d0ba9zacgi51ijw5yyj7rvialjg493ag7w98hay81aamdi6";
    };
    meta = with lib; {
      description = "Git source for nvim-cmp";
      homepage = "https://github.com/petertriho/cmp-git";
      license = with licenses; [ mit ];
    };
  };
  nvim-scrollbar = buildVimPluginFrom2Nix {
    pname = "nvim-scrollbar";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/petertriho/nvim-scrollbar/archive/ce0df6954a69d61315452f23f427566dc1e937ae.tar.gz";
      sha256 = "12z86ci9c13rivd19wjbx5df816f3sq0g1gkwij6nnzs447dk0iq";
    };
    meta = with lib; {
      description = "Extensible Neovim Scrollbar";
      homepage = "https://github.com/petertriho/nvim-scrollbar";
      license = with licenses; [ mit ];
    };
  };
  hop-nvim = buildVimPluginFrom2Nix {
    pname = "hop-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/phaazon/hop.nvim/archive/ced6c94204c6cd55c583e6bce6397fd1c91eb214.tar.gz";
      sha256 = "1bgkbirzq8nh4yqplcdgfwb4bf86vz53x8rsx3a72vk4az4yvz0m";
    };
    meta = with lib; {
      description = "Neovim motions on speed!";
      homepage = "https://github.com/phaazon/hop.nvim";
    };
  };
  zenburn-nvim = buildVimPluginFrom2Nix {
    pname = "zenburn-nvim";
    version = "2022-04-28";
    src = fetchurl {
      url = "https://github.com/phha/zenburn.nvim/archive/f70eea4d1c44a29831c86dbbecb26d3a5341a951.tar.gz";
      sha256 = "171favjr1vc19lvvy01dwnvfkjswji7vw1nlsyy0di976bsnyy6a";
    };
    meta = with lib; {
      description = "Zenburn for the modern age";
      homepage = "https://github.com/phha/zenburn.nvim";
      license = with licenses; [ mit ];
    };
  };
  consolation-nvim = buildVimPluginFrom2Nix {
    pname = "consolation-nvim";
    version = "2021-09-01";
    src = fetchurl {
      url = "https://github.com/pianocomposer321/consolation.nvim/archive/9111a1e5204e6d522e0229569f5f2841faa7a72f.tar.gz";
      sha256 = "0dldx3mm8a5sm6bgrgpmr6kxhwkq4j5wwgqg5y1djqsx0c8xhxp1";
    };
    meta = with lib; {
      description = "A general-purpose terminal wrapper and management plugin for neovim, written in lua";
      homepage = "https://github.com/pianocomposer321/consolation.nvim";
    };
  };
  yabs-nvim = buildVimPluginFrom2Nix {
    pname = "yabs-nvim";
    version = "2022-05-09";
    src = fetchurl {
      url = "https://github.com/pianocomposer321/yabs.nvim/archive/88bdb5c557448960be3cb9d3da64e52009e7bef9.tar.gz";
      sha256 = "032h765cdw251xns4c6r0pwwa1gvbv8lkcb77k7xb7nrlkgdij1f";
    };
    meta = with lib; {
      description = "Yet Another Build System/Code Runner for Neovim, written in lua";
      homepage = "https://github.com/pianocomposer321/yabs.nvim";
      license = with licenses; [ agpl3Only ];
    };
  };
  github-nvim-theme = buildVimPluginFrom2Nix {
    pname = "github-nvim-theme";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/projekt0n/github-nvim-theme/archive/6c9b575a6bd28ddce3ca282955c77d426c20cec3.tar.gz";
      sha256 = "1q17s7s5i0msb903j14pngdm109p1hpqm451g3kvjjxh3r1bj617";
    };
    meta = with lib; {
      description = "Github's Neovim and Terminals themes (Unofficial Community-driven)";
      homepage = "https://github.com/projekt0n/github-nvim-theme";
      license = with licenses; [ mit ];
    };
  };
  codeql-nvim = buildVimPluginFrom2Nix {
    pname = "codeql-nvim";
    version = "2022-07-12";
    src = fetchurl {
      url = "https://github.com/pwntester/codeql.nvim/archive/0373bdb93f9256c2a204472e0c976be8ab971914.tar.gz";
      sha256 = "0qm4vcqwbsghlabpk50mhfmjpygqnlj2bmjh3qi9a1pgm9zvwan2";
    };
    meta = with lib; {
      description = "CodeQL plugin for Neovim";
      homepage = "https://github.com/pwntester/codeql.nvim";
    };
  };
  octo-nvim = buildVimPluginFrom2Nix {
    pname = "octo-nvim";
    version = "2022-06-30";
    src = fetchurl {
      url = "https://github.com/pwntester/octo.nvim/archive/1f6a770a3b2a463cff474df51dc037ae7a6c2920.tar.gz";
      sha256 = "135anjn7nbnwfr3pscbjr90inknksnvknvys7c785l6z6rdixzgh";
    };
    meta = with lib; {
      description = "Edit and review GitHub issues and pull requests from the comfort of your favorite editor";
      homepage = "https://github.com/pwntester/octo.nvim";
      license = with licenses; [ mit ];
    };
  };
  cmp-nvim-ultisnips = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-ultisnips";
    version = "2022-04-22";
    src = fetchurl {
      url = "https://github.com/quangnguyen30192/cmp-nvim-ultisnips/archive/21f02b62deb409ce69928a23406076bd0043ddbc.tar.gz";
      sha256 = "19r1s417nhdmzarx2vnzc4zwisbxj1846zrncva3p3rj1ajfkyyc";
    };
    meta = with lib; {
      description = "nvim-cmp source for ultisnips";
      homepage = "https://github.com/quangnguyen30192/cmp-nvim-ultisnips";
      license = with licenses; [ asl20 ];
    };
  };
  nvim-goc-lua = buildVimPluginFrom2Nix {
    pname = "nvim-goc-lua";
    version = "2022-06-07";
    src = fetchurl {
      url = "https://github.com/rafaelsq/nvim-goc.lua/archive/723c2dec751d5028350e587b70bb043213439115.tar.gz";
      sha256 = "0vjxlrpkd8wf18qs2yyq6pkvpf3ass23f3m1cn5llaz1s889iqy6";
    };
    meta = with lib; {
      description = "Go Coverage for Neovim";
      homepage = "https://github.com/rafaelsq/nvim-goc.lua";
      license = with licenses; [ mit ];
    };
  };
  neon = buildVimPluginFrom2Nix {
    pname = "neon";
    version = "2021-07-30";
    src = fetchurl {
      url = "https://github.com/rafamadriz/neon/archive/5c6d24504e2177a709ad16ae9e89ab5732327ad8.tar.gz";
      sha256 = "0yz8a2ralm499y35jldghfyrpwvzld3lz88n1j4j1q2j2mgcnwdw";
    };
    meta = with lib; {
      description = "Customizable coloscheme with dark and light options, vivid colors and easy on the eye";
      homepage = "https://github.com/rafamadriz/neon";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-luapad = buildVimPluginFrom2Nix {
    pname = "nvim-luapad";
    version = "2022-07-09";
    src = fetchurl {
      url = "https://github.com/rafcamlet/nvim-luapad/archive/9815e2659ce8e2ef4b55e401531cf09b6423e0ea.tar.gz";
      sha256 = "12apn8qpdvip9nrnymdmvx456pbsxslz0xnh3ad2kgcdl3wvf3ir";
    };
    meta = with lib; {
      description = "Interactive real time neovim scratchpad for embedded lua engine - type and watch!";
      homepage = "https://github.com/rafcamlet/nvim-luapad";
    };
  };
  tabline-framework-nvim = buildVimPluginFrom2Nix {
    pname = "tabline-framework-nvim";
    version = "2022-03-09";
    src = fetchurl {
      url = "https://github.com/rafcamlet/tabline-framework.nvim/archive/fc388232a38c2ff0e5a7f8840371301d2fd89606.tar.gz";
      sha256 = "071jvyvsn433k9vb5v4wmkdqsadqd0s1fyhcshqha8izxkajwijp";
    };
    meta = with lib; {
      description = "User-friendly framework for building your dream tabline in a few lines of code";
      homepage = "https://github.com/rafcamlet/tabline-framework.nvim";
      license = with licenses; [ mit ];
    };
  };
  requirements-txt-vim = buildVimPluginFrom2Nix {
    pname = "requirements-txt-vim";
    version = "2022-03-30";
    src = fetchurl {
      url = "https://github.com/raimon49/requirements.txt.vim/archive/b6dd6cc47f3ea14d97ac102a29ad351bbd6f5237.tar.gz";
      sha256 = "08gwr5g8gai43mr1njmm844gl066878kln6xx1sfbsv36g8qv6ks";
    };
    meta = with lib; {
      description = "the Requirements File Format syntax support for Vim";
      homepage = "https://github.com/raimon49/requirements.txt.vim";
      license = with licenses; [ mit ];
    };
  };
  aurora = buildVimPluginFrom2Nix {
    pname = "aurora";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/ray-x/aurora/archive/bc13049ee772cc19f94c69e7f9c198861336a692.tar.gz";
      sha256 = "1cfgw5xsccmpd1x34lhcbvz5iic5j0r6wav2asz1dr3hvwb9sx9s";
    };
    meta = with lib; {
      description = "24-bit dark theme for (Neo)vim. Optimized for treesitter, LSP";
      homepage = "https://github.com/ray-x/aurora";
      license = with licenses; [ mit ];
    };
  };
  go-nvim = buildVimPluginFrom2Nix {
    pname = "go-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/ray-x/go.nvim/archive/3774ac0eba34db6b4dbe9ac07fbd1533ee1cb3c1.tar.gz";
      sha256 = "0nygf25khxv4zzp1b7xq5qb93cs0qpkj0fwxknw1nnwgxa3pg0lg";
    };
    meta = with lib; {
      description = "Modern Go plugin for Neovim, based on gopls, treesitter AST, Dap and a variety of go tools";
      homepage = "https://github.com/ray-x/go.nvim";
      license = with licenses; [ mit ];
    };
  };
  guihua-lua = buildVimPluginFrom2Nix {
    pname = "guihua-lua";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/ray-x/guihua.lua/archive/cbf54aed71176db3b828dcb1dae743b5ae8b25cd.tar.gz";
      sha256 = "0b46ai9h2fig4pzr9djzcy58siqyyd45qnhnqiz4ym1qbldsr5qc";
    };
    meta = with lib; {
      description = "A GUI library for Neovim plugin developer";
      homepage = "https://github.com/ray-x/guihua.lua";
      license = with licenses; [ mit ];
    };
  };
  lsp-signature-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-signature-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/ray-x/lsp_signature.nvim/archive/aea1e060d465fcb565bc1178e4189fc79524ba61.tar.gz";
      sha256 = "0zrfpsgng6zf3yh57q1g7cwch8486gnwn6dm8a2nxx6ps3kryp1v";
    };
    meta = with lib; {
      description = "LSP signature hint as you type";
      homepage = "https://github.com/ray-x/lsp_signature.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  navigator-lua = buildVimPluginFrom2Nix {
    pname = "navigator-lua";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/ray-x/navigator.lua/archive/ed47d386e6a1e02660da644e3e8bb961da18271e.tar.gz";
      sha256 = "0l5qplfwx4p7cgrl2qh5gca0628kns8jhvb5l2608x7dliy1aij2";
    };
    meta = with lib; {
      description = "Symbol analysis & navigation plugin for Neovim. Navigate codes like a breeze🎐.  Exploring LSP and 🌲Treesitter symbols a piece of 🍰. Take control like a boss 🦍";
      homepage = "https://github.com/ray-x/navigator.lua";
      license = with licenses; [ mit ];
    };
  };
  cmp-dap = buildVimPluginFrom2Nix {
    pname = "cmp-dap";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/rcarriga/cmp-dap/archive/e21f0e5d188ee428f8acab1af21839af391607a4.tar.gz";
      sha256 = "027wv30zyfw43gdcl91yn4ipzxaj1nlmyj8bb9fdjr1xa51f4vra";
    };
    meta = with lib; {
      description = "nvim-cmp source for nvim-dap REPL and nvim-dap-ui buffers";
      homepage = "https://github.com/rcarriga/cmp-dap";
      license = with licenses; [ mit ];
    };
  };
  nvim-dap-ui = buildVimPluginFrom2Nix {
    pname = "nvim-dap-ui";
    version = "2022-07-23";
    src = fetchurl {
      url = "https://github.com/rcarriga/nvim-dap-ui/archive/b7b71444128f5aa90e4aee8dbfa36b14afddfb7a.tar.gz";
      sha256 = "1n9ippl2n98mw9inqaivz0nzcvf84vfj2zhc2j99x8vfjwnzl86l";
    };
    meta = with lib; {
      description = "A UI for nvim-dap";
      homepage = "https://github.com/rcarriga/nvim-dap-ui";
    };
  };
  nvim-notify = buildVimPluginFrom2Nix {
    pname = "nvim-notify";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/rcarriga/nvim-notify/archive/cd2a59f16d3dc8c54dabc58c31c9c539fcef3c2b.tar.gz";
      sha256 = "029yz6zsav47a344r4k7dg1wfvdjra8al0q8yww8z2cfznr8sgwn";
    };
    meta = with lib; {
      description = "A fancy, configurable, notification manager for NeoVim";
      homepage = "https://github.com/rcarriga/nvim-notify";
      license = with licenses; [ mit ];
    };
  };
  vim-ultest = buildVimPluginFrom2Nix {
    pname = "vim-ultest";
    version = "2022-06-18";
    src = fetchurl {
      url = "https://github.com/rcarriga/vim-ultest/archive/c93eb128332f8245776b753407ab6c4432c4c556.tar.gz";
      sha256 = "0yif459w7813z19shlvwhgbqb5ilh0i6vxgkbg17pcrda4lx3kc5";
    };
    meta = with lib; {
      description = "The ultimate testing plugin for (Neo)Vim";
      homepage = "https://github.com/rcarriga/vim-ultest";
      license = with licenses; [ mit ];
    };
  };
  heirline-nvim = buildVimPluginFrom2Nix {
    pname = "heirline-nvim";
    version = "2022-07-06";
    src = fetchurl {
      url = "https://github.com/rebelot/heirline.nvim/archive/805a158b2b44b015f7966b03cd9def489984be8f.tar.gz";
      sha256 = "167y9znfirvbhk5dr0a96v7zmgr1bg3nphgmjarr7fdabdgvimjl";
    };
    meta = with lib; {
      description = "Heirline.nvim is a no-nonsense Neovim Statusline plugin designed around recursive inheritance to be exceptionally fast and versatile";
      homepage = "https://github.com/rebelot/heirline.nvim";
      license = with licenses; [ mit ];
    };
  };
  telekasten-nvim = buildVimPluginFrom2Nix {
    pname = "telekasten-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/renerocksai/telekasten.nvim/archive/74ff3a9e64d6117e14be911712d87016e953cb1b.tar.gz";
      sha256 = "0vbanwpwj7xlx6hfpcc65zp58z1l738gdnf5b0wn1q6caqhlfsav";
    };
    meta = with lib; {
      description = "A Neovim (lua) plugin for working with a markdown zettelkasten / wiki and mixing it with a journal, based on telescope.nvim";
      homepage = "https://github.com/renerocksai/telekasten.nvim";
      license = with licenses; [ mit ];
    };
  };
  other-nvim = buildVimPluginFrom2Nix {
    pname = "other-nvim";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/rgroli/other.nvim/archive/08e1be94b5c0bb7a0f040466018a5a13cf318477.tar.gz";
      sha256 = "118hk3b2g3njp88byxhkyw8i9gz9q9wypgdlqrvdcpw2ilgkmd4w";
    };
    meta = with lib; {
      description = "Open alternative files for the current buffer";
      homepage = "https://github.com/rgroli/other.nvim";
      license = with licenses; [ mit ];
    };
  };
  vim-gfm-syntax = buildVimPluginFrom2Nix {
    pname = "vim-gfm-syntax";
    version = "2021-10-04";
    src = fetchurl {
      url = "https://github.com/rhysd/vim-gfm-syntax/archive/7bb14638147377a92a0e12912af27877247c6d8c.tar.gz";
      sha256 = "05hrc8cnq6yr98aqdvd5ijysvp5c3navycxsyrn43c59yg4y1j01";
    };
    meta = with lib; {
      description = "GitHub Flavored Markdown syntax highlight extension for Vim";
      homepage = "https://github.com/rhysd/vim-gfm-syntax";
      license = with licenses; [ mit ];
    };
  };
  highlight-current-n-nvim = buildVimPluginFrom2Nix {
    pname = "highlight-current-n-nvim";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/rktjmp/highlight-current-n.nvim/archive/114b295477e961fae3d66c270470d6eefe8de1e9.tar.gz";
      sha256 = "1g8sar85nhqm68v3gxv58qcghmbfc1b3c6mpsk82cf1y7l1fdjms";
    };
    meta = with lib; {
      description = "Highlights the current /, ? or * match under your cursor when pressing n or N and gets out of the way afterwards";
      homepage = "https://github.com/rktjmp/highlight-current-n.nvim";
      license = with licenses; [ mit ];
    };
  };
  hotpot-nvim = buildVimPluginFrom2Nix {
    pname = "hotpot-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/rktjmp/hotpot.nvim/archive/b942e8760ea26f6ff3782f675a8d6c1323f3e7d4.tar.gz";
      sha256 = "0dpywd1plv6n367nyll7vzfkyah6k7j25jamkwhff15pl9pjqmir";
    };
    meta = with lib; {
      description = ":stew: Carl Weathers #1 Neovim Plugin";
      homepage = "https://github.com/rktjmp/hotpot.nvim";
      license = with licenses; [ mit ];
    };
  };
  lush-nvim = buildVimPluginFrom2Nix {
    pname = "lush-nvim";
    version = "2022-07-13";
    src = fetchurl {
      url = "https://github.com/rktjmp/lush.nvim/archive/3df0790319b0985d04e2f09fe879b6c2b15692f2.tar.gz";
      sha256 = "0ad2x3aaw4jwv77xr7sf308r64p701flm2ki76ikfq2rp53mbm1a";
    };
    meta = with lib; {
      description = "Create Neovim themes with real-time feedback, export anywhere";
      homepage = "https://github.com/rktjmp/lush.nvim";
      license = with licenses; [ mit ];
    };
  };
  paperplanes-nvim = buildVimPluginFrom2Nix {
    pname = "paperplanes-nvim";
    version = "2022-05-13";
    src = fetchurl {
      url = "https://github.com/rktjmp/paperplanes.nvim/archive/c23a1c4caab0fa8fd60478ed27668f4b99c1ca85.tar.gz";
      sha256 = "1fq651kfl8vz3j82780phjrrzi8qs086q8q0g28mwla1157701n3";
    };
    meta = with lib; {
      description = "Neovim :airplane: Pastebins";
      homepage = "https://github.com/rktjmp/paperplanes.nvim";
      license = with licenses; [ mit ];
    };
  };
  pounce-nvim = buildVimPluginFrom2Nix {
    pname = "pounce-nvim";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/rlane/pounce.nvim/archive/c2aeae37a3109315fb1c6e9c492bca805e480dc3.tar.gz";
      sha256 = "0m40i8fymp649i8k1ylmyhvxk3sj29dbxczlk3z1k3im5dvz0szx";
    };
    meta = with lib; {
      description = "Incremental fuzzy search motion plugin for Neovim";
      homepage = "https://github.com/rlane/pounce.nvim";
    };
  };
  auto-session = buildVimPluginFrom2Nix {
    pname = "auto-session";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/rmagatti/auto-session/archive/50f5f2eaa7ff825c7036dc3c9981ebae7584b48e.tar.gz";
      sha256 = "0q445zw133zqn84qp814xww099nvp1f7m927d7y3k61j6272p9mb";
    };
    meta = with lib; {
      description = "A small automated session manager for Neovim";
      homepage = "https://github.com/rmagatti/auto-session";
      license = with licenses; [ mit ];
    };
  };
  goto-preview = buildVimPluginFrom2Nix {
    pname = "goto-preview";
    version = "2022-07-19";
    src = fetchurl {
      url = "https://github.com/rmagatti/goto-preview/archive/a5af27cff485b325f0ef2dcdf55ae51faed05cba.tar.gz";
      sha256 = "1jcz8z4aakbr8cwalmd6z9cwbac9c2b108ighpjmkkawigsgrf22";
    };
    meta = with lib; {
      description = "A small Neovim plugin for previewing definitions using floating windows";
      homepage = "https://github.com/rmagatti/goto-preview";
      license = with licenses; [ asl20 ];
    };
  };
  onenord-nvim = buildVimPluginFrom2Nix {
    pname = "onenord-nvim";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/rmehri01/onenord.nvim/archive/c2021ba34aecd8027437dadd27edf9fc949c9aa8.tar.gz";
      sha256 = "14ay746xh3njcyvnssx9k3xylxm96kv90c8l3jpdfb4i9rmc2mqw";
    };
    meta = with lib; {
      description = "🏔️ A Neovim theme that combines the Nord and Atom One Dark color palettes for a more vibrant programming experience";
      homepage = "https://github.com/rmehri01/onenord.nvim";
      license = with licenses; [ mit ];
    };
  };
  boo-colorscheme-nvim = buildVimPluginFrom2Nix {
    pname = "boo-colorscheme-nvim";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/rockerBOO/boo-colorscheme-nvim/archive/c9347034a077e241c36265ca3ae1f99acb66b99b.tar.gz";
      sha256 = "1k6drrlj3nkq4a9l7j5zypda3148mxmdka5vlbmb2h56h4c97gmh";
    };
    meta = with lib; {
      description = "Boo is a colorscheme for Neovim with handcrafted support for LSP, Treesitter";
      homepage = "https://github.com/rockerBOO/boo-colorscheme-nvim";
      license = with licenses; [ mit ];
    };
  };
  arctic-nvim = buildVimPluginFrom2Nix {
    pname = "arctic-nvim";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/rockyzhang24/arctic.nvim/archive/852a99b9bac1a75e179603732daf3030da8ff5dd.tar.gz";
      sha256 = "0d4x4yjirbqgmlyaxsdjw9anjb9d3dx6bnhgmhrvhwadd29r29mr";
    };
    meta = with lib; {
      description = "Neovim color scheme ported from VSCode Dark+";
      homepage = "https://github.com/rockyzhang24/arctic.nvim";
      license = with licenses; [ mit ];
    };
  };
  coc-tailwind-intellisense = buildVimPluginFrom2Nix {
    pname = "coc-tailwind-intellisense";
    version = "2021-09-07";
    src = fetchurl {
      url = "https://github.com/rodrigore/coc-tailwind-intellisense/archive/129fbd9dc33f6f7d3daa5e1e0b98dc4352f30290.tar.gz";
      sha256 = "1l1zyvxvg5qmr29h1sl1divy6m0m4s7a18rhx8fxn8wdqx7y35wx";
    };
    meta = with lib; {
      description = "Coc.nvim extension for Tailwind CSS IntelliSense ";
      homepage = "https://github.com/rodrigore/coc-tailwind-intellisense";
    };
  };
  barbar-nvim = buildVimPluginFrom2Nix {
    pname = "barbar-nvim";
    version = "2022-07-24";
    src = fetchurl {
      url = "https://github.com/romgrk/barbar.nvim/archive/4a19df133df71b51e82302db06b31570d7dedd58.tar.gz";
      sha256 = "0xyj21ma75l8p3f258s560my6x5khi63l7c5bg42n5hkxxkaxv8c";
    };
    meta = with lib; {
      description = "The neovim tabline plugin";
      homepage = "https://github.com/romgrk/barbar.nvim";
    };
  };
  rose-pine = buildVimPluginFrom2Nix {
    pname = "rose-pine";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/rose-pine/neovim/archive/9aff7f7602614f4f0046db639f07cf2bed4c321a.tar.gz";
      sha256 = "1vwfl450wsashm4kk33k9qx1f4ili18gmz6vn7wc1gywm37ydv7s";
    };
    meta = with lib; {
      description = "Soho vibes for Neovim";
      homepage = "https://github.com/rose-pine/neovim";
    };
  };
  gitlinker-nvim = buildVimPluginFrom2Nix {
    pname = "gitlinker-nvim";
    version = "2022-06-28";
    src = fetchurl {
      url = "https://github.com/ruifm/gitlinker.nvim/archive/782e98dd1f8f2c97186b13b5c59a472b585a4504.tar.gz";
      sha256 = "0a7c7mc7059rpx50xadvljjgr758lrd3wciswx9m4rmpxykx3vqi";
    };
    meta = with lib; {
      description = "A lua neovim plugin to generate shareable file permalinks (with line ranges) for several git web frontend hosts. Inspired by tpope/vim-fugitive's :GBrowse";
      homepage = "https://github.com/ruifm/gitlinker.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-comment-frame = buildVimPluginFrom2Nix {
    pname = "nvim-comment-frame";
    version = "2022-07-08";
    src = fetchurl {
      url = "https://github.com/s1n7ax/nvim-comment-frame/archive/2e1f9242c493237c088e0796f0163cef6fc097bc.tar.gz";
      sha256 = "085wcc2cb9m2pvw82vsyv97b8nc68cykfhvx1c5cw33g5h3zxqvh";
    };
    meta = with lib; {
      description = "Detects the language using treesitter and adds a comment block";
      homepage = "https://github.com/s1n7ax/nvim-comment-frame";
      license = with licenses; [ mit ];
    };
  };
  nvim-terminal = buildVimPluginFrom2Nix {
    pname = "nvim-terminal";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/s1n7ax/nvim-terminal/archive/e058de4b8029d7605b17275f30f83be8f8df5f62.tar.gz";
      sha256 = "03pf0hzf5d06z3bysjpzid69jihx770344kkc3qw2pi8w560rrlf";
    };
    meta = with lib; {
      description = "A Lua-Neovim plugin that toggles a terminal";
      homepage = "https://github.com/s1n7ax/nvim-terminal";
      license = with licenses; [ mit ];
    };
  };
  sort-nvim = buildVimPluginFrom2Nix {
    pname = "sort-nvim";
    version = "2022-07-08";
    src = fetchurl {
      url = "https://github.com/sQVe/sort.nvim/archive/9e4065625317128f6a1c826f4a36f9b47600417a.tar.gz";
      sha256 = "0drwk8vqx215s1n8bml0g6zf5x1qr4z7rnas3fvi2m6zidk5i2v9";
    };
    meta = with lib; {
      description = "Sorting plugin for Neovim that supports line-wise and delimiter sorting";
      homepage = "https://github.com/sQVe/sort.nvim";
      license = with licenses; [ mit ];
    };
  };
  cmp-luasnip = buildVimPluginFrom2Nix {
    pname = "cmp-luasnip";
    version = "2022-05-01";
    src = fetchurl {
      url = "https://github.com/saadparwaiz1/cmp_luasnip/archive/a9de941bcbda508d0a45d28ae366bb3f08db2e36.tar.gz";
      sha256 = "1ssajyinwnafjfs4mswfavcf0gyvdlk4hak43rn9bfh37jvw83br";
    };
    meta = with lib; {
      description = "luasnip completion source for nvim-cmp";
      homepage = "https://github.com/saadparwaiz1/cmp_luasnip";
      license = with licenses; [ asl20 ];
    };
  };
  chartoggle-nvim = buildVimPluginFrom2Nix {
    pname = "chartoggle-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/saifulapm/chartoggle.nvim/archive/e96641c7ee7972033f832b7f4af78d9ed04b130f.tar.gz";
      sha256 = "1x2a7m2j1l3i14lmr05967a6c4xvnami93nvlpd9aw58hxwdmlsx";
    };
    meta = with lib; {
      description = "Toggle character in Neovim";
      homepage = "https://github.com/saifulapm/chartoggle.nvim";
      license = with licenses; [ mit ];
    };
  };
  edge = buildVimPluginFrom2Nix {
    pname = "edge";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/sainnhe/edge/archive/33dbe6b7ac23f8666d36ad27db7f82ff58cb2408.tar.gz";
      sha256 = "1mvzd4cjqjisv8pfr9ffgv43jpr7v4a1gwka6yhfcgv5rhqx7i2p";
    };
    meta = with lib; {
      description = "Clean & Elegant Color Scheme inspired by Atom One and Material";
      homepage = "https://github.com/sainnhe/edge";
      license = with licenses; [ mit ];
    };
  };
  everforest = buildVimPluginFrom2Nix {
    pname = "everforest";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/sainnhe/everforest/archive/9a8b4f85a7f1bb0e3019911f2c425b994cedb18f.tar.gz";
      sha256 = "1s5pyv6wxn5ahv9rys2cm57pnj18wycbf31kpb1rxs06i66l9wk0";
    };
    meta = with lib; {
      description = "🌲 Comfortable & Pleasant Color Scheme for Vim";
      homepage = "https://github.com/sainnhe/everforest";
      license = with licenses; [ mit ];
    };
  };
  gruvbox-material = buildVimPluginFrom2Nix {
    pname = "gruvbox-material";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/sainnhe/gruvbox-material/archive/d60d97144193502e1ba19aa6a5f90284ed418f95.tar.gz";
      sha256 = "1kfh1gis1b15zyhnjfnpi9r8niv5fkx72j9726b296p63hcvsv8d";
    };
    meta = with lib; {
      description = "Gruvbox with Material Palette";
      homepage = "https://github.com/sainnhe/gruvbox-material";
      license = with licenses; [ mit ];
    };
  };
  sonokai = buildVimPluginFrom2Nix {
    pname = "sonokai";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/sainnhe/sonokai/archive/888b68bed34a18be8f3341713ccd69b549951d95.tar.gz";
      sha256 = "1ddv9rkgab02s7171d7yazr2vv5cxccvy1zy5pqyym5ssg5gdys0";
    };
    meta = with lib; {
      description = "High Contrast & Vivid Color Scheme based on Monokai Pro";
      homepage = "https://github.com/sainnhe/sonokai";
      license = with licenses; [ mit ];
    };
  };
  nvim-gdb = buildVimPluginFrom2Nix {
    pname = "nvim-gdb";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/sakhnik/nvim-gdb/archive/4408d2c10618636101945e9cd9ef9d68fc335e19.tar.gz";
      sha256 = "08viyccry58mmybb0ppnixvh43n95rg5p337xrskrhq822zvn7dz";
    };
    meta = with lib; {
      description = "Neovim thin wrapper for GDB, LLDB, PDB/PDB++ and BashDB";
      homepage = "https://github.com/sakhnik/nvim-gdb";
    };
  };
  melange = buildVimPluginFrom2Nix {
    pname = "melange";
    version = "2022-06-13";
    src = fetchurl {
      url = "https://github.com/savq/melange/archive/78af754ad22828ea3558e2990326b8aa39730918.tar.gz";
      sha256 = "09fzxiiwq4ncjx4adnmyp88lhnyxy4x2jrgslvw2mn2qk5v3vp82";
    };
    meta = with lib; {
      description = "🗡️ Warm colorscheme for Neovim and beyond";
      homepage = "https://github.com/savq/melange";
      license = with licenses; [ mit ];
    };
  };
  paq-nvim = buildVimPluginFrom2Nix {
    pname = "paq-nvim";
    version = "2022-06-09";
    src = fetchurl {
      url = "https://github.com/savq/paq-nvim/archive/b3c7d047e29792f306626bf87430a2b0c92e5aad.tar.gz";
      sha256 = "101m8mmhz0wvf8ph1fn24ws3nalxqsscm5xpinwvil5ahv82rid3";
    };
    meta = with lib; {
      description = "🌚  Neovim package manager";
      homepage = "https://github.com/savq/paq-nvim";
      license = with licenses; [ mit ];
    };
  };
  neoformat = buildVimPluginFrom2Nix {
    pname = "neoformat";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/sbdchd/neoformat/archive/892be036fa82871f602f20a5245dfd4bc88d2f08.tar.gz";
      sha256 = "019laa6yscj1bmr20xlm9zy5a03fwhz30rwf3fgcxzkncyv17d7x";
    };
    meta = with lib; {
      description = ":sparkles: A (Neo)vim plugin for formatting code";
      homepage = "https://github.com/sbdchd/neoformat";
      license = with licenses; [ bsd2 ];
    };
  };
  nvim-metals = buildVimPluginFrom2Nix {
    pname = "nvim-metals";
    version = "2022-07-18";
    src = fetchurl {
      url = "https://github.com/scalameta/nvim-metals/archive/e6cd8ff487b0140863e683b2ea4cf7f0c14bc504.tar.gz";
      sha256 = "0z1vjimbnbhm4inj4lf52xk3cmhdg4mcca850bhdrznifl8yqy7i";
    };
    meta = with lib; {
      description = "A Metals plugin for Neovim";
      homepage = "https://github.com/scalameta/nvim-metals";
      license = with licenses; [ asl20 ];
    };
  };
  killersheep-nvim = buildVimPluginFrom2Nix {
    pname = "killersheep-nvim";
    version = "2022-05-11";
    src = fetchurl {
      url = "https://github.com/seandewar/killersheep.nvim/archive/506823c47b854df02e78d5fec9468ab0e542dcf5.tar.gz";
      sha256 = "19n45z3vic1w96xs8f1sgpbpc2m62rcy79zhqfac13pdlfzs7fi7";
    };
    meta = with lib; {
      description = "Neovim port of killersheep (with blood!)";
      homepage = "https://github.com/seandewar/killersheep.nvim";
    };
  };
  nvimesweeper = buildVimPluginFrom2Nix {
    pname = "nvimesweeper";
    version = "2022-04-26";
    src = fetchurl {
      url = "https://github.com/seandewar/nvimesweeper/archive/b40a5714340d54e4ea8374e8831304a090340ccb.tar.gz";
      sha256 = "0q25ix44d9ap0l6ls9y6v3hhg5n5554ng3bphw8hjvsg06kjxw2h";
    };
    meta = with lib; {
      description = "Play Minesweeper in your favourite text editor (Neovim 0.7+)";
      homepage = "https://github.com/seandewar/nvimesweeper";
      license = with licenses; [ mit ];
    };
  };
  vim-textobj-parameter = buildVimPluginFrom2Nix {
    pname = "vim-textobj-parameter";
    version = "2017-05-16";
    src = fetchurl {
      url = "https://github.com/sgur/vim-textobj-parameter/archive/201144f19a1a7081033b3cf2b088916dd0bcb98c.tar.gz";
      sha256 = "1l1b1gz1ckbl5c68ri1gnlkyyc3dqr65m3hlgdplhmy1lyzf8p0v";
    };
    meta = with lib; {
      description = "A fork of textobj-parameter 0.1.0";
      homepage = "https://github.com/sgur/vim-textobj-parameter";
    };
  };
  Abstract-cs = buildVimPluginFrom2Nix {
    pname = "Abstract-cs";
    version = "2022-02-16";
    src = fetchurl {
      url = "https://github.com/Abstract-IDE/Abstract-cs/archive/04ac9f79651a39deda73987ee43e3e14a5868056.tar.gz";
      sha256 = "0yy0h3610vjfq46ql5vm7q0wx6ckcd3ly42gsh7l87nawc2fsx0x";
    };
    meta = with lib; {
      description = "Colorscheme for (neo)vim written in lua, specially made for roshnivim with Tree-sitter support";
      homepage = "https://github.com/Abstract-IDE/Abstract-cs";
    };
  };
  nord-nvim = buildVimPluginFrom2Nix {
    pname = "nord-nvim";
    version = "2022-07-18";
    src = fetchurl {
      url = "https://github.com/shaunsingh/nord.nvim/archive/baf9ab55a8b8a75325ed8a9673e60e4d8fef6092.tar.gz";
      sha256 = "09ii1n73mshgxd0yzlrahfgi393vpcg36mih7dhdgd5c31dsffc1";
    };
    meta = with lib; {
      description = "Neovim theme based off of the Nord Color Palette, written in lua with tree sitter support";
      homepage = "https://github.com/shaunsingh/nord.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  rust-tools-nvim = buildVimPluginFrom2Nix {
    pname = "rust-tools-nvim";
    version = "2022-05-18";
    src = fetchurl {
      url = "https://github.com/simrat39/rust-tools.nvim/archive/11dcd674781ba68a951ab4c7b740553cae8fe671.tar.gz";
      sha256 = "0vp6qzms3qw4hb7fmrc7bj1cc1zcwixdcqqjahk62bvbv9dwxcb1";
    };
    meta = with lib; {
      description = "Tools for better development in rust using neovim's builtin lsp";
      homepage = "https://github.com/simrat39/rust-tools.nvim";
      license = with licenses; [ mit ];
    };
  };
  symbols-outline-nvim = buildVimPluginFrom2Nix {
    pname = "symbols-outline-nvim";
    version = "2022-05-01";
    src = fetchurl {
      url = "https://github.com/simrat39/symbols-outline.nvim/archive/15ae99c27360ab42e931be127d130611375307d5.tar.gz";
      sha256 = "0gqvh36ixwci0dfsj8gxqd18vs7xvi5rzdhxlv3x9kndvizs4blc";
    };
    meta = with lib; {
      description = "A tree like view for symbols in Neovim using the Language Server Protocol. Supports all your favourite languages";
      homepage = "https://github.com/simrat39/symbols-outline.nvim";
      license = with licenses; [ mit ];
    };
  };
  diffview-nvim = buildVimPluginFrom2Nix {
    pname = "diffview-nvim";
    version = "2022-07-20";
    src = fetchurl {
      url = "https://github.com/sindrets/diffview.nvim/archive/a45163cb9ee65742cf26b940c2b24cc652f295c9.tar.gz";
      sha256 = "0qx5rhrnnmfsqy1zzlm5q04q1mddmvpbwi24zhr5dh27dkbvzk74";
    };
    meta = with lib; {
      description = "Single tabpage interface for easily cycling through diffs for all modified files for any git rev";
      homepage = "https://github.com/sindrets/diffview.nvim";
    };
  };
  winshift-nvim = buildVimPluginFrom2Nix {
    pname = "winshift-nvim";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/sindrets/winshift.nvim/archive/9e884748f2857c4ba05e5ee9521dd9a576e22083.tar.gz";
      sha256 = "0dpp0ximjhvlgafphpa16nj4figzkgqyqa07wqks0cjrbri7r8jc";
    };
    meta = with lib; {
      description = "Rearrange your windows with ease";
      homepage = "https://github.com/sindrets/winshift.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-numbertoggle = buildVimPluginFrom2Nix {
    pname = "nvim-numbertoggle";
    version = "2022-07-06";
    src = fetchurl {
      url = "https://github.com/sitiom/nvim-numbertoggle/archive/8a6bdd34f40073d8bb813ea4eb2d68eb8366ca2a.tar.gz";
      sha256 = "1c5jnv4n7726rf98c0k0is5rbnzgjxp8p73sb35dsiw5hpprwzm1";
    };
    meta = with lib; {
      description = "Neovim plugin to automatically toggle between relative and absolute line numbers. Written in Lua";
      homepage = "https://github.com/sitiom/nvim-numbertoggle";
      license = with licenses; [ mit ];
    };
  };
  christmas-vim = buildVimPluginFrom2Nix {
    pname = "christmas-vim";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/skanehira/christmas.vim/archive/f243b269787a8b638777fd48d3f392a4d6da8beb.tar.gz";
      sha256 = "0jnpcamc1yx2bwm05s55m397mnhhxj9j8ck2rzphlcqza3g31fz4";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/skanehira/christmas.vim";
    };
  };
  unruly-worker = buildVimPluginFrom2Nix {
    pname = "unruly-worker";
    version = "2022-03-22";
    src = fetchurl {
      url = "https://github.com/slugbyte/unruly-worker/archive/6046d8fedf84ee6cb344d4e248a74b4586cb6e14.tar.gz";
      sha256 = "1pcab6n484a28rk9h8dxg7xiq6rl5ml21j3wpqan8m38y420asld";
    };
    meta = with lib; {
      description = "A ridiculously fun alternative nvim keymap for the workman keyboard layout";
      homepage = "https://github.com/slugbyte/unruly-worker";
      license = with licenses; [ unlicense ];
    };
  };
  inc-rename-nvim = buildVimPluginFrom2Nix {
    pname = "inc-rename-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/smjonas/inc-rename.nvim/archive/25ec4c8ca5b4a3f5cfaaad9e91c27e385d801067.tar.gz";
      sha256 = "1wf60iiywxqf7nfmxqlzds65f8jxjfi258zdlfx59lssyzr1zdi8";
    };
    meta = with lib; {
      description = "Incremental LSP renaming based on Neovim's command-preview feature";
      homepage = "https://github.com/smjonas/inc-rename.nvim";
      license = with licenses; [ mit ];
    };
  };
  snippet-converter-nvim = buildVimPluginFrom2Nix {
    pname = "snippet-converter-nvim";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/smjonas/snippet-converter.nvim/archive/0f4c3b319684e00cd34a544ec70ccfb336a26111.tar.gz";
      sha256 = "0pdh1pw1mb2qrig29ziqbzb6nxn645sdh2gn143n1n6zjg1bwraa";
    };
    meta = with lib; {
      description = "Bundle snippets from multiple sources and convert them to your format of choice";
      homepage = "https://github.com/smjonas/snippet-converter.nvim";
      license = with licenses; [ mpl20 ];
    };
  };
  yaml-companion-nvim = buildVimPluginFrom2Nix {
    pname = "yaml-companion-nvim";
    version = "2022-06-25";
    src = fetchurl {
      url = "https://github.com/someone-stole-my-name/yaml-companion.nvim/archive/ab42ea608dfb8e82adb506cc90f85786efa37923.tar.gz";
      sha256 = "0d7sxd51zr5lwyz99zy75zszmhvwcnis10dsph6cg31m78cc12fi";
    };
    meta = with lib; {
      description = "Get, set and autodetect YAML schemas in your buffers";
      homepage = "https://github.com/someone-stole-my-name/yaml-companion.nvim";
      license = with licenses; [ mit ];
    };
  };
  startup-nvim = buildVimPluginFrom2Nix {
    pname = "startup-nvim";
    version = "2022-03-28";
    src = fetchurl {
      url = "https://github.com/startup-nvim/startup.nvim/archive/00bede05e89d9d11bf5e1e848f3d67a0fe7552a7.tar.gz";
      sha256 = "1lhlq3xpwl9h2ai8cfjn2js50hipksnz6vk4z20m4sryq9glkq28";
    };
    meta = with lib; {
      description = "A highly configurable neovim startup screen";
      homepage = "https://github.com/startup-nvim/startup.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  aerial-nvim = buildVimPluginFrom2Nix {
    pname = "aerial-nvim";
    version = "2022-07-25";
    src = fetchurl {
      url = "https://github.com/stevearc/aerial.nvim/archive/86b8341bb8c58ece7e7f3f9b2d0310f4a328ab21.tar.gz";
      sha256 = "10b7wgi5l8csz8wgp09vbmxmywxxx72ycddillbny20pnh1a4sbk";
    };
    meta = with lib; {
      description = "Neovim plugin for a code outline window";
      homepage = "https://github.com/stevearc/aerial.nvim";
      license = with licenses; [ mit ];
    };
  };
  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim";
    version = "2022-07-21";
    src = fetchurl {
      url = "https://github.com/stevearc/dressing.nvim/archive/e9d0de44707fe5ce06be6f6959d33a3fab985a3c.tar.gz";
      sha256 = "184cp3kky9idd6ycw8kic0kim6dxfzc23q883hnnv1h4g5askv4w";
    };
    meta = with lib; {
      description = "Neovim plugin to improve the default vim.ui interfaces";
      homepage = "https://github.com/stevearc/dressing.nvim";
      license = with licenses; [ mit ];
    };
  };
  gkeep-nvim = buildVimPluginFrom2Nix {
    pname = "gkeep-nvim";
    version = "2022-06-02";
    src = fetchurl {
      url = "https://github.com/stevearc/gkeep.nvim/archive/8b441b30c67c88aca9a4be9332c8b1fbe188376c.tar.gz";
      sha256 = "0pcwwqdvm8s54h0xwk2w2q83l81a3jyqm6qyyvy2hm7hji1rb26p";
    };
    meta = with lib; {
      description = "Google Keep integration for Neovim";
      homepage = "https://github.com/stevearc/gkeep.nvim";
      license = with licenses; [ mit ];
    };
  };
  overseer-nvim = buildVimPluginFrom2Nix {
    pname = "overseer-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/stevearc/overseer.nvim/archive/a9e5041ee87c8807ca884cb72afe243141ece6e6.tar.gz";
      sha256 = "0hxrmd2icy9w0q59hgm05x6vh9h6ld2m88h2iqj8vvc5w96nc767";
    };
    meta = with lib; {
      description = "A task runner and job management plugin for Neovim";
      homepage = "https://github.com/stevearc/overseer.nvim";
      license = with licenses; [ mit ];
    };
  };
  qf-helper-nvim = buildVimPluginFrom2Nix {
    pname = "qf-helper-nvim";
    version = "2022-01-28";
    src = fetchurl {
      url = "https://github.com/stevearc/qf_helper.nvim/archive/84ca8af5f272a5c0e3ca30e287a0b9219e23a774.tar.gz";
      sha256 = "0mpk12cggraf5b20s19h43vfs9schxdh5lpayirmlb8my6f05axv";
    };
    meta = with lib; {
      description = "A collection of improvements for the quickfix buffer";
      homepage = "https://github.com/stevearc/qf_helper.nvim";
      license = with licenses; [ mit ];
    };
  };
  cheatsheet-nvim = buildVimPluginFrom2Nix {
    pname = "cheatsheet-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/sudormrfbin/cheatsheet.nvim/archive/9716f9aaa94dd1fd6ce59b5aae0e5f25e2a463ef.tar.gz";
      sha256 = "1wqmfa6fi9dwcn4a4gy8w2ychhhqy8b506l2g6nvbyxzmrqxaq4c";
    };
    meta = with lib; {
      description = "A cheatsheet plugin for neovim with bundled cheatsheets for the editor, multiple vim plugins, nerd-fonts, regex, etc. with a Telescope fuzzy finder interface !";
      homepage = "https://github.com/sudormrfbin/cheatsheet.nvim";
    };
  };
  Shade-nvim = buildVimPluginFrom2Nix {
    pname = "Shade-nvim";
    version = "2022-02-01";
    src = fetchurl {
      url = "https://github.com/sunjon/Shade.nvim/archive/4286b5abc47d62d0c9ffb22a4f388b7bf2ac2461.tar.gz";
      sha256 = "1cjy35ayw0hxppyd11d2psdw1ks2kjr1f3pdg7bvvpd0rlp3fivp";
    };
    meta = with lib; {
      description = "An Nvim lua plugin that dims your inactive windows";
      homepage = "https://github.com/sunjon/Shade.nvim";
      license = with licenses; [ mit ];
    };
  };
  vim-yoink = buildVimPluginFrom2Nix {
    pname = "vim-yoink";
    version = "2021-09-15";
    src = fetchurl {
      url = "https://github.com/svermeulen/vim-yoink/archive/89ed6934679fdbc3c20f552b50b1f869f624cd22.tar.gz";
      sha256 = "1j46bd3kjmxmd2vd1dfvpy8wi694bs0khd43ji0qspgns9f0a20z";
    };
    meta = with lib; {
      description = "Vim plugin that maintains a yank history to cycle between when pasting";
      homepage = "https://github.com/svermeulen/vim-yoink";
      license = with licenses; [ mit ];
    };
  };
  vimpeccable = buildVimPluginFrom2Nix {
    pname = "vimpeccable";
    version = "2021-12-28";
    src = fetchurl {
      url = "https://github.com/svermeulen/vimpeccable/archive/bd19b2a86a3d4a0ee184412aa3edb7ed57025d56.tar.gz";
      sha256 = "0wgv655syxiqq1b4qbls2x6zgjj131q9plhd4sqy7shjybrmfl7h";
    };
    meta = with lib; {
      description = "Neovim plugin that allows you to easily map keys directly to lua code inside your init.lua";
      homepage = "https://github.com/svermeulen/vimpeccable";
      license = with licenses; [ mit ];
    };
  };
  lir-nvim = buildVimPluginFrom2Nix {
    pname = "lir-nvim";
    version = "2022-05-17";
    src = fetchurl {
      url = "https://github.com/tamago324/lir.nvim/archive/41b57761d118ab919d265ad2983a696ca1081562.tar.gz";
      sha256 = "17dq8fx6af913jc02hfr25rlrg56zp0d00wjb1cgz6phf3r01j5k";
    };
    meta = with lib; {
      description = "Neovim file explorer";
      homepage = "https://github.com/tamago324/lir.nvim";
      license = with licenses; [ mit ];
    };
  };
  nlsp-settings-nvim = buildVimPluginFrom2Nix {
    pname = "nlsp-settings-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/tamago324/nlsp-settings.nvim/archive/e99da980d421b75b5a5f52150b2330bdf337522f.tar.gz";
      sha256 = "04vk4vns7npgc5k7c11gsdikzaqhrs2nkywrn8nd2bl9i177k4dv";
    };
    meta = with lib; {
      description = "A plugin for setting Neovim LSP with JSON or YAML files";
      homepage = "https://github.com/tamago324/nlsp-settings.nvim";
      license = with licenses; [ mit ];
    };
  };
  staline-nvim = buildVimPluginFrom2Nix {
    pname = "staline-nvim";
    version = "2022-06-17";
    src = fetchurl {
      url = "https://github.com/tamton-aquib/staline.nvim/archive/846f067d3ee001f5934350b25afae6c9b1ef4d1e.tar.gz";
      sha256 = "04pgml9yyhh90cqh20f0p8nc3lnvf5kp490ly17h3w35qbc4lwv8";
    };
    meta = with lib; {
      description = "A modern lightweight statusline and bufferline plugin for neovim in lua. Mainly uses unicode symbols for showing info";
      homepage = "https://github.com/tamton-aquib/staline.nvim";
      license = with licenses; [ mit ];
    };
  };
  monokai-nvim = buildVimPluginFrom2Nix {
    pname = "monokai-nvim";
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/tanvirtin/monokai.nvim/archive/4fc970efcbbdcd614733eb8c68d3b8bf8bddec3e.tar.gz";
      sha256 = "1ppwj02i3p3y9z24f917p609lx7c59xmf2aykdhw7csq7gyc2m5x";
    };
    meta = with lib; {
      description = "Monokai theme for Neovim written in Lua";
      homepage = "https://github.com/tanvirtin/monokai.nvim";
      license = with licenses; [ mit ];
    };
  };
  vgit-nvim = buildVimPluginFrom2Nix {
    pname = "vgit-nvim";
    version = "2022-05-29";
    src = fetchurl {
      url = "https://github.com/tanvirtin/vgit.nvim/archive/ee9081c304b44509b2f4267f1f7addc303f9fb9b.tar.gz";
      sha256 = "1246gw73i00ax5wy1wcmy24j9404rvf9zbf8z96b0mxaaci03h39";
    };
    meta = with lib; {
      description = "Visual git plugin for Neovim";
      homepage = "https://github.com/tanvirtin/vgit.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-comment = buildVimPluginFrom2Nix {
    pname = "nvim-comment";
    version = "2022-03-15";
    src = fetchurl {
      url = "https://github.com/terrortylor/nvim-comment/archive/861921706a39144ea528a6200a059a549b02d8f0.tar.gz";
      sha256 = "108f5gsbi83ypg6qn6amgmxnk4f8gsy25rah17gyr1b1myk1k6ir";
    };
    meta = with lib; {
      description = "A comment toggler for Neovim, written in Lua";
      homepage = "https://github.com/terrortylor/nvim-comment";
      license = with licenses; [ mit ];
    };
  };
  vim-workspace = buildVimPluginFrom2Nix {
    pname = "vim-workspace";
    version = "2021-11-25";
    src = fetchurl {
      url = "https://github.com/thaerkh/vim-workspace/archive/c26b473f9b073f24bacecd38477f44c5cd1f5a62.tar.gz";
      sha256 = "073j8fprmrx5qvssqkmc7l9660y77cplbvf826nyjxvr03vhay4i";
    };
    meta = with lib; {
      description = "📑 Automated Vim session management with file auto-save and persistent undo history";
      homepage = "https://github.com/thaerkh/vim-workspace";
      license = with licenses; [ asl20 ];
    };
  };
  tailwindcss-colors-nvim = buildVimPluginFrom2Nix {
    pname = "tailwindcss-colors-nvim";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/themaxmarchuk/tailwindcss-colors.nvim/archive/ccb5be2f84673c1a0ef90a0c0a76733e85e5265b.tar.gz";
      sha256 = "0f109vnqbd364x5zrgbr3v9mxl9b5qn5vf8p7kw0mlkr92rina8g";
    };
    meta = with lib; {
      description = "Highlights Tailwind CSS class names when @tailwindcss/language-server is connected";
      homepage = "https://github.com/themaxmarchuk/tailwindcss-colors.nvim";
      license = with licenses; [ mit ];
    };
  };
  themer-lua = buildVimPluginFrom2Nix {
    pname = "themer-lua";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/ThemerCorp/themer.lua/archive/a3d16aa7f478088545466991cf1d89cf26066382.tar.gz";
      sha256 = "0kx9b76v9w96gisswhiqmv7c47chglazcgnj3qqr2xkxp3gs69p4";
    };
    meta = with lib; {
      description = "A simple, minimal highlighter plugin for neovim";
      homepage = "https://github.com/ThemerCorp/themer.lua";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-deus = buildVimPluginFrom2Nix {
    pname = "nvim-deus";
    version = "2021-08-26";
    src = fetchurl {
      url = "https://github.com/theniceboy/nvim-deus/archive/6baf3218d71bb52920887cb8f08c734ab94fe42f.tar.gz";
      sha256 = "1ypy9dp7j6g8148bcikwxxwaarw0pwa9adn743z6lv4672wbimqs";
    };
    meta = with lib; {
      description = "vim-deus with treesitter support";
      homepage = "https://github.com/theniceboy/nvim-deus";
    };
  };
  tokyodark-nvim = buildVimPluginFrom2Nix {
    pname = "tokyodark-nvim";
    version = "2022-04-25";
    src = fetchurl {
      url = "https://github.com/tiagovla/tokyodark.nvim/archive/e505c2bf88ef0e3fcb2c46195baacd0fcbe79d6f.tar.gz";
      sha256 = "0s7g86iar22iy12i2yhqp0wnm6irqv1q1ng3kb9pg4mdlq02hxqd";
    };
    meta = with lib; {
      description = "A clean dark theme written in lua for neovim";
      homepage = "https://github.com/tiagovla/tokyodark.nvim";
    };
  };
  zephyrium = buildVimPluginFrom2Nix {
    pname = "zephyrium";
    version = "2022-02-20";
    src = fetchurl {
      url = "https://github.com/titanzero/zephyrium/archive/c8f6c4b803c22aad7302be37a7bda3380f6e8e9c.tar.gz";
      sha256 = "1gdf3mp029fbglaaw9a3z763yxwawwpwdcwjlzmda5gficw6ig6z";
    };
    meta = with lib; {
      description = "A dark color scheme for Vim, based on Zephyr, written in Lua";
      homepage = "https://github.com/titanzero/zephyrium";
      license = with licenses; [ mit ];
    };
  };
  astronauta-nvim = buildVimPluginFrom2Nix {
    pname = "astronauta-nvim";
    version = "2021-11-09";
    src = fetchurl {
      url = "https://github.com/tjdevries/astronauta.nvim/archive/edc19d30a3c51a8c3fc3f606008e5b4238821f1e.tar.gz";
      sha256 = "061lqiy6l5sbcgdipr2g6mxa4br703kp0q2pb78ldrf5kikbhif5";
    };
    meta = with lib; {
      description = "You now feel at home traveling to the moon";
      homepage = "https://github.com/tjdevries/astronauta.nvim";
      license = with licenses; [ mit ];
    };
  };
  colorbuddy-nvim = buildVimPluginFrom2Nix {
    pname = "colorbuddy-nvim";
    version = "2022-02-28";
    src = fetchurl {
      url = "https://github.com/tjdevries/colorbuddy.nvim/archive/cdb5b0654d3cafe61d2a845e15b2b4b0e78e752a.tar.gz";
      sha256 = "1vxkgfh27rdpl2vbnw3hh8v9y5byhm8c52d8xdvkiwnrg6xdaq4v";
    };
    meta = with lib; {
      description = "Your color buddy for making cool neovim color schemes";
      homepage = "https://github.com/tjdevries/colorbuddy.nvim";
      license = with licenses; [ mit ];
    };
  };
  express-line-nvim = buildVimPluginFrom2Nix {
    pname = "express-line-nvim";
    version = "2021-12-01";
    src = fetchurl {
      url = "https://github.com/tjdevries/express_line.nvim/archive/30f04edb9647d9ea7c08d0bdbfad33faf5bcda57.tar.gz";
      sha256 = "0s9a4if9sr6rdhdkpg447j2r4r0mcq4gs7jsh5qg8jhdw2sxdpng";
    };
    meta = with lib; {
      description = "WIP: Statusline written in pure lua. Supports co-routines, functions and jobs";
      homepage = "https://github.com/tjdevries/express_line.nvim";
      license = with licenses; [ mit ];
    };
  };
  gruvbuddy-nvim = buildVimPluginFrom2Nix {
    pname = "gruvbuddy-nvim";
    version = "2021-04-15";
    src = fetchurl {
      url = "https://github.com/tjdevries/gruvbuddy.nvim/archive/52bdae82517d7767dbd287141b9aabceeab0f9a5.tar.gz";
      sha256 = "0vlsj2sbl1cgzz087b2v7ybf1hhq1vkdwd6v9iiyijvcdvgxx966";
    };
    meta = with lib; {
      description = "Gruvbox colors using https://github.com/tjdevries/colorbuddy.vim";
      homepage = "https://github.com/tjdevries/gruvbuddy.nvim";
      license = with licenses; [ mit ];
    };
  };
  nlua-nvim = buildVimPluginFrom2Nix {
    pname = "nlua-nvim";
    version = "2021-12-14";
    src = fetchurl {
      url = "https://github.com/tjdevries/nlua.nvim/archive/3603ee35ed928acd961847aeac30c92a3a048997.tar.gz";
      sha256 = "0j9fp3hf7rbalhi5xmhj1cyv475yzhdy0mfnpb9x52a9mw60hsj3";
    };
    meta = with lib; {
      description = "Lua Development for Neovim";
      homepage = "https://github.com/tjdevries/nlua.nvim";
      license = with licenses; [ mit ];
    };
  };
  train-nvim = buildVimPluginFrom2Nix {
    pname = "train-nvim";
    version = "2020-09-10";
    src = fetchurl {
      url = "https://github.com/tjdevries/train.nvim/archive/7b2e9a59af58385d88bf39c5311c08f839e2b1ce.tar.gz";
      sha256 = "0kcgp8f9szydnb60060x41fkzfd3bvnwigvjc1rjh315jh1cbq9n";
    };
    meta = with lib; {
      description = "Train yourself with vim motions and make your own train tracks :)";
      homepage = "https://github.com/tjdevries/train.nvim";
      license = with licenses; [ mit ];
    };
  };
  vlog-nvim = buildVimPluginFrom2Nix {
    pname = "vlog-nvim";
    version = "2020-08-04";
    src = fetchurl {
      url = "https://github.com/tjdevries/vlog.nvim/archive/300e43f1628935aa9fec0560f3c7c483b3d38db2.tar.gz";
      sha256 = "15wvc90hs006l3yh93p1c7dc0zqqcgywdrcch4gy7sxbzc1hplw1";
    };
    meta = with lib; {
      description = "Single file, no dependency, easy copy & paste log file to add to your neovim lua plugins";
      homepage = "https://github.com/tjdevries/vlog.nvim";
      license = with licenses; [ mit ];
    };
  };
  vim-code-dark = buildVimPluginFrom2Nix {
    pname = "vim-code-dark";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/tomasiser/vim-code-dark/archive/08eea24ec8c9a713e53ec47b7dd2c1d5a2dd7027.tar.gz";
      sha256 = "0pd2canc29c0a3wzps4cg6qvgalgl7lcas9kz97vxvmqdg2rdniy";
    };
    meta = with lib; {
      description = "Dark color scheme for Vim and vim-airline, inspired by Dark+ in Visual Studio Code";
      homepage = "https://github.com/tomasiser/vim-code-dark";
      license = with licenses; [ mit ];
    };
  };
  reach-nvim = buildVimPluginFrom2Nix {
    pname = "reach-nvim";
    version = "2022-06-14";
    src = fetchurl {
      url = "https://github.com/toppair/reach.nvim/archive/50d91d2fedc714357d1171dd6aa35f9ca3414aef.tar.gz";
      sha256 = "1n1h89l2sxdv8j4wvfa5nc45cqi0b599dclic17lf561ihs4bc9n";
    };
    meta = with lib; {
      description = "Buffer, mark, tabpage, colorscheme switcher for Neovim";
      homepage = "https://github.com/toppair/reach.nvim";
      license = with licenses; [ mit ];
    };
  };
  registers-nvim = buildVimPluginFrom2Nix {
    pname = "registers-nvim";
    version = "2022-05-19";
    src = fetchurl {
      url = "https://github.com/tversteeg/registers.nvim/archive/f354159d34bc17553ad772c633fd7caff8ecb35c.tar.gz";
      sha256 = "08rrkhi7r5q7r0a9vab5r91lnshd4xd8nry4l8g18gqjzb3xq11m";
    };
    meta = with lib; {
      description = "📑 Neovim plugin to preview the contents of the registers";
      homepage = "https://github.com/tversteeg/registers.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-blame-line = buildVimPluginFrom2Nix {
    pname = "nvim-blame-line";
    version = "2022-05-04";
    src = fetchurl {
      url = "https://github.com/tveskag/nvim-blame-line/archive/b3d94f0ed5882d3d1c843c69788b9670476e1f42.tar.gz";
      sha256 = "11ysrhkfswi4vwwynk37xianjgi83g83clqglsm35lql9lf8qnqh";
    };
    meta = with lib; {
      description = "A small plugin that uses neovims virtual text to print git blame info at the end of the current line";
      homepage = "https://github.com/tveskag/nvim-blame-line";
      license = with licenses; [ mit ];
    };
  };
  cmp-fuzzy-buffer = buildVimPluginFrom2Nix {
    pname = "cmp-fuzzy-buffer";
    version = "2022-07-07";
    src = fetchurl {
      url = "https://github.com/tzachar/cmp-fuzzy-buffer/archive/a939269ccaa251374a6543d90f304a234304cd3d.tar.gz";
      sha256 = "06fj0rfi5g7d4zsikffym7pn9xnd5gayhbhh3nivkdamy6x38whw";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/tzachar/cmp-fuzzy-buffer";
      license = with licenses; [ mit ];
    };
  };
  cmp-fuzzy-path = buildVimPluginFrom2Nix {
    pname = "cmp-fuzzy-path";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/tzachar/cmp-fuzzy-path/archive/b4a8c1bebfe5a5d45b36e0b09e72f9f082e9a40c.tar.gz";
      sha256 = "076cb3b5yjcb3d6khk5wrl6iffip7gqm3m7nrl5wmaihvf5qavdp";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/tzachar/cmp-fuzzy-path";
    };
  };
  cmp-tabnine = buildVimPluginFrom2Nix {
    pname = "cmp-tabnine";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/tzachar/cmp-tabnine/archive/bfc45c962a4e8da957e9972d4f4ddeda92580db0.tar.gz";
      sha256 = "07qcj8jnqamld0iwb2lissn577gb9ayrzczjxjyqi8iahf7gvnbm";
    };
    meta = with lib; {
      description = "TabNine plugin for hrsh7th/nvim-cmp";
      homepage = "https://github.com/tzachar/cmp-tabnine";
      license = with licenses; [ mit ];
    };
  };
  hibiscus-nvim = buildVimPluginFrom2Nix {
    pname = "hibiscus-nvim";
    version = "2022-06-03";
    src = fetchurl {
      url = "https://github.com/udayvir-singh/hibiscus.nvim/archive/f47c7521309f6a553257fa791ed8a6a2a6fdb262.tar.gz";
      sha256 = "19p9bhk7xfkq43r1ymw97bg2h45n3nxpwhcwr1shsjm12rjc2pq2";
    };
    meta = with lib; {
      description = ":hibiscus: Flavored Fennel Macros for Neovim";
      homepage = "https://github.com/udayvir-singh/hibiscus.nvim";
      license = with licenses; [ mit ];
    };
  };
  tangerine-nvim = buildVimPluginFrom2Nix {
    pname = "tangerine-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/udayvir-singh/tangerine.nvim/archive/00c2a4631da9d14ee6df282d8703ccfb0ce97283.tar.gz";
      sha256 = "0ld6pn7l9yqysc0c6b6wji2zi192zmdf5g2qcp2amyxpilnl04vx";
    };
    meta = with lib; {
      description = "🍊 Sweet Fennel integration for Neovim";
      homepage = "https://github.com/udayvir-singh/tangerine.nvim";
      license = with licenses; [ mit ];
    };
  };
  complementree-nvim = buildVimPluginFrom2Nix {
    pname = "complementree-nvim";
    version = "2022-07-05";
    src = fetchurl {
      url = "https://github.com/vigoux/complementree.nvim/archive/a8392e758f6c99042232d63b0d76cbd7eb2b0dd3.tar.gz";
      sha256 = "02jy54q6c111jqdfm8jns5xcmybhalrd8vi6zxd421dhbp6wmkfg";
    };
    meta = with lib; {
      description = "Tree-sitter powered syntax-aware completion framework";
      homepage = "https://github.com/vigoux/complementree.nvim";
      license = with licenses; [ bsd3 ];
    };
  };
  nvim-fzf = buildVimPluginFrom2Nix {
    pname = "nvim-fzf";
    version = "2022-07-12";
    src = fetchurl {
      url = "https://github.com/vijaymarupudi/nvim-fzf/archive/a8dc4bae4c1e1552e0233df796e512ab9ca65e44.tar.gz";
      sha256 = "142fp7rrw6ijp1clrxkm6p8whzw4pmpgzf3bmbs2wrgq3y7b2zqk";
    };
    meta = with lib; {
      description = "A Lua API for using fzf in neovim";
      homepage = "https://github.com/vijaymarupudi/nvim-fzf";
      license = with licenses; [ agpl3Only ];
    };
  };
  package-info-nvim = buildVimPluginFrom2Nix {
    pname = "package-info-nvim";
    version = "2022-06-17";
    src = fetchurl {
      url = "https://github.com/vuki656/package-info.nvim/archive/45e409c69063a057250833a747e52e2ff00dd722.tar.gz";
      sha256 = "0sd0yhjd1jyj8qhidsg2imf3g0rlhcr93gh5xfzsv9dbspwds3fi";
    };
    meta = with lib; {
      description = "✍️ All the npm/yarn commands I don't want to type";
      homepage = "https://github.com/vuki656/package-info.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  packer-nvim = buildVimPluginFrom2Nix {
    pname = "packer-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/wbthomason/packer.nvim/archive/de109156cfa634ce0256ea4b6a7c32f9186e2f10.tar.gz";
      sha256 = "0xly0vdqg54lpy5n67d67axsj87rd9v8xnmz3fgphfjg423z0rcb";
    };
    meta = with lib; {
      description = "A use-package inspired plugin manager for Neovim. Uses native packages, supports Luarocks dependencies, written in Lua, allows for expressive config";
      homepage = "https://github.com/wbthomason/packer.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-code-action-menu = buildVimPluginFrom2Nix {
    pname = "nvim-code-action-menu";
    version = "2022-05-29";
    src = fetchurl {
      url = "https://github.com/weilbith/nvim-code-action-menu/archive/ee599409ed6ab31f6d7115e9c5c4550336470c14.tar.gz";
      sha256 = "0kbpqwm1jwp143gnlf7k7wbg03cz5qcnr340isf5i9ki5nn8a5h7";
    };
    meta = with lib; {
      description = "Pop-up menu for code actions to show meta-information and diff preview";
      homepage = "https://github.com/weilbith/nvim-code-action-menu";
      license = with licenses; [ mit ];
    };
  };
  mason-nvim = buildVimPluginFrom2Nix {
    pname = "mason-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/williamboman/mason.nvim/archive/cfd789cc3d6198aa0abe03088de981774b52a9b6.tar.gz";
      sha256 = "054dp2cwybn9gp04bd05zvzjvi4myl3s9qlm9vyn9rqbzchd33p1";
    };
    meta = with lib; {
      description = "Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters";
      homepage = "https://github.com/williamboman/mason.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  nvim-lsp-installer = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-installer";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/williamboman/nvim-lsp-installer/archive/ff51c2173d2917517c96f22d9c21940307930b57.tar.gz";
      sha256 = "00x16clg7hfk8v77z9s87007wbwqbmsavnfy6sy2bkiva9avvxhz";
    };
    meta = with lib; {
      description = "Neovim plugin that allow you to seamlessly manage LSP servers with :LspInstall. With full Windows support! Further development has moved to https://github.com/williamboman/mason.nvim!";
      homepage = "https://github.com/williamboman/nvim-lsp-installer";
      license = with licenses; [ asl20 ];
    };
  };
  nvim-autopairs = buildVimPluginFrom2Nix {
    pname = "nvim-autopairs";
    version = "2022-07-06";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-autopairs/archive/972a7977e759733dd6721af7bcda7a67e40c010e.tar.gz";
      sha256 = "029a4myq9zq5c390vhh885igv7rx9rgd26rdp61m9h5n770aivm8";
    };
    meta = with lib; {
      description = "autopairs for neovim written by lua";
      homepage = "https://github.com/windwp/nvim-autopairs";
      license = with licenses; [ mit ];
    };
  };
  nvim-projectconfig = buildVimPluginFrom2Nix {
    pname = "nvim-projectconfig";
    version = "2021-11-10";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-projectconfig/archive/05fd34831e170db269d1b84597615bcdcdde930e.tar.gz";
      sha256 = "1xfh4vd01n1khnxiz6ywpbzj6nf5mkqxvr93f5brz2s90pnw3527";
    };
    meta = with lib; {
      description = "neovim projectconfig";
      homepage = "https://github.com/windwp/nvim-projectconfig";
      license = with licenses; [ mit ];
    };
  };
  nvim-spectre = buildVimPluginFrom2Nix {
    pname = "nvim-spectre";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/nvim-pack/nvim-spectre/archive/b1a084c05bf6cf32a3b55196e5cde44bb94422fb.tar.gz";
      sha256 = "0wzpd180lrrx093xzjysyfg5l3b47dsmajdcpqnyc3bfhm0624x9";
    };
    meta = with lib; {
      description = "Find the enemy and replace them with dark power";
      homepage = "https://github.com/nvim-pack/nvim-spectre";
      license = with licenses; [ mit ];
    };
  };
  windline-nvim = buildVimPluginFrom2Nix {
    pname = "windline-nvim";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/windwp/windline.nvim/archive/0872eb09a635ca1a13b5812159f6e96d896321fc.tar.gz";
      sha256 = "1sydm606lxz225w5qacrpbdfhgxp0pcih2kiryscs0dkzwrrg94j";
    };
    meta = with lib; {
      description = "Animation statusline, floating window statusline. Use lua + luv make some wind";
      homepage = "https://github.com/windwp/windline.nvim";
      license = with licenses; [ mit ];
    };
  };
  commented-nvim = buildVimPluginFrom2Nix {
    pname = "commented-nvim";
    version = "2022-03-12";
    src = fetchurl {
      url = "https://github.com/winston0410/commented.nvim/archive/be322c5ef455800984705cee97490a5450f072bc.tar.gz";
      sha256 = "15jg3z7iqxbrjayzxjjbl5539aqilhsdhz1pl1lgiwffh8asbx3s";
    };
    meta = with lib; {
      description = "Neovim commenting plugin in Lua. Support operator, motions and more than 60 languages! :fire:";
      homepage = "https://github.com/winston0410/commented.nvim";
      license = with licenses; [ mit ];
    };
  };
  range-highlight-nvim = buildVimPluginFrom2Nix {
    pname = "range-highlight-nvim";
    version = "2021-08-03";
    src = fetchurl {
      url = "https://github.com/winston0410/range-highlight.nvim/archive/8b5e8ccb3460b2c3675f4639b9f54e64eaab36d9.tar.gz";
      sha256 = "172i70j6czabd23np3x32gpsdz4z3fdm5bw3inbc3f1sfy1834lw";
    };
    meta = with lib; {
      description = "An extremely lightweight plugin (~ 120loc) that hightlights ranges you have entered in commandline";
      homepage = "https://github.com/winston0410/range-highlight.nvim";
      license = with licenses; [ mit ];
    };
  };
  competitest-nvim = buildVimPluginFrom2Nix {
    pname = "competitest-nvim";
    version = "2022-06-17";
    src = fetchurl {
      url = "https://github.com/xeluxee/competitest.nvim/archive/aa3bbfbd4432ef28f026148c99961811562c77ef.tar.gz";
      sha256 = "0zrc8j6j1b0bfbjq09r56a3vx55kq942p8nway6dfahblbr9q6sh";
    };
    meta = with lib; {
      description = "CompetiTest.nvim is a Neovim plugin to automate testcases management and checking for Competitive Programming";
      homepage = "https://github.com/xeluxee/competitest.nvim";
    };
  };
  link-visitor-nvim = buildVimPluginFrom2Nix {
    pname = "link-visitor-nvim";
    version = "2022-07-02";
    src = fetchurl {
      url = "https://github.com/xiyaowong/link-visitor.nvim/archive/d2e9c85d23ba9fe0dd74ad9d7c3071d739beaaa9.tar.gz";
      sha256 = "1sn3rjw363j8p42y0w48bcpx563jqwmkafx3r2m54rbwdyb3snl5";
    };
    meta = with lib; {
      description = "Let me help you open the links!";
      homepage = "https://github.com/xiyaowong/link-visitor.nvim";
    };
  };
  nvim-cursorword = buildVimPluginFrom2Nix {
    pname = "nvim-cursorword";
    version = "2022-06-22";
    src = fetchurl {
      url = "https://github.com/xiyaowong/nvim-cursorword/archive/c0f2958ec729b47be2dba0d79ef43d005dac9f4e.tar.gz";
      sha256 = "05crhganvhi0ldnaxf2ixx8jmazv0im35rr72y6b7b1216iqwxsj";
    };
    meta = with lib; {
      description = "highlight the word under the cursor";
      homepage = "https://github.com/xiyaowong/nvim-cursorword";
    };
  };
  nvim-transparent = buildVimPluginFrom2Nix {
    pname = "nvim-transparent";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/xiyaowong/nvim-transparent/archive/1a3d7d3b7670fecbbfddd3fc999ddea5862ac3c2.tar.gz";
      sha256 = "1z38816wvx3908fcaln90ca8x33qv4f4yhglgway2rnchbipprrl";
    };
    meta = with lib; {
      description = "Remove all background colors to make nvim transparent";
      homepage = "https://github.com/xiyaowong/nvim-transparent";
    };
  };
  virtcolumn-nvim = buildVimPluginFrom2Nix {
    pname = "virtcolumn-nvim";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/xiyaowong/virtcolumn.nvim/archive/5a24869fab079aaf587b71e0e66f0e421e1de3c7.tar.gz";
      sha256 = "0ki0y5262b86asrm7c9sa6g21rjhd4wjrv2rgvb2f0i5ajgz8rhn";
    };
    meta = with lib; {
      description = "Display a line as the colorcolumn";
      homepage = "https://github.com/xiyaowong/virtcolumn.nvim";
    };
  };
  nvim-cursorline = buildVimPluginFrom2Nix {
    pname = "nvim-cursorline";
    version = "2022-04-15";
    src = fetchurl {
      url = "https://github.com/yamatsum/nvim-cursorline/archive/804f0023692653b2b2368462d67d2a87056947f9.tar.gz";
      sha256 = "1a2yvnwvf1hd3g36ci6ndbi84p17mvknrn2zs82rd8wl0m2j2vbk";
    };
    meta = with lib; {
      description = "A plugin for neovim that highlights cursor words and lines";
      homepage = "https://github.com/yamatsum/nvim-cursorline";
      license = with licenses; [ mit ];
    };
  };
  nvim-nonicons = buildVimPluginFrom2Nix {
    pname = "nvim-nonicons";
    version = "2021-12-06";
    src = fetchurl {
      url = "https://github.com/yamatsum/nvim-nonicons/archive/cdb104f58c46a62ff9f484f49f8660d46db6326f.tar.gz";
      sha256 = "12y7r2b0nns192vmdmr7xvagplrnpqkdxpn18fj08gwb45qr14hj";
    };
    meta = with lib; {
      description = "Icon set using nonicons for neovim plugins and settings";
      homepage = "https://github.com/yamatsum/nvim-nonicons";
    };
  };
  calvera-dark-nvim = buildVimPluginFrom2Nix {
    pname = "calvera-dark-nvim";
    version = "2021-08-13";
    src = fetchurl {
      url = "https://github.com/yashguptaz/calvera-dark.nvim/archive/84802d0bde047ce79ebfddc1800800f0bd67f37a.tar.gz";
      sha256 = "0pjaz7bhn5lcv8qmpzhg35h0ml4867lcnkqfrw4xn0402khsjgca";
    };
    meta = with lib; {
      description = "Calvera Dark Colorscheme for Neovim written in Lua with built-in support for native LSP, TreeSitter and many more plugins";
      homepage = "https://github.com/yashguptaz/calvera-dark.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  minimal-nvim = buildVimPluginFrom2Nix {
    pname = "minimal-nvim";
    version = "2022-07-26";
    src = fetchurl {
      url = "https://github.com/Yazeed1s/minimal.nvim/archive/758a907e30520766d2d36bce3f967e0b87c7d9e5.tar.gz";
      sha256 = "1l0nadj2z68xj49d7k2idp4q9pmbjrypdkjl1fl5vvh1a0x9pi3i";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/Yazeed1s/minimal.nvim";
    };
  };
  omni-vim = buildVimPluginFrom2Nix {
    pname = "omni-vim";
    version = "2022-06-17";
    src = fetchurl {
      url = "https://github.com/yonlu/omni.vim/archive/6c0f3015b1d6f2ae59c12cc380c629b965d3dc62.tar.gz";
      sha256 = "1g6vbis3nanzj1v7sz7f7x1kqcsjn5jj7aic3h0s8j7c4sx2p75s";
    };
    meta = with lib; {
      description = "🎨 Omni color scheme for Neovim";
      homepage = "https://github.com/yonlu/omni.vim";
    };
  };
  nvim-pqf = buildVimPluginFrom2Nix {
    pname = "nvim-pqf";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://gitlab.com/api/v4/projects/yorickpeterse%2Fnvim-pqf/repository/archive.tar.gz?sha=1bf0758e2ce4c8930941d76fca23da37f4b7a4bc";
      sha256 = "1iw8r4r8cqcr9n3jxjxjsx0z5mvb8wpvn40h3x1b3wdf9spxazbx";
    };
    meta = with lib; {
      description = "Prettier quickfix/location list windows for NeoVim";
      homepage = "https://gitlab.com/yorickpeterse/nvim-pqf";
    };
  };
  nvim-window = buildVimPluginFrom2Nix {
    pname = "nvim-window";
    version = "2022-03-23";
    src = fetchurl {
      url = "https://gitlab.com/api/v4/projects/yorickpeterse%2Fnvim-window/repository/archive.tar.gz?sha=dd0a6b230003ef35524853d71e5413f88fd2ba74";
      sha256 = "0q745ynvk6pmv5ndi8hykwm09mc9z9ib52dipa3fsz3jmi4gmm7m";
    };
    meta = with lib; {
      description = "Easily jump between NeoVim windows";
      homepage = "https://gitlab.com/yorickpeterse/nvim-window";
    };
  };
  copilot-cmp = buildVimPluginFrom2Nix {
    pname = "copilot-cmp";
    version = "2022-07-22";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot-cmp/archive/dc42702b6a0777d6e75aabf6dad5d72111514dcb.tar.gz";
      sha256 = "09nplsi60zqnb94md734m6mi09rwjb99b4gavhlb0dmvjw36yga9";
    };
    meta = with lib; {
      description = "Lua plugin to turn github copilot into a cmp source";
      homepage = "https://github.com/zbirenbaum/copilot-cmp";
    };
  };
  color-picker-nvim = buildVimPluginFrom2Nix {
    pname = "color-picker-nvim";
    version = "2022-07-04";
    src = fetchurl {
      url = "https://github.com/ziontee113/color-picker.nvim/archive/c253206980696e258f508f4e5b000b0391a1d01d.tar.gz";
      sha256 = "15wsdhyzfv0a4rjyh4qw67hybd6wf66s9cpwbc2cfa72pzmcm99s";
    };
    meta = with lib; {
      description = "A powerful Neovim plugin that lets users choose & modify RGB/HSL/HEX colors. ";
      homepage = "https://github.com/ziontee113/color-picker.nvim";
      license = with licenses; [ mit ];
    };
  };
  icon-picker-nvim = buildVimPluginFrom2Nix {
    pname = "icon-picker-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/ziontee113/icon-picker.nvim/archive/fddd49e084d67ed9b98e4c56b1a2afe6bf58f236.tar.gz";
      sha256 = "0zsq8qv0kjhwzm802klma1sp9mx8wqg67ab53rs86a7zydm3apmx";
    };
    meta = with lib; {
      description = "This is a Neovim plugin that helps you pick Nerd Font Icons, Symbols & Emojis";
      homepage = "https://github.com/ziontee113/icon-picker.nvim";
      license = with licenses; [ mit ];
    };
  };
  syntax-tree-surfer = buildVimPluginFrom2Nix {
    pname = "syntax-tree-surfer";
    version = "2022-07-03";
    src = fetchurl {
      url = "https://github.com/ziontee113/syntax-tree-surfer/archive/9d5879ab6f2f4f02ce5bd0777e67b11de2c41b22.tar.gz";
      sha256 = "00y73qd7556hm7bm0pz8nfvxxwyxl034w1b0v1a40mlgz1ga76n6";
    };
    meta = with lib; {
      description = "A plugin for Neovim that helps you surf through your document and move elements around using the nvim-treesitter API";
      homepage = "https://github.com/ziontee113/syntax-tree-surfer";
      license = with licenses; [ mit ];
    };
  };
}
