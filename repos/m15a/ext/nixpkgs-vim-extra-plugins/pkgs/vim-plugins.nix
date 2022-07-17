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
  LuaSnip = buildVimPluginFrom2Nix {
    pname = "LuaSnip";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/45fc3d860cfa7a074b4d2fbf68c0249aa3a01320.tar.gz";
      sha256 = "135plnyb9j00zp1qpr9j4wpbcknpg3gic7a25x1r5mvda74221w8";
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
  tidy-nvim = buildVimPluginFrom2Nix {
    pname = "tidy-nvim";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/mcauley-penney/tidy.nvim/archive/889dc71f200f76e3b115fd3af92671f0d669acbe.tar.gz";
      sha256 = "1l1ys4rgm01nc1k34n4pgq6vbvaixgzasiif3ycfqck8130n8wjh";
    };
    meta = with lib; {
      description = "A small Neovim plugin to remove trailing whitespace and empty lines at end of file on every save";
      homepage = "https://github.com/mcauley-penney/tidy.nvim";
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
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/Mofiqul/vscode.nvim/archive/22d3ed7d5ad0e57ceed9fa0b779c424ffcbc5bde.tar.gz";
      sha256 = "0p8wa2jmldsww9j7bpcf2p0n4gcmgyqj51cxblvbmikzi9fc54qm";
    };
    meta = with lib; {
      description = "Neovim/Vim color scheme inspired by Dark+ and Light+ theme in Visual Studio Code";
      homepage = "https://github.com/Mofiqul/vscode.nvim";
      license = with licenses; [ mit ];
    };
  };
  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/nui.nvim/archive/60931a72524ae7681c15bedcc92d69a0826af293.tar.gz";
      sha256 = "0mfzl1q1jz57ryaa23y58q0fcy3hw1rfcabs93885ywz6sq8l9x0";
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
  themer-lua = buildVimPluginFrom2Nix {
    pname = "themer-lua";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/ThemerCorp/themer.lua/archive/6e8290cb2196e20670161030a45a4cd8e114ef0e.tar.gz";
      sha256 = "01n78vqdc39q5q6amv6xmjy202z4611bm5x0ykkp1y0gwnz7ybyx";
    };
    meta = with lib; {
      description = "A simple, minimal highlighter plugin for neovim";
      homepage = "https://github.com/ThemerCorp/themer.lua";
      license = with licenses; [ gpl3Only ];
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
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/akinsho/flutter-tools.nvim/archive/eac3d0c29f070e0fe89d9f50ce4e4a78a8ec8c0b.tar.gz";
      sha256 = "1hhpzbrziwyl00fn07cd48f0b84y38a4k617h3l23c887067n82l";
    };
    meta = with lib; {
      description = "Tools to help create flutter apps in neovim using the native lsp";
      homepage = "https://github.com/akinsho/flutter-tools.nvim";
      license = with licenses; [ mit ];
    };
  };
  toggleterm-nvim = buildVimPluginFrom2Nix {
    pname = "toggleterm-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/akinsho/toggleterm.nvim/archive/3f9d383f1f89eb5a1558ee612061eccaca385680.tar.gz";
      sha256 = "1rnay2gihy3acvqlw9ipykwkgl14c37p4y4ck5yagsx72y4ff6bl";
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
  pretty-fold-nvim = buildVimPluginFrom2Nix {
    pname = "pretty-fold-nvim";
    version = "2022-06-29";
    src = fetchurl {
      url = "https://github.com/anuvyklack/pretty-fold.nvim/archive/af4afff523fc1daee33bee32d6786c90d8bcc121.tar.gz";
      sha256 = "13w8r4gn6hph9plhvlnrgnl5jjkk7b6maxr4v94w7m6xrrc4z9fw";
    };
    meta = with lib; {
      description = "Foldtext customization and folded region preview in Neovim";
      homepage = "https://github.com/anuvyklack/pretty-fold.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  tmux-nvim = buildVimPluginFrom2Nix {
    pname = "tmux-nvim";
    version = "2022-06-14";
    src = fetchurl {
      url = "https://github.com/aserowy/tmux.nvim/archive/7b19060fccfbd1791ae17ec2372e0bc836f9d519.tar.gz";
      sha256 = "1srnfqac2hjzis6xgz1hkzx7z8qckhkraa4xh2dic4xl7g11gh8l";
    };
    meta = with lib; {
      description = "tmux integration for nvim features pane movement and resizing from within nvim";
      homepage = "https://github.com/aserowy/tmux.nvim";
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
  focus-nvim = buildVimPluginFrom2Nix {
    pname = "focus-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/beauwilliams/focus.nvim/archive/542871bc710249d51709ed9c808a165c42e16e9d.tar.gz";
      sha256 = "01ryd3yx3nzhbcg9blp12jhrbkx17gbbzh7qzpii6q59yndm9f83";
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
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-moonfly-colors/archive/9dde1bfb48eaed94de610b9128b8e5bc5d103641.tar.gz";
      sha256 = "052cpaihddv6ilf6ghl2c756wlqqmad49scsx3r1ndwb5ap895hs";
    };
    meta = with lib; {
      description = "A dark color scheme for Vim & Neovim";
      homepage = "https://github.com/bluz71/vim-moonfly-colors";
      license = with licenses; [ mit ];
    };
  };
  vim-nightfly-guicolors = buildVimPluginFrom2Nix {
    pname = "vim-nightfly-guicolors";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-nightfly-guicolors/archive/1220d5a4cdd47e8951e8e1274b5f79654264f827.tar.gz";
      sha256 = "1ngp9770dp6lxphi6ry6mpm1cc3s9wki4jx1bnwmpwkln7y1n6zm";
    };
    meta = with lib; {
      description = "Another dark color scheme for Vim & Neovim";
      homepage = "https://github.com/bluz71/vim-nightfly-guicolors";
      license = with licenses; [ mit ];
    };
  };
  nvim-gomove = buildVimPluginFrom2Nix {
    pname = "nvim-gomove";
    version = "2022-05-18";
    src = fetchurl {
      url = "https://github.com/booperlv/nvim-gomove/archive/40f05247d1f25725ea205729cb7250bd204a5f00.tar.gz";
      sha256 = "17064lb0wf293dqfixaxwlgzvzx79kvnjpczrrz9zzqqd2526kvn";
    };
    meta = with lib; {
      description = "A complete plugin for moving and duplicating blocks and lines, with complete fold handling, reindenting, and undoing in one go";
      homepage = "https://github.com/booperlv/nvim-gomove";
      license = with licenses; [ mit ];
    };
  };
  catppuccin = buildVimPluginFrom2Nix {
    pname = "catppuccin";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/6abbe9e731a8f4121ce0208d489009c8dd696960.tar.gz";
      sha256 = "0awrrkj9cf8mf8fz9zbwdkjk3gbk665zlby715rqkkjkqfcc0zmj";
    };
    meta = with lib; {
      description = "🍨 Soothing pastel theme for NeoVim";
      homepage = "https://github.com/catppuccin/nvim";
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
  nvim-go = buildVimPluginFrom2Nix {
    pname = "nvim-go";
    version = "2022-07-06";
    src = fetchurl {
      url = "https://github.com/crispgm/nvim-go/archive/4f903f995be01f14b66e8a9004484a167079fc39.tar.gz";
      sha256 = "1nazbpcwcji30zkiini72dw05jwimxcjvw33fpifb82q9jgwd5dn";
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
    version = "2022-06-25";
    src = fetchurl {
      url = "https://github.com/dcampos/nvim-snippy/archive/0eff6e2826d92e4b37be6711a1e5bbc945ec3b9f.tar.gz";
      sha256 = "06dn3qf8k2v33ssx5idvqgywjyvxa31h44mfsjcyhlyjdd8pmdy1";
    };
    meta = with lib; {
      description = "Snippet plugin for Neovim";
      homepage = "https://github.com/dcampos/nvim-snippy";
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
  alpha-nvim = buildVimPluginFrom2Nix {
    pname = "alpha-nvim";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/goolord/alpha-nvim/archive/79187fdf8f2a08a7174f237423198f6e75ae213a.tar.gz";
      sha256 = "0mq4nypqcghr2cj4hm8apdgiz61qdqqxryz4cybnz8b6wp7m0hmi";
    };
    meta = with lib; {
      description = "a lua powered greeter like vim-startify / dashboard-nvim";
      homepage = "https://github.com/goolord/alpha-nvim";
      license = with licenses; [ mit ];
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
  vim-hy = buildVimPluginFrom2Nix {
    pname = "vim-hy";
    version = "2022-03-09";
    src = fetchurl {
      url = "https://github.com/hylang/vim-hy/archive/813ff051dfc73ed225ef71495c2b235f84fbaa1e.tar.gz";
      sha256 = "0r8f4z8y2awx4ad2ai8c7z77l6v3bmin83i1i1p2l3f2jaavspgk";
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
    version = "2022-07-10";
    src = fetchurl {
      url = "https://github.com/ibhagwan/fzf-lua/archive/95c859b4e4d90bd275bc4ba70da6b1e04118cec1.tar.gz";
      sha256 = "059xs4nl2brk6bf9d0alnmk0p6v7hnsgmsasa6nihd7aabif1fph";
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
    version = "2022-05-16";
    src = fetchurl {
      url = "https://github.com/ishan9299/modus-theme-vim/archive/42ee50e89c1869e5bda69fa2cde44e4d72663131.tar.gz";
      sha256 = "10h3qzfnkifbhxsp90a36897m1cqpvl4anlhs40gcwclx212kyz4";
    };
    meta = with lib; {
      description = "Port of modus-themes in neovim";
      homepage = "https://github.com/ishan9299/modus-theme-vim";
      license = with licenses; [ mit ];
    };
  };
  mkdnflow-nvim = buildVimPluginFrom2Nix {
    pname = "mkdnflow-nvim";
    version = "2022-07-09";
    src = fetchurl {
      url = "https://github.com/jakewvincent/mkdnflow.nvim/archive/a59b96c8b7c711ba30e0422689a3e61c0b0bd835.tar.gz";
      sha256 = "146xlhyyqql3s6z6dwh2wg7z1v42kbqzzky021jdx0v2wjkplvla";
    };
    meta = with lib; {
      description = "Tools for markdown notebook navigation and management";
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
    version = "2022-03-12";
    src = fetchurl {
      url = "https://github.com/jghauser/mkdir.nvim/archive/01261650382bef195dab8ac39344234b57914f09.tar.gz";
      sha256 = "1lga32bbjr1xy64ph7i16insv6ldb2060y93afw1vn63k3v3i3lk";
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
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/null-ls.nvim/archive/b95d94fc094d319450a24ad8c980e632b37aa90c.tar.gz";
      sha256 = "12mi1hm7bhwfyhrsyw8xr86kw38z1pmlpbhnsz11gq6cxhw40dar";
    };
    meta = with lib; {
      description = "Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua";
      homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
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
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/kyazdani42/blue-moon/archive/940facddeae7fd9447985a2f5a1c20ed7c0abb25.tar.gz";
      sha256 = "1knqg3mnzrznj1mjjricy9rgz6mkx96pn58m8ixx4k9j2ddh0rg3";
    };
    meta = with lib; {
      description = "A dark color scheme for Neovim derived from palenight and carbonight";
      homepage = "https://github.com/kyazdani42/blue-moon";
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
  github-colors = buildVimPluginFrom2Nix {
    pname = "github-colors";
    version = "2022-07-15";
    src = fetchurl {
      url = "https://github.com/lourenci/github-colors/archive/3b54afaa1cd5dd0924cead863d97617c7ba485ae.tar.gz";
      sha256 = "1z6kggwn356cy4y2drd7siyjndczg56ljshhb94li7gx9aaxgaqa";
    };
    meta = with lib; {
      description = "Yet another GitHub colorscheme";
      homepage = "https://github.com/lourenci/github-colors";
      license = with licenses; [ mit ];
    };
  };
  gruvbox-baby = buildVimPluginFrom2Nix {
    pname = "gruvbox-baby";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/luisiacc/gruvbox-baby/archive/52e1d0f23e4d76440bd5ffac4c951154aef900f2.tar.gz";
      sha256 = "17wjf8xf81ncs4m2ki9802i20a33cq0qy6yp7imb4wwcbd1pxn4q";
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
  nvim-treehopper = buildVimPluginFrom2Nix {
    pname = "nvim-treehopper";
    version = "2021-12-20";
    src = fetchurl {
      url = "https://github.com/mfussenegger/nvim-treehopper/archive/59a589471c85ebf9479089c4ca1638021b9a10e3.tar.gz";
      sha256 = "0ly17pj03jwg0yhzngy7a49vrn9hhbvfm3fj86yjl8bjq4c5z1aa";
    };
    meta = with lib; {
      description = "Region selection with hints on the AST nodes of a document powered by treesitter";
      homepage = "https://github.com/mfussenegger/nvim-treehopper";
      license = with licenses; [ gpl3Only ];
    };
  };
  sniprun = buildVimPluginFrom2Nix {
    pname = "sniprun";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/michaelb/sniprun/archive/54a98058b1830b1b4d48b445a47ec26f35c4cd43.tar.gz";
      sha256 = "1xbyzmjfc4w0pkdy2f7k0y2pngcg6qcwcjwlb8mn21rmlxp28xhj";
    };
    meta = with lib; {
      description = "A neovim plugin to run lines/blocs of code (independently of the rest of the file), supporting multiples languages";
      homepage = "https://github.com/michaelb/sniprun";
      license = with licenses; [ mit ];
    };
  };
  iswap-nvim = buildVimPluginFrom2Nix {
    pname = "iswap-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/mizlan/iswap.nvim/archive/f4a77e1cb9f4f7fac6032d999648219442fce42d.tar.gz";
      sha256 = "1qn4wi4gajai8bj0zp0gk8ggmhh2h9g810wyi98m9fds214gc03h";
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
    version = "2021-12-17";
    src = fetchurl {
      url = "https://github.com/mnacamura/nvim-srcerite/archive/2eadf3c0e8b9b493b3b6af8bebded4706919b33f.tar.gz";
      sha256 = "105dy572r8csj0frqky7w6s1ydj8h250hj9z2zsp51jacazs56fr";
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
  coq-nvim = buildVimPluginFrom2Nix {
    pname = "coq-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/ms-jpq/coq_nvim/archive/309e27d0cdbbfb1eb79e9e95baca2a746a657ca1.tar.gz";
      sha256 = "0fk0sxxwa8403wfbg972bnibpabccrk6n7dkjvqm1v4gc9835gma";
    };
    meta = with lib; {
      description = "Fast as FUCK nvim completion. SQLite, concurrent scheduler, hundreds of hours of optimization";
      homepage = "https://github.com/ms-jpq/coq_nvim";
      license = with licenses; [ gpl3Only ];
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
  cmdbuf-nvim = buildVimPluginFrom2Nix {
    pname = "cmdbuf-nvim";
    version = "2022-05-26";
    src = fetchurl {
      url = "https://github.com/notomo/cmdbuf.nvim/archive/1fd21a235f373e1c1481997d807f244be81b3b81.tar.gz";
      sha256 = "1xz0yfqx6wxbhjrgsdnc98f68d3y3s7m19ldl8s5qqlr5a00y43g";
    };
    meta = with lib; {
      description = "Alternative command-line window plugin for neovim";
      homepage = "https://github.com/notomo/cmdbuf.nvim";
      license = with licenses; [ mit ];
    };
  };
  gesture-nvim = buildVimPluginFrom2Nix {
    pname = "gesture-nvim";
    version = "2022-05-26";
    src = fetchurl {
      url = "https://github.com/notomo/gesture.nvim/archive/75885f1e50a9b8f1d92a2507853fa968506b820c.tar.gz";
      sha256 = "0vpl0hgy002yf2mh1x7nbfvpg6impa7lb05r1a806pwbc0y2hbn0";
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
    version = "2022-07-13";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/7c49fb2ac01a9f03410100c8e78f647bbea857e8.tar.gz";
      sha256 = "0aqrw2j1mj5b80ld0pbrgckdkw4aix872r2jza5yvd0hksj4dn4d";
    };
    meta = with lib; {
      description = ":brain: :muscle: // Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more";
      homepage = "https://github.com/numToStr/Comment.nvim";
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
  cphelper-nvim = buildVimPluginFrom2Nix {
    pname = "cphelper-nvim";
    version = "2022-05-21";
    src = fetchurl {
      url = "https://github.com/p00f/cphelper.nvim/archive/f5df068678ec06f0b93fbc8a4fcec9f117e743a7.tar.gz";
      sha256 = "0qk3mgaph2hqmxg5bhjz1cv8mclvsl0kr3s1wpg0284w7nv95w99";
    };
    meta = with lib; {
      description = "Neovim helper for competitive programming. https://sr.ht/~p00f/cphelper.nvim preferred";
      homepage = "https://github.com/p00f/cphelper.nvim";
      license = with licenses; [ mit ];
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
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/projekt0n/github-nvim-theme/archive/c0473069c1466c37dba53a62c266746cfc1fae1b.tar.gz";
      sha256 = "1cwq79mr2387va9mz7pcbr2sw7mvk8hckfck04slghypgk5qmd3r";
    };
    meta = with lib; {
      description = "Github theme for Neovim and Terminals written in Lua";
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
  go-nvim = buildVimPluginFrom2Nix {
    pname = "go-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/ray-x/go.nvim/archive/f0732425f9450795a1797a7723a85c9b2cb6bf6a.tar.gz";
      sha256 = "1ldlvm9a2g0mym9va55yr4jvi5ick5znfnp6b3inym88a27143l8";
    };
    meta = with lib; {
      description = "Modern Go plugin for Neovim, based on gopls, treesitter AST, Dap and a variety of go tools";
      homepage = "https://github.com/ray-x/go.nvim";
      license = with licenses; [ mit ];
    };
  };
  guihua-lua = buildVimPluginFrom2Nix {
    pname = "guihua-lua";
    version = "2022-07-06";
    src = fetchurl {
      url = "https://github.com/ray-x/guihua.lua/archive/0df98aaca522dd5d52c11cbb443d3ef3d8624dd0.tar.gz";
      sha256 = "0i53yxwcyg4ig7l653c02in72c6mc0ij6x5x503w0wa9rszbdw7b";
    };
    meta = with lib; {
      description = "A GUI library for Neovim plugin developer";
      homepage = "https://github.com/ray-x/guihua.lua";
      license = with licenses; [ mit ];
    };
  };
  navigator-lua = buildVimPluginFrom2Nix {
    pname = "navigator-lua";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/ray-x/navigator.lua/archive/3d9a9582dde291268dbd62757ee8c76b80c54900.tar.gz";
      sha256 = "1kffwf0zsczyjrfvzs7i9ic7iqv2cxz3wf7kg9h389536wf6mpsg";
    };
    meta = with lib; {
      description = "Symbol analysis & navigation plugin for Neovim. Navigate codes like a breeze🎐.  Exploring LSP and 🌲Treesitter symbols a piece of 🍰. Take control like a boss 🦍";
      homepage = "https://github.com/ray-x/navigator.lua";
      license = with licenses; [ mit ];
    };
  };
  telekasten-nvim = buildVimPluginFrom2Nix {
    pname = "telekasten-nvim";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/renerocksai/telekasten.nvim/archive/d7d7c709641dc1cc15734764df3c6b623d05ef73.tar.gz";
      sha256 = "0qprxcd3cxhs1hbacz546jm97rzpwa1bfy3w5w9msa3qvwpliq22";
    };
    meta = with lib; {
      description = "A Neovim (lua) plugin for working with a markdown zettelkasten / wiki and mixing it with a journal, based on telescope.nvim";
      homepage = "https://github.com/renerocksai/telekasten.nvim";
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
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/rktjmp/hotpot.nvim/archive/e88ffce6cdc56f7e3c334c1523a425c593a9f067.tar.gz";
      sha256 = "1ndfqk811fwspcpnnb6r26wla887hjm27ly0sn3ldbc2kp9rn2jb";
    };
    meta = with lib; {
      description = ":stew: Carl Weathers #1 Neovim Plugin";
      homepage = "https://github.com/rktjmp/hotpot.nvim";
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
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/rockerBOO/boo-colorscheme-nvim/archive/9338b9508198d04d6b9d56acf5fd035ea8770bca.tar.gz";
      sha256 = "08z2xcfd2dx2j8x8wpyjc1zq5hf5jqagpg0rj3v2clwdkkgsy52k";
    };
    meta = with lib; {
      description = "Boo is a colorscheme for Neovim with handcrafted support for LSP, Treesitter";
      homepage = "https://github.com/rockerBOO/boo-colorscheme-nvim";
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
  chartoggle-nvim = buildVimPluginFrom2Nix {
    pname = "chartoggle-nvim";
    version = "2021-10-25";
    src = fetchurl {
      url = "https://github.com/saifulapm/chartoggle.nvim/archive/f6edf93041b96f475bace30d3b98a97567e8d5d4.tar.gz";
      sha256 = "02syvqsp1vm0zxsfv0j4ysvi0v956c8vxxw3i2cdq6ck80f64wc8";
    };
    meta = with lib; {
      description = "Toggle character in Neovim";
      homepage = "https://github.com/saifulapm/chartoggle.nvim";
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
  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim";
    version = "2022-07-14";
    src = fetchurl {
      url = "https://github.com/stevearc/dressing.nvim/archive/1e60c07ae9a8557ac6395144606c3a5335ad47e0.tar.gz";
      sha256 = "1b8zkf0217sbs44sacn2l63sgcm20bnhv5726rs0i2dbx55sk1x4";
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
  nlsp-settings-nvim = buildVimPluginFrom2Nix {
    pname = "nlsp-settings-nvim";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/tamago324/nlsp-settings.nvim/archive/30e9199ade7b63b891a7fc15c58d46a1fac09cd5.tar.gz";
      sha256 = "1qxhqbxyhvqr9bg4s8cb2a3ni28nk3jp43h8a8wc7dxz274iqhg5";
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
  neorg = buildVimPluginFrom2Nix {
    pname = "neorg";
    version = "2022-07-16";
    src = fetchurl {
      url = "https://github.com/nvim-neorg/neorg/archive/e5dd1b205fe46154c67b284547d6ba144922bd17.tar.gz";
      sha256 = "1yjvmd3fzc91826sdngqrrkisqwzd5v2dqc0dn5yhbdydfn0rgkn";
    };
    meta = with lib; {
      description = "Modernity meets insane extensibility. The future of organizing your life in Neovim";
      homepage = "https://github.com/nvim-neorg/neorg";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-lsp-installer = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-installer";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/williamboman/nvim-lsp-installer/archive/793f99660fa9212f52ee8b6164454e03ba1f42c9.tar.gz";
      sha256 = "185igvidh8nyvp3fg2yixvc3gpjrln9fx1wlpkr9zbfvknzsbmcs";
    };
    meta = with lib; {
      description = "Neovim plugin that allow you to seamlessly manage LSP servers with :LspInstall. With full Windows support!";
      homepage = "https://github.com/williamboman/nvim-lsp-installer";
      license = with licenses; [ asl20 ];
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
}
