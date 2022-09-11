{ lib, buildVimPluginFrom2Nix, fetchurl, fetchgit }:

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
  nvim-FeMaco-lua = buildVimPluginFrom2Nix {
    pname = "nvim-FeMaco-lua";
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/AckslD/nvim-FeMaco.lua/archive/e94e857d7137d4e792995cb1a08e5c6ae1ae980e.tar.gz";
      sha256 = "09p6c5sdmk46ppb6ivhgv3y02i0cb24dzphmva8x1h80b0klh87q";
    };
    meta = with lib; {
      description = "Catalyze your Fenced Markdown Code-block editing!";
      homepage = "https://github.com/AckslD/nvim-FeMaco.lua";
    };
  };
  nvim-gfold-lua = buildVimPluginFrom2Nix {
    pname = "nvim-gfold-lua";
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/AckslD/nvim-gfold.lua/archive/60614a32c2ec68c803f6f3f2aa81cca172f137b7.tar.gz";
      sha256 = "1xphh4nypy0bjwcxqwpxbkmdy2ndqbbpgcxv4228d6haih8mb9g6";
    };
    meta = with lib; {
      description = "nvim plugin using gfold to switch repo and have statusline component";
      homepage = "https://github.com/AckslD/nvim-gfold.lua";
      license = with licenses; [ mit ];
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
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/CRAG666/code_runner.nvim/archive/7a107a5e641baf00cd9ef82de06ee468dfeac621.tar.gz";
      sha256 = "1f7mrnc2mawpnbj77ic5fcds74px4h2gawhy086zvdbn2mharwph";
    };
    meta = with lib; {
      description = "Neovim plugin.The best code runner you could have, it is like the one in vscode but with super powers, it manages projects like in intellij but without being slow";
      homepage = "https://github.com/CRAG666/code_runner.nvim";
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
  jester = buildVimPluginFrom2Nix {
    pname = "jester";
    version = "2022-08-27";
    src = fetchurl {
      url = "https://github.com/David-Kunz/jester/archive/be6fdd511bce3343117977cab3ca686dd4d4c0d6.tar.gz";
      sha256 = "1765jj5fmaqdaq25jfi4b5g3zplasqf6pkir98vvkmhbhnnc488x";
    };
    meta = with lib; {
      description = "A Neovim plugin to easily run and debug Jest tests";
      homepage = "https://github.com/David-Kunz/jester";
      license = with licenses; [ unlicense ];
    };
  };
  vs-tasks-nvim = buildVimPluginFrom2Nix {
    pname = "vs-tasks-nvim";
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/EthanJWright/vs-tasks.nvim/archive/df644d9c22ca68ecc3153debac5a44681f0845b9.tar.gz";
      sha256 = "0v8c5270s4gwkkcxm1cz9s2jx5hq571g52yynfray4kapqkz0f9s";
    };
    meta = with lib; {
      description = "A telescope plugin that runs tasks similar to VS Code's task implementation";
      homepage = "https://github.com/EthanJWright/vs-tasks.nvim";
    };
  };
  everblush-nvim = buildVimPluginFrom2Nix {
    pname = "everblush-nvim";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/Everblush/everblush.nvim/archive/8341ec1d72018973ca09862e07249195fa1039d3.tar.gz";
      sha256 = "1x3qjfh4had06y1iljvrbms50rv00vxnqpm6389ylr5k05q60kg9";
    };
    meta = with lib; {
      description = "A port of everblush.vim but written in lua";
      homepage = "https://github.com/Everblush/everblush.nvim";
    };
  };
  command-center-nvim = buildVimPluginFrom2Nix {
    pname = "command-center-nvim";
    version = "2022-08-27";
    src = fetchurl {
      url = "https://github.com/FeiyouG/command_center.nvim/archive/3d2c167fd4689b542e92f92566c51162eb362a10.tar.gz";
      sha256 = "0rphj40li0ylrr0qr30mk0zzk47gab65kcapwmzqlbsk8jnl3av0";
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
  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring";
    version = "2022-08-26";
    src = fetchurl {
      url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring/archive/4d3a68c41a53add8804f471fcc49bb398fe8de08.tar.gz";
      sha256 = "1zmyan81k95fygcyv86jnhvsp12lzpcq4w0lrjqqph5fr40xj1kj";
    };
    meta = with lib; {
      description = "Neovim treesitter plugin for setting the commentstring based on the cursor location in a file";
      homepage = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring";
      license = with licenses; [ mit ];
    };
  };
  lsp-setup-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-setup-nvim";
    version = "2022-08-16";
    src = fetchurl {
      url = "https://github.com/junnplus/lsp-setup.nvim/archive/5180bdaf0cd19534afc0ea1a4a45fab8ccfc1b9a.tar.gz";
      sha256 = "0dk8qk1qdafrwhjdq06p852bb3vm4hmky8ss6ippx0v1i5qj4i3h";
    };
    meta = with lib; {
      description = "A simple wrapper for nvim-lspconfig and mason-lspconfig to easily setup LSP servers";
      homepage = "https://github.com/junnplus/lsp-setup.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  LuaSnip = buildVimPluginFrom2Nix {
    pname = "LuaSnip";
    version = "2022-09-08";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/6e506ce63b7bebd1d4cb2243e0ab67abe82d9594.tar.gz";
      sha256 = "16swfp232zzcpixgw2d661p9yrcgsdsa1kqqm4q5sm8ajq03rd86";
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
    version = "2022-09-05";
    src = fetchurl {
      url = "https://github.com/Everblush/everblush.vim/archive/d8b9b8eb427afb4d6f4c931a7519236a39e3a9de.tar.gz";
      sha256 = "0sni3169vh16787fsvx5hsl6ha58kslspqjhvzpkc33bjgpqyip2";
    };
    meta = with lib; {
      description = "🎨 A beautiful and dark vim colorscheme. ";
      homepage = "https://github.com/Everblush/everblush.vim";
      license = with licenses; [ mit ];
    };
  };
  adwaita-nvim = buildVimPluginFrom2Nix {
    pname = "adwaita-nvim";
    version = "2022-08-12";
    src = fetchurl {
      url = "https://github.com/Mofiqul/adwaita.nvim/archive/230e1808045c70e7d6eda2eed9f1439a7474b309.tar.gz";
      sha256 = "141frliyqb0d6vyih6njwqlvc7z58sic4vpng7xl4lhblpg4cvgm";
    };
    meta = with lib; {
      description = "Neovim colorscheme using Gnome Adwaita syntax";
      homepage = "https://github.com/Mofiqul/adwaita.nvim";
    };
  };
  dracula-nvim = buildVimPluginFrom2Nix {
    pname = "dracula-nvim";
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/Mofiqul/dracula.nvim/archive/7f7371ad5af5d7bf7369f31a9da781e6c822a4d2.tar.gz";
      sha256 = "05blwscwkr7r0qdv4k62grm8s3r3x0g1sc2arvwl6j3p5a07149s";
    };
    meta = with lib; {
      description = "Dracula colorscheme for neovim written in Lua";
      homepage = "https://github.com/Mofiqul/dracula.nvim";
      license = with licenses; [ mit ];
    };
  };
  vscode-nvim = buildVimPluginFrom2Nix {
    pname = "vscode-nvim";
    version = "2022-08-08";
    src = fetchurl {
      url = "https://github.com/Mofiqul/vscode.nvim/archive/4f790efe9442d267a1d4e1d62d2611f84b16efb7.tar.gz";
      sha256 = "1lc4a8nwwnadd1kcrfjs1j6vdhzc21afpdmdhqwvggh0zmih1lhf";
    };
    meta = with lib; {
      description = "Neovim/Vim color scheme inspired by Dark+ and Light+ theme in Visual Studio Code";
      homepage = "https://github.com/Mofiqul/vscode.nvim";
      license = with licenses; [ mit ];
    };
  };
  exrc-nvim = buildVimPluginFrom2Nix {
    pname = "exrc-nvim";
    version = "2022-08-10";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/exrc.nvim/archive/7e6a93df0b84caa830b327dfb09c7d932d990367.tar.gz";
      sha256 = "1v7r8jl5xxwg3254xv0wiwa66qra0cyk392cjpgmf50l34s6vkz2";
    };
    meta = with lib; {
      description = "Secure Project Local Config for Neovim";
      homepage = "https://github.com/MunifTanjim/exrc.nvim";
      license = with licenses; [ mit ];
    };
  };
  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui-nvim";
    version = "2022-08-25";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/nui.nvim/archive/62facd37e0dd8196212399a897374f689886f500.tar.gz";
      sha256 = "1b34lqpqm78fqvgi4v08jg543kla1l4kz9vydc89jpg92gx9vi5n";
    };
    meta = with lib; {
      description = "UI Component Library for Neovim";
      homepage = "https://github.com/MunifTanjim/nui.nvim";
      license = with licenses; [ mit ];
    };
  };
  prettier-nvim = buildVimPluginFrom2Nix {
    pname = "prettier-nvim";
    version = "2022-09-04";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/prettier.nvim/archive/7bf4d17280a30f05d0bf5cd1efd4d9f644f7d878.tar.gz";
      sha256 = "020y4cqqd3ypwqzcnk9qyydxvagihcwn8mnhv6vqy49b1nfalss0";
    };
    meta = with lib; {
      description = "Prettier plugin for Neovim's built-in LSP client";
      homepage = "https://github.com/MunifTanjim/prettier.nvim";
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
      description = "Neovim plugin for displaying due dates";
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
    version = "2022-08-30";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/doom-one.nvim/archive/60eb78255472bd9a2ca483ce70757cfda57cc706.tar.gz";
      sha256 = "13psv28q48fwlpxgiaz3qll8irl3dv2wy38sw0dw510ccfbg45w9";
    };
    meta = with lib; {
      description = "doom-emacs' doom-one Lua port for Neovim";
      homepage = "https://github.com/NTBBloodbath/doom-one.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-colorizer-lua = buildVimPluginFrom2Nix {
    pname = "nvim-colorizer-lua";
    version = "2022-09-10";
    src = fetchurl {
      url = "https://github.com/NvChad/nvim-colorizer.lua/archive/2664070cd04f2b9f803a10dd328a562be8ab15ca.tar.gz";
      sha256 = "0adz86dk6k1288y10l7p2j8k01h4v1yai2w3zn8xyrqx88b3qrff";
    };
    meta = with lib; {
      description = "The fastest Neovim colorizer";
      homepage = "https://github.com/NvChad/nvim-colorizer.lua";
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
  auto-save-nvim = buildVimPluginFrom2Nix {
    pname = "auto-save-nvim";
    version = "2022-08-06";
    src = fetchurl {
      url = "https://github.com/Pocco81/auto-save.nvim/archive/2c7a2943340ee2a36c6a61db812418fca1f57866.tar.gz";
      sha256 = "0vsm2sm1hyix1334iz2s33rm55j9fi84in9gpczivaqcg42iw5fw";
    };
    meta = with lib; {
      description = "🧶 Automatically save your changes in NeoVim";
      homepage = "https://github.com/Pocco81/auto-save.nvim";
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
  crates-nvim = buildVimPluginFrom2Nix {
    pname = "crates-nvim";
    version = "2022-09-08";
    src = fetchurl {
      url = "https://github.com/Saecki/crates.nvim/archive/003442e2448870f6f2fab6ec7ac7b4de21e6d1d4.tar.gz";
      sha256 = "0i5z2hkh8b0w90kr83vf2ndqllda1ph69qga9a927zdry6i5nszs";
    };
    meta = with lib; {
      description = "A neovim plugin that helps managing crates.io dependencies";
      homepage = "https://github.com/Saecki/crates.nvim";
      license = with licenses; [ mit ];
    };
  };
  neovim-session-manager = buildVimPluginFrom2Nix {
    pname = "neovim-session-manager";
    version = "2022-09-10";
    src = fetchurl {
      url = "https://github.com/Shatur/neovim-session-manager/archive/ffefc2be3e0085d1a564aabe0566c95cd130bedc.tar.gz";
      sha256 = "1kk5sppv6h7lgja106cprm72mi5gbam2fhqna3x5cwsa7h2jx84w";
    };
    meta = with lib; {
      description = "A simple wrapper around :mksession";
      homepage = "https://github.com/Shatur/neovim-session-manager";
      license = with licenses; [ gpl3Only ];
    };
  };
  carbon-nvim = buildVimPluginFrom2Nix {
    pname = "carbon-nvim";
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/SidOfc/carbon.nvim/archive/9aa703e2d4068e03c93de334af8f6023e3676e21.tar.gz";
      sha256 = "164j3zwksckgg82pylb4wxd0dxizcrgwzfkhrkr97zq9pdxna87m";
    };
    meta = with lib; {
      description = "The simple directory tree viewer for Neovim written in Lua";
      homepage = "https://github.com/SidOfc/carbon.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-navic = buildVimPluginFrom2Nix {
    pname = "nvim-navic";
    version = "2022-09-05";
    src = fetchurl {
      url = "https://github.com/SmiteshP/nvim-navic/archive/202312e93869213c574d200a40eafeff4b4caec2.tar.gz";
      sha256 = "17pzk1vimzrhk37sl7n30j2l6blijb1p8k78xm7hn9l5rygq1aiy";
    };
    meta = with lib; {
      description = "Simple winbar/statusline plugin that shows your current code context";
      homepage = "https://github.com/SmiteshP/nvim-navic";
      license = with licenses; [ asl20 ];
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
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/TheBlob42/drex.nvim/archive/fe2fb8f7c8be8230b0fcda40f6072a46988f8951.tar.gz";
      sha256 = "1pwbczxipr1sg15z2gsg42lcfd2y0q5hmw1wlc3rpb94f026s6jh";
    };
    meta = with lib; {
      description = "Another directory/file explorer for Neovim written in Lua ";
      homepage = "https://github.com/TheBlob42/drex.nvim";
      license = with licenses; [ gpl3Only ];
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
    version = "2022-08-10";
    src = fetchurl {
      url = "https://github.com/TimUntersberger/neofs/archive/e10428da8f31001bffa0aba0a5c13fc623a54d75.tar.gz";
      sha256 = "0xj78y3yg7qngp36bk4ssd380lsnhda5yhliw07lsii0lrj81xpq";
    };
    meta = with lib; {
      description = "A file manager for neovim";
      homepage = "https://github.com/TimUntersberger/neofs";
      license = with licenses; [ mit ];
    };
  };
  persistent-breakpoints-nvim = buildVimPluginFrom2Nix {
    pname = "persistent-breakpoints-nvim";
    version = "2022-08-12";
    src = fetchurl {
      url = "https://github.com/Weissle/persistent-breakpoints.nvim/archive/0dee5374c68950a89d2739f8d59be2350a8503c7.tar.gz";
      sha256 = "10wjbvcpn3l4zf6x319kcy8m2ki2k4d6470f1dz6jwrr6733cwsd";
    };
    meta = with lib; {
      description = "Neovim plugin for persistent breakpoints";
      homepage = "https://github.com/Weissle/persistent-breakpoints.nvim";
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
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/adelarsq/neoline.vim/archive/185ee4c66b60cd8872d04b000a08c1d87579b0d6.tar.gz";
      sha256 = "1mk7175a9pa76rbjqkkbx55dk2gvll2rhprm20mps8dgq79w9hyk";
    };
    meta = with lib; {
      description = "Status Line for Neovim focused on beauty and performance ✅🖤💙💛";
      homepage = "https://github.com/adelarsq/neoline.vim";
      license = with licenses; [ mit ];
    };
  };
  apprentice-nvim = buildVimPluginFrom2Nix {
    pname = "apprentice-nvim";
    version = "2022-08-17";
    src = fetchurl {
      url = "https://github.com/adisen99/apprentice.nvim/archive/ef980c7feccd0d3ea650f93494b4d13a16c1471a.tar.gz";
      sha256 = "1xirniwylhzxnxf7vhsp23y1pmcyrn6fzc4ah9rmycyg0ah6fkk9";
    };
    meta = with lib; {
      description = "Apprentice color scheme for Neovim written in Lua";
      homepage = "https://github.com/adisen99/apprentice.nvim";
      license = with licenses; [ mit ];
    };
  };
  codeschool-nvim = buildVimPluginFrom2Nix {
    pname = "codeschool-nvim";
    version = "2022-08-17";
    src = fetchurl {
      url = "https://github.com/adisen99/codeschool.nvim/archive/b252b106b8651528f7e616cd6c258392a374c8fe.tar.gz";
      sha256 = "023p5sa3gpby9z038ksx1a8rp3grds34wrnj16g48qdha2vycyy8";
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
  git-conflict-nvim = buildVimPluginFrom2Nix {
    pname = "git-conflict-nvim";
    version = "2022-08-31";
    src = fetchurl {
      url = "https://github.com/akinsho/git-conflict.nvim/archive/0f87781ad92957a5354197baed9a6ace56332aa7.tar.gz";
      sha256 = "1qc6l7qr6b8x320fh3cyz0a89r1zmav1w9jvz2m5yb4q4g5msk62";
    };
    meta = with lib; {
      description = "A plugin to visualise and resolve merge conflicts in neovim";
      homepage = "https://github.com/akinsho/git-conflict.nvim";
    };
  };
  toggleterm-nvim = buildVimPluginFrom2Nix {
    pname = "toggleterm-nvim";
    version = "2022-09-05";
    src = fetchurl {
      url = "https://github.com/akinsho/toggleterm.nvim/archive/5e393e558f7c41d132542c8e9626aa824a1caa59.tar.gz";
      sha256 = "1skhdf1wrwfh9spf7jgq568yxs359y8wsgkg99jdi9n6b4hg63wj";
    };
    meta = with lib; {
      description = "A neovim lua plugin to help easily manage multiple terminal windows";
      homepage = "https://github.com/akinsho/toggleterm.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nim-nvim = buildVimPluginFrom2Nix {
    pname = "nim-nvim";
    version = "2022-08-08";
    src = fetchurl {
      url = "https://github.com/alaviss/nim.nvim/archive/87afde2ae995723e0338e1851c3b3c1cbd81d955.tar.gz";
      sha256 = "19jiq06gzw8gz59rdqq5jc8xi1sfq8f5pbfgfnm6mnj3sa79avl6";
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
  debugprint-nvim = buildVimPluginFrom2Nix {
    pname = "debugprint-nvim";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/andrewferrier/debugprint.nvim/archive/2b8a0dc2582bcc590748239615c2baac339d3812.tar.gz";
      sha256 = "1fxannw1pk0l65512xansdwzvf53i5l55j7zclansx1nmc59jz2r";
    };
    meta = with lib; {
      description = "Debugging in NeoVim the print() way!";
      homepage = "https://github.com/andrewferrier/debugprint.nvim";
    };
  };
  textobj-diagnostic-nvim = buildVimPluginFrom2Nix {
    pname = "textobj-diagnostic-nvim";
    version = "2022-08-14";
    src = fetchurl {
      url = "https://github.com/andrewferrier/textobj-diagnostic.nvim/archive/38abb6fd3c20770d92462a69b0c6b57fc74959bc.tar.gz";
      sha256 = "0jj1j4ryfb19izxa1dbb6fv3ipy6981mws4ggkrqahyq18fpjybl";
    };
    meta = with lib; {
      description = "NeoVim text object that finds diagnostics";
      homepage = "https://github.com/andrewferrier/textobj-diagnostic.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-coverage = buildVimPluginFrom2Nix {
    pname = "nvim-coverage";
    version = "2022-07-17";
    src = fetchurl {
      url = "https://github.com/andythigpen/nvim-coverage/archive/5b4d1749f11ac57bb41a1f5a919f6df25a9801a5.tar.gz";
      sha256 = "0sjxhis56qcqq2cfjf1snxrmk1ac5ij6szr9a2dvi575wnhhhdk0";
    };
    meta = with lib; {
      description = "Displays test coverage data in the sign column";
      homepage = "https://github.com/andythigpen/nvim-coverage";
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
  fold-preview-nvim = buildVimPluginFrom2Nix {
    pname = "fold-preview-nvim";
    version = "2022-08-09";
    src = fetchurl {
      url = "https://github.com/anuvyklack/fold-preview.nvim/archive/33c24101dc1b2be29876ee3354de98bb8bd14cb0.tar.gz";
      sha256 = "0lyn20vw6xnvhbbdllhi836d9x2r3qb222y0f33wc37wyjbcwf03";
    };
    meta = with lib; {
      description = "Preview folds in float window ";
      homepage = "https://github.com/anuvyklack/fold-preview.nvim";
    };
  };
  hydra-nvim = buildVimPluginFrom2Nix {
    pname = "hydra-nvim";
    version = "2022-08-05";
    src = fetchurl {
      url = "https://github.com/anuvyklack/hydra.nvim/archive/c70facc87141f64162aca519acfd18aa85e06329.tar.gz";
      sha256 = "0b9qp5q330hr8742g46wicvbd5vs1g2mqpcnigzjq6bsyksaj5xk";
    };
    meta = with lib; {
      description = "Create custom submodes and menus";
      homepage = "https://github.com/anuvyklack/hydra.nvim";
    };
  };
  keymap-amend-nvim = buildVimPluginFrom2Nix {
    pname = "keymap-amend-nvim";
    version = "2022-07-28";
    src = fetchurl {
      url = "https://github.com/anuvyklack/keymap-amend.nvim/archive/41964a7230b6a787d3121bf8d2d06c08dabe9449.tar.gz";
      sha256 = "0lnci88890dbjjq66rigzsigshh5yw0q340l44ckla96cgab63cy";
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
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/aserowy/tmux.nvim/archive/f3af091f5f0b7b102b4bb8def014ed13171af0b8.tar.gz";
      sha256 = "16f1bjis93x5p1zp902rqz2lnfg8h0gyl21krq89bihx248ilq7f";
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
  incline-nvim = buildVimPluginFrom2Nix {
    pname = "incline-nvim";
    version = "2022-07-28";
    src = fetchurl {
      url = "https://github.com/b0o/incline.nvim/archive/44d4e6f4dcf2f98cf7b62a14e3c10749fc5c6e35.tar.gz";
      sha256 = "1mcddmz1laqarvgrphgzkaxackb7y3f2mhql0kd9iyf4m74c9kld";
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
  focus-nvim = buildVimPluginFrom2Nix {
    pname = "focus-nvim";
    version = "2022-08-10";
    src = fetchurl {
      url = "https://github.com/beauwilliams/focus.nvim/archive/eb63719f4664b22e9e472c4c97773200110c2b1f.tar.gz";
      sha256 = "1qh2lbwzrb56dx4c4aqrypqs4pcs5k89xs52q9kwwypxqfjlplcj";
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
    version = "2022-08-02";
    src = fetchurl {
      url = "https://github.com/bennypowers/nvim-regexplainer/archive/0d7151ddd3ff2b2e9e8a69137b911c28fc7051a4.tar.gz";
      sha256 = "03bpnh6j5igq2vvssg4y27yx6bdg1dx4idjrs9v5756z5dgn3q3a";
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
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-moonfly-colors/archive/5548d41bf4654ba34f2947a878c70014b586ff25.tar.gz";
      sha256 = "0dbqs1blai8w1d0nraya4njkc9vy4f94im99hd0xyrj2v07zz5fy";
    };
    meta = with lib; {
      description = "A dark color scheme for Vim & Neovim";
      homepage = "https://github.com/bluz71/vim-moonfly-colors";
      license = with licenses; [ mit ];
    };
  };
  vim-nightfly-guicolors = buildVimPluginFrom2Nix {
    pname = "vim-nightfly-guicolors";
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-nightfly-guicolors/archive/9358eafeb9690a0087f9ecf78448e1a1f1dd787b.tar.gz";
      sha256 = "1pbygjvb6f8jdj73aq57k48avgg8s7k0mg0zh1wvamqnrdpsc9b8";
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
  mix-nvim = buildVimPluginFrom2Nix {
    pname = "mix-nvim";
    version = "2022-08-22";
    src = fetchurl {
      url = "https://github.com/brendalf/mix.nvim/archive/9cbdc90351781c183667be15d51b0ec09396c3f4.tar.gz";
      sha256 = "0c5rmlixvh9lffr4l4qlsm3qx4ihv1sbknb9ljfbd6qlgvrq0rx8";
    };
    meta = with lib; {
      description = "A Mix Wrapper for Neovim";
      homepage = "https://github.com/brendalf/mix.nvim";
    };
  };
  nvim-highlight-colors = buildVimPluginFrom2Nix {
    pname = "nvim-highlight-colors";
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/brenoprata10/nvim-highlight-colors/archive/5902d013a507db47629fb18d5563074793f5255c.tar.gz";
      sha256 = "18wb2shs4pgcfxb042i7yrb1hgnwi26djqxzfacm2fxr7j8w9qkd";
    };
    meta = with lib; {
      description = "Highlight colors for neovim";
      homepage = "https://github.com/brenoprata10/nvim-highlight-colors";
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
    version = "2022-09-08";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/047770c18ddf8081873cc6279f640c2dda725bba.tar.gz";
      sha256 = "19ifnn90xmpy0qzqix7hw61m0wka20bdw3ppgyplg4whyhnnkf7j";
    };
    meta = with lib; {
      description = "🍨 Soothing pastel theme for NeoVim";
      homepage = "https://github.com/catppuccin/nvim";
      license = with licenses; [ mit ];
    };
  };
  distant-nvim = buildVimPluginFrom2Nix {
    pname = "distant-nvim";
    version = "2022-08-05";
    src = fetchurl {
      url = "https://github.com/chipsenkbeil/distant.nvim/archive/887fc16bdae59bd1865e0776b427ca521987f7fe.tar.gz";
      sha256 = "1vvq43gq1fqvm47yj78bdcc00v127k0hffd4hiz1h6liis5g99zd";
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
  one-monokai-nvim = buildVimPluginFrom2Nix {
    pname = "one-monokai-nvim";
    version = "2022-08-27";
    src = fetchurl {
      url = "https://github.com/cpea2506/one_monokai.nvim/archive/effc75b63b415b8ca5bc328aba33eae279bb12f3.tar.gz";
      sha256 = "102dd0zv9zj36n1k41fsxs4b31n3xr3910asw3da4flmcas1cfnl";
    };
    meta = with lib; {
      description = "One Monokai theme for Neovim";
      homepage = "https://github.com/cpea2506/one_monokai.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-go = buildVimPluginFrom2Nix {
    pname = "nvim-go";
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/crispgm/nvim-go/archive/6775cba94504e69fa9c8816cc89e37479ef4300a.tar.gz";
      sha256 = "04n8k1qics4gi73a87sn7xkzk7xpf8wzjqn0rri1p98b2xlfcn03";
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
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/crusj/bookmarks.nvim/archive/75ad577f98b6bed05cb1fd038bda0f92ae2c147f.tar.gz";
      sha256 = "07ixjlj566l5c4gmybi9llrb8jm3z8vlx8w6ga2jjp0l800aqg18";
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
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/crusj/structrue-go.nvim/archive/77eced9495b8b0f4a1315f2c1cc2f5cfbb808f51.tar.gz";
      sha256 = "1kmjv2zw2imsm4ma8v53qckiidhgp4jlfsk1dmcv06bp44wnhzdf";
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
    version = "2022-08-06";
    src = fetchurl {
      url = "https://github.com/drybalka/tree-climber.nvim/archive/9c943b85f44d3064e8f42ee8b3aacad3959a5a75.tar.gz";
      sha256 = "0bagpkq086vxcq6kix6xz4fvfrj5lck82b0b176xpgvkfg4l1kv2";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/drybalka/tree-climber.nvim";
      license = with licenses; [ mit ];
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
    version = "2022-08-28";
    src = fetchurl {
      url = "https://github.com/elihunter173/dirbuf.nvim/archive/ac7ad3c8e61630d15af1f6266441984f54f54fd2.tar.gz";
      sha256 = "115z2h99sc55zv2dvsm73a9dlf77zy3dv68x6ry1d8qzi415d60q";
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
    version = "2022-08-23";
    src = fetchurl {
      url = "https://github.com/ellisonleao/glow.nvim/archive/8dca3583e44d54bcfd79cb8dc06ddb89128aa5e0.tar.gz";
      sha256 = "0q615kpjbag7f7m40wapd1mciab1yfhcgsh1qsikiwhx7ln1fnmv";
    };
    meta = with lib; {
      description = "A markdown preview directly in your neovim";
      homepage = "https://github.com/ellisonleao/glow.nvim";
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
  feline-nvim = buildVimPluginFrom2Nix {
    pname = "feline-nvim";
    version = "2022-09-02";
    src = fetchurl {
      url = "https://github.com/feline-nvim/feline.nvim/archive/331a79449d86668618a4e00fced153bce3ce2780.tar.gz";
      sha256 = "042va23c6wabr7z56z13ggfc4cp36sv87v2cmzl283r8kvfa1qh6";
    };
    meta = with lib; {
      description = "A minimal, stylish and customizable statusline for Neovim written in Lua";
      homepage = "https://github.com/feline-nvim/feline.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  knap = buildVimPluginFrom2Nix {
    pname = "knap";
    version = "2022-08-05";
    src = fetchurl {
      url = "https://github.com/frabjous/knap/archive/4c472163b3134a7260e1105571021f7b9ba4ed41.tar.gz";
      sha256 = "0ap3zngdrcaw05yqpn288hlmcmzl8ixkcrgz231hfqz86jrw78zh";
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
    version = "2022-08-23";
    src = fetchurl {
      url = "https://github.com/gbprod/phpactor.nvim/archive/6b79d30f6d172a0c6f387155952f5f03f7f4f74d.tar.gz";
      sha256 = "0dys7xsvlyccbfkryrxlyrsi6xg58zdxap34fqjza11aar6bvjn9";
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
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/gbprod/substitute.nvim/archive/974d877cd3c7f7c41449788c3d99238aeabbe1b8.tar.gz";
      sha256 = "1l1sw0lrb9g8m7zhf0idnmvgsdsz1k0n3a67d90g9vx6hw6c2044";
    };
    meta = with lib; {
      description = "Neovim plugin introducing a new operators motions to quickly replace and exchange text";
      homepage = "https://github.com/gbprod/substitute.nvim";
      license = with licenses; [ wtfpl ];
    };
  };
  yanky-nvim = buildVimPluginFrom2Nix {
    pname = "yanky-nvim";
    version = "2022-08-25";
    src = fetchurl {
      url = "https://github.com/gbprod/yanky.nvim/archive/2805c5cde03e7bf9d98824fc2d924423b864a7c3.tar.gz";
      sha256 = "0hfc40zn41h8v8fbypik8znzmgp10i6mfhz95hv3mhabpvd7l491";
    };
    meta = with lib; {
      description = "Improved Yank and Put functionalities for Neovim";
      homepage = "https://github.com/gbprod/yanky.nvim";
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
  leap-nvim = buildVimPluginFrom2Nix {
    pname = "leap-nvim";
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/ggandor/leap.nvim/archive/762e3d75acea9ebc9bb9c02a4da1882336483e4e.tar.gz";
      sha256 = "1gdargpxbs0212i3lplwc2lgnk2sqqrpwiz4j24a5zxgg8mdbcb5";
    };
    meta = with lib; {
      description = "🦘 Neovim's answer to the mouse: a \"clairvoyant\" interface that makes on-screen jumps quicker and more natural than ever";
      homepage = "https://github.com/ggandor/leap.nvim";
      license = with licenses; [ mit ];
    };
  };
  cybu-nvim = buildVimPluginFrom2Nix {
    pname = "cybu-nvim";
    version = "2022-09-01";
    src = fetchurl {
      url = "https://github.com/ghillb/cybu.nvim/archive/43b68850ac370c583e95ff136f65b144859470dc.tar.gz";
      sha256 = "0727gcwl9h4sq07hhc1rz1j2k32lipzr8xk7cwfmnbc1c8920zvn";
    };
    meta = with lib; {
      description = "Neovim plugin that offers context when cycling buffers in the form of a customizable notification window";
      homepage = "https://github.com/ghillb/cybu.nvim";
      license = with licenses; [ mit ];
    };
  };
  firenvim = buildVimPluginFrom2Nix {
    pname = "firenvim";
    version = "2022-08-16";
    src = fetchurl {
      url = "https://github.com/glacambre/firenvim/archive/56a49d79904921a8b4405786e12b4e12fbbf171b.tar.gz";
      sha256 = "1z624w2zr5mi89ra1a584gcqfhhgdzv5ajgcfx0mm2r0gfrrk8p2";
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
    version = "2022-08-20";
    src = fetchurl {
      url = "https://github.com/glepnir/prodoc.nvim/archive/a0838640976165ed95ecbd49bf59eb26e930c1eb.tar.gz";
      sha256 = "1d9hpd03p501wly666spgc4mbmhb1icixrczfdk3jswb25v2m6bc";
    };
    meta = with lib; {
      description = "a neovim comment and  annotation plugin using coroutine";
      homepage = "https://github.com/glepnir/prodoc.nvim";
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
    version = "2022-07-31";
    src = fetchurl {
      url = "https://github.com/henriquehbr/ataraxis.lua/archive/1ded0dde2f37a06299e6001c9343dcc774dbfa12.tar.gz";
      sha256 = "1khwypigldh8b8cy2f2wr54scs6nfi2hdv79z31zgn1dwmgym9bn";
    };
    meta = with lib; {
      description = "A simple zen mode for improving code readability on neovim";
      homepage = "https://github.com/henriquehbr/ataraxis.lua";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-startup-lua = buildVimPluginFrom2Nix {
    pname = "nvim-startup-lua";
    version = "2022-07-31";
    src = fetchgit {
      url = "https://git.sr.ht/~henriquehbr/nvim-startup.lua";
      rev = "f2f450df0ea970b9e7848ab1634f01baccc1dcf8";
      sha256 = "18355a1mb4a0p2fbirzyx1axs4vl7vnmgls5hpgdw51kylffz9gp";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://sr.ht/~henriquehbr/nvim-startup.lua/";
    };
  };
  iron-nvim = buildVimPluginFrom2Nix {
    pname = "iron-nvim";
    version = "2022-08-31";
    src = fetchurl {
      url = "https://github.com/hkupty/iron.nvim/archive/eeb7fb1c4ac4231ff3982e0e2a68e25791be780f.tar.gz";
      sha256 = "15qd0s6lxdkakgwksx4wdv2kg9rz1gd5mkjlh852qjdk1pzwkjqp";
    };
    meta = with lib; {
      description = "Interactive Repl Over Neovim";
      homepage = "https://github.com/hkupty/iron.nvim";
      license = with licenses; [ bsd3 ];
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
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/ishan9299/modus-theme-vim/archive/a237dae84cfd2ede32b97dc9635a0f9db6144a74.tar.gz";
      sha256 = "0x02bhvcw6avkylf7prj3g4jzkakla9flxh98y2j88nc542s4jfw";
    };
    meta = with lib; {
      description = "Port of modus-themes in neovim";
      homepage = "https://github.com/ishan9299/modus-theme-vim";
      license = with licenses; [ mit ];
    };
  };
  mkdnflow-nvim = buildVimPluginFrom2Nix {
    pname = "mkdnflow-nvim";
    version = "2022-08-31";
    src = fetchurl {
      url = "https://github.com/jakewvincent/mkdnflow.nvim/archive/c094cffa37660015470872868c7ca01137fc976b.tar.gz";
      sha256 = "0d1sdgby61l9wpwqm34c8xddyxsc889njl3v4zxxv77g4hzvnbc5";
    };
    meta = with lib; {
      description = "Fluent navigation and management of markdown notebooks";
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
    version = "2022-09-08";
    src = fetchurl {
      url = "https://github.com/jbyuki/nabla.nvim/archive/24b4dbe4636461bc3316106be5a824d7674ddcba.tar.gz";
      sha256 = "0mm2f2wvnrmvv0syg7qryp9wiwda0cf9m8mq1ajhcjzrnix2vj1x";
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
  possession-nvim = buildVimPluginFrom2Nix {
    pname = "possession-nvim";
    version = "2022-08-30";
    src = fetchurl {
      url = "https://github.com/jedrzejboczar/possession.nvim/archive/a7c49ee0b15a3ae05fa9e5d96202ed62a4004ae5.tar.gz";
      sha256 = "0vnyfphmyxdnrv5y12rqyi11y1rxisxpp86py87gyq3rqh8kmfhl";
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
    version = "2022-09-05";
    src = fetchurl {
      url = "https://github.com/jghauser/auto-pandoc.nvim/archive/a2906258db9813745c479b87a7058253d5e60d17.tar.gz";
      sha256 = "1gj72sch1607rvn3xwf3q5cvcx0m46d0dgz9jn6qxkadhldpxzy9";
    };
    meta = with lib; {
      description = "A neovim plugin leveraging pandoc to help you convert your markdown files. It takes pandoc options from yaml blocks";
      homepage = "https://github.com/jghauser/auto-pandoc.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  fold-cycle-nvim = buildVimPluginFrom2Nix {
    pname = "fold-cycle-nvim";
    version = "2022-08-17";
    src = fetchurl {
      url = "https://github.com/jghauser/fold-cycle.nvim/archive/7100300f3a8ae5b7222c07aa805f591ebbce447d.tar.gz";
      sha256 = "0xys7rflzv91zhmyr2168s5v2wi676s2p4lpp113qgq7bzjlha0y";
    };
    meta = with lib; {
      description = "This neovim plugin allows you to cycle folds open or closed";
      homepage = "https://github.com/jghauser/fold-cycle.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  follow-md-links-nvim = buildVimPluginFrom2Nix {
    pname = "follow-md-links-nvim";
    version = "2022-08-21";
    src = fetchurl {
      url = "https://github.com/jghauser/follow-md-links.nvim/archive/f31196f24046487a95341cc539dda97a00cb6a09.tar.gz";
      sha256 = "0m79fha58aypmf8ssyhydck3vsd78g071amz73yfs8c3b7k06kab";
    };
    meta = with lib; {
      description = "Easily follow markdown links with this neovim plugin";
      homepage = "https://github.com/jghauser/follow-md-links.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  kitty-runner-nvim = buildVimPluginFrom2Nix {
    pname = "kitty-runner-nvim";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/jghauser/kitty-runner.nvim/archive/c41158a16af49180540cb0085c82ba4be5b395d2.tar.gz";
      sha256 = "0mwjl4aclm2rcv5gbgnchpr7ayknmscb44x42dlymhmjanqy93md";
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
    version = "2022-09-10";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/null-ls.nvim/archive/bf027826eeb83606ef7153f312ef66750ef14961.tar.gz";
      sha256 = "0g9rb2vyvcdv2bakil1y6hr6vj01nx7w3s1kk2wpji0736l9bpsk";
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
  nvim-juliana = buildVimPluginFrom2Nix {
    pname = "nvim-juliana";
    version = "2022-09-08";
    src = fetchurl {
      url = "https://github.com/kaiuri/nvim-juliana/archive/2cf71fc291f5348034fbb2767afa20ea07ed086c.tar.gz";
      sha256 = "03rwziy8nm1f4m5hxggmgkwjs11h9z05gzl4c2h7rlk5hfrrwni6";
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
  im-select-nvim = buildVimPluginFrom2Nix {
    pname = "im-select-nvim";
    version = "2022-07-31";
    src = fetchurl {
      url = "https://github.com/keaising/im-select.nvim/archive/5271f73dcf776d7d76f2781fd6e785a8fcc0ffc0.tar.gz";
      sha256 = "1xdgnp147mk1q1bbcnpmfnvxghn7jgn53ym7h7n6qzl1wdxlpi8q";
    };
    meta = with lib; {
      description = "Switch Input Method automatically depends on Neovim's edit mode ";
      homepage = "https://github.com/keaising/im-select.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-ufo = buildVimPluginFrom2Nix {
    pname = "nvim-ufo";
    version = "2022-09-10";
    src = fetchurl {
      url = "https://github.com/kevinhwang91/nvim-ufo/archive/3f649eedec68dfa62d49a6fe80c19e1cad6d7afc.tar.gz";
      sha256 = "0r0siqwbgg9irlvn0ka2sp0sylgw708p1by42b7ygmg49jgmriv8";
    };
    meta = with lib; {
      description = "Not UFO in the sky, but an ultra fold in Neovim";
      homepage = "https://github.com/kevinhwang91/nvim-ufo";
      license = with licenses; [ bsd3 ];
    };
  };
  lspsaga-nvim = buildVimPluginFrom2Nix {
    pname = "lspsaga-nvim";
    version = "2022-08-20";
    src = fetchurl {
      url = "https://github.com/kkharji/lspsaga.nvim/archive/9ec569a49aa7ff265764081acff9e5da839c13fe.tar.gz";
      sha256 = "0206igfxs1imgj8dalvi5mhi49q5qj4hrm2y21x0w1wv9f07g2n1";
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
      description = "SQLite LuaJIT binding with a very simple api";
      homepage = "https://github.com/kkharji/sqlite.lua";
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
  nvim-surround = buildVimPluginFrom2Nix {
    pname = "nvim-surround";
    version = "2022-09-04";
    src = fetchurl {
      url = "https://github.com/kylechui/nvim-surround/archive/d91787d5a716623be7cec3be23c06c0856dc21b8.tar.gz";
      sha256 = "1pwdc4yqpyaf0jdxgch01119wm46fp7ffc15fdhhw96s99mhbawk";
    };
    meta = with lib; {
      description = "Add/change/delete surrounding delimiter pairs with ease. Written with :heart: in Lua";
      homepage = "https://github.com/kylechui/nvim-surround";
      license = with licenses; [ mit ];
    };
  };
  cobalt2-nvim = buildVimPluginFrom2Nix {
    pname = "cobalt2-nvim";
    version = "2022-09-01";
    src = fetchurl {
      url = "https://github.com/lalitmee/cobalt2.nvim/archive/10cf851d79779f2d9fb71fb014d09851c66d6e27.tar.gz";
      sha256 = "0hpdcnk9df2ayin7ja2jswnsf3alanbl9rxihv3can875xwa7p33";
    };
    meta = with lib; {
      description = "cobalt2 theme for neovim in Lua using colorbuddy";
      homepage = "https://github.com/lalitmee/cobalt2.nvim";
      license = with licenses; [ mit ];
    };
  };
  overlength-nvim = buildVimPluginFrom2Nix {
    pname = "overlength-nvim";
    version = "2022-08-10";
    src = fetchurl {
      url = "https://github.com/lcheylus/overlength.nvim/archive/3715b66d10ae0a68667e50c650c2ef3e5ab9f1e7.tar.gz";
      sha256 = "0p24a2fk0y84gph8i1ij4l26fbwi8s1gz4iq77g64c1rb54285zm";
    };
    meta = with lib; {
      description = "A small Neovim plugin to highlight too long lines";
      homepage = "https://github.com/lcheylus/overlength.nvim";
      license = with licenses; [ mit ];
    };
  };
  gh-nvim = buildVimPluginFrom2Nix {
    pname = "gh-nvim";
    version = "2022-09-02";
    src = fetchurl {
      url = "https://github.com/ldelossa/gh.nvim/archive/0d66195d8df7fadb2296d2d6e1bc5ef76e9e31ab.tar.gz";
      sha256 = "1pfpx248hw5pr991b0qddjs10al7fcczhggp1xrhjyxardyca346";
    };
    meta = with lib; {
      description = "A fully featured GitHub integration for performing code reviews in Neovim";
      homepage = "https://github.com/ldelossa/gh.nvim";
      license = with licenses; [ mit ];
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
  sherbet-nvim = buildVimPluginFrom2Nix {
    pname = "sherbet-nvim";
    version = "2022-09-02";
    src = fetchurl {
      url = "https://github.com/lewpoly/sherbet.nvim/archive/557e008196df29b60aedeace498433f8b8fb7112.tar.gz";
      sha256 = "0fbcphzdw2n3shjj62d9s87v1zgl9zj7m88n6v3asbyi9b6v7j9q";
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
    version = "2022-08-13";
    src = fetchurl {
      url = "https://github.com/linty-org/readline.nvim/archive/cab666cbd026dea9c817182e22255ecb3b3419b1.tar.gz";
      sha256 = "14ip3zv98m7fl988fwib13c62bwvmswmhwpk28ds5w17nxv11kvx";
    };
    meta = with lib; {
      description = "Readline motions and deletions in Neovim";
      homepage = "https://github.com/linty-org/readline.nvim";
    };
  };
  kimbox = buildVimPluginFrom2Nix {
    pname = "kimbox";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/lmburns/kimbox/archive/ec0b3d1900e8902e259ce8655942796583bff0ea.tar.gz";
      sha256 = "0iprfddmv8x20rnxcp800pfvva1fjwlkzl6rb5lvqff3nhzz3axy";
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
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/luisiacc/gruvbox-baby/archive/a7dd15a89fba420b73d712ca9cfc0c08158b2904.tar.gz";
      sha256 = "1gf4fh61bdh5kawmbha1760p6ghsvyj0ih2lnb3792p1hcvfq9bz";
    };
    meta = with lib; {
      description = "Gruvbox theme for neovim with full 🎄TreeSitter support. ";
      homepage = "https://github.com/luisiacc/gruvbox-baby";
      license = with licenses; [ mit ];
    };
  };
  lsp-format-nvim = buildVimPluginFrom2Nix {
    pname = "lsp-format-nvim";
    version = "2022-09-05";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/lsp-format.nvim/archive/b611bd6cea82ccc127cf8fd781a1cb784b0d6d3c.tar.gz";
      sha256 = "1g9bdnp6q6a0pqs2nivgi47yb1jxzgh683vis68wdvc117vzbv5a";
    };
    meta = with lib; {
      description = "A wrapper around Neovims native LSP formatting";
      homepage = "https://github.com/lukas-reineke/lsp-format.nvim";
    };
  };
  nnn-nvim = buildVimPluginFrom2Nix {
    pname = "nnn-nvim";
    version = "2022-08-23";
    src = fetchurl {
      url = "https://github.com/luukvbaal/nnn.nvim/archive/f9a4584085d37844c23874d916bc3934c6beabf0.tar.gz";
      sha256 = "1j54z4x4qi9y7sz54qmffr9x75zhyaxa98w3wngi3kaal2byf6vx";
    };
    meta = with lib; {
      description = "File manager for Neovim powered by nnn";
      homepage = "https://github.com/luukvbaal/nnn.nvim";
      license = with licenses; [ bsd3 ];
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
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/m-demare/hlargs.nvim/archive/9966b6f417cfbb3844905c2fe39e05341794a687.tar.gz";
      sha256 = "11kh3chlj2d7dsdg9ys9j8cibvrcwv3bzdmqfsq9k9yaswdb4mfv";
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
  autoclose-nvim = buildVimPluginFrom2Nix {
    pname = "autoclose-nvim";
    version = "2022-09-04";
    src = fetchurl {
      url = "https://github.com/m4xshen/autoclose.nvim/archive/c283288e75b83f11f9cbc227e997e02cc24ffc9c.tar.gz";
      sha256 = "1acf73cgk9gj6yxi28qqrhq2631v3gzx36fn641rzm8xmaw0qmzl";
    };
    meta = with lib; {
      description = "A minimalist autoclose plugin for Neovim written in Lua";
      homepage = "https://github.com/m4xshen/autoclose.nvim";
      license = with licenses; [ mit ];
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
    version = "2022-08-07";
    src = fetchurl {
      url = "https://github.com/mcchrish/zenbones.nvim/archive/30d9598356588bde64c4a29eb56aa241a246108c.tar.gz";
      sha256 = "03nslvas9r7p0061i38cpjqy7qsk02awb2d1rw0yzibcxxz8bx0s";
    };
    meta = with lib; {
      description = "🪨 A collection of contrast-based Vim/Neovim colorschemes";
      homepage = "https://github.com/mcchrish/zenbones.nvim";
      license = with licenses; [ mit ];
    };
  };
  neovim = buildVimPluginFrom2Nix {
    pname = "neovim";
    version = "2022-08-13";
    src = fetchurl {
      url = "https://github.com/meliora-theme/neovim/archive/670e67b51cfaa915e448b991c25c5ecc4402a2da.tar.gz";
      sha256 = "1z7f1maaxdq0gpvj37zlw8x8aj00ycfnq5lcyk6byx8vpxszb2x3";
    };
    meta = with lib; {
      description = "Warm and cozy theme for Neovim";
      homepage = "https://github.com/meliora-theme/neovim";
      license = with licenses; [ mit ];
    };
  };
  nvim-treehopper = buildVimPluginFrom2Nix {
    pname = "nvim-treehopper";
    version = "2022-08-07";
    src = fetchurl {
      url = "https://github.com/mfussenegger/nvim-treehopper/archive/f1ffa06bcd1566a50c3122b34334d38f50e1d420.tar.gz";
      sha256 = "1axrh56bym1blc2kpmzy792ppsm7vzkzxf6l702hym7m5xllpgrj";
    };
    meta = with lib; {
      description = "Region selection with hints on the AST nodes of a document powered by treesitter";
      homepage = "https://github.com/mfussenegger/nvim-treehopper";
      license = with licenses; [ gpl3Only ];
    };
  };
  sniprun = buildVimPluginFrom2Nix {
    pname = "sniprun";
    version = "2022-09-08";
    src = fetchurl {
      url = "https://github.com/michaelb/sniprun/archive/ef79f034286d03e404600c0a7d016862a27095bf.tar.gz";
      sha256 = "130sfnl68yqqzgiq8458cmbjcf1vazg5wa99qs6lizilwncjjb8b";
    };
    meta = with lib; {
      description = "A neovim plugin to run lines/blocs of code (independently of the rest of the file), supporting multiples languages";
      homepage = "https://github.com/michaelb/sniprun";
      license = with licenses; [ mit ];
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
  import-nvim = buildVimPluginFrom2Nix {
    pname = "import-nvim";
    version = "2022-08-16";
    src = fetchurl {
      url = "https://github.com/miversen33/import.nvim/archive/cd3be6736a78aa07357d97efa71e7ab5e542532b.tar.gz";
      sha256 = "15sczxmz7drh8i21f0xc6pimgzasg7x8qi9z606vzb7wg0yf5g3d";
    };
    meta = with lib; {
      description = "A safe require override with niceties";
      homepage = "https://github.com/miversen33/import.nvim";
      license = with licenses; [ mit ];
    };
  };
  iswap-nvim = buildVimPluginFrom2Nix {
    pname = "iswap-nvim";
    version = "2022-08-21";
    src = fetchurl {
      url = "https://github.com/mizlan/iswap.nvim/archive/a21edeeb1a77530074ceba3a3325b4648d995d21.tar.gz";
      sha256 = "0xgm2hdwy75x8an1h5mnhcagzbnpwg2698vspalr0lvgjr7kzm8l";
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
    version = "2022-08-29";
    src = fetchurl {
      url = "https://github.com/monaqa/dial.nvim/archive/d2d7a57fb030c82b8b0d6712d9c35dfb49d9aa3c.tar.gz";
      sha256 = "1d81b50jvdm9ggg9xyh054wcawmrffaksbskn8cpp78drw2wdh7n";
    };
    meta = with lib; {
      description = "enhanced increment/decrement plugin for Neovim";
      homepage = "https://github.com/monaqa/dial.nvim";
      license = with licenses; [ mit ];
    };
  };
  matchparen-nvim = buildVimPluginFrom2Nix {
    pname = "matchparen-nvim";
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/monkoose/matchparen.nvim/archive/4a3a8080e2f51c7947a9159fb0eb7217e11acd73.tar.gz";
      sha256 = "0x7i5jjhrgn8gbjwf8mim4dvq3yclcvyfc7zhdqwdf4as08rb42w";
    };
    meta = with lib; {
      description = "alternative to matchparen neovim plugin ";
      homepage = "https://github.com/monkoose/matchparen.nvim";
      license = with licenses; [ mit ];
    };
  };
  legendary-nvim = buildVimPluginFrom2Nix {
    pname = "legendary-nvim";
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/mrjones2014/legendary.nvim/archive/bb997500c454a470dc029c054d66f6d698404f2c.tar.gz";
      sha256 = "1l3yczq4vn1nn4ixhs9qh4gfdmky6a4555bb7zyaiy2zx2nf8dpy";
    };
    meta = with lib; {
      description = "🗺️ A legend for your keymaps, commands, and autocmds, with which-key.nvim integration";
      homepage = "https://github.com/mrjones2014/legendary.nvim";
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
    version = "2022-08-16";
    src = fetchurl {
      url = "https://github.com/nanozuki/tabby.nvim/archive/4d09e26705c5e4946189bf5e569e14ab30888f4a.tar.gz";
      sha256 = "1pw7vg8sym7h2dp6my3dm6w7k0ayslqfinmn7qyamwzsllwkrwn1";
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
  nvim-toggler = buildVimPluginFrom2Nix {
    pname = "nvim-toggler";
    version = "2022-08-26";
    src = fetchurl {
      url = "https://github.com/nguyenvukhang/nvim-toggler/archive/eb299950de0e90903b2e0869e67445329613797a.tar.gz";
      sha256 = "129c0par36grmj9p14nagf3zf89fjlig1m94qg3mhi2sqw77h333";
    };
    meta = with lib; {
      description = "invert text in vim, purely with lua";
      homepage = "https://github.com/nguyenvukhang/nvim-toggler";
      license = with licenses; [ mit ];
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
  nvim-bufferline = buildVimPluginFrom2Nix {
    pname = "nvim-bufferline";
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/noib3/nvim-bufferline/archive/501f93ec84af0d505d95d3827cad470b9c5e86dc.tar.gz";
      sha256 = "042s21h947sv8n3k7i4pqpgvjkd175wslr7bhsmz1nb333y11jfp";
    };
    meta = with lib; {
      description = ":nose: A minimal Neovim bufferline";
      homepage = "https://github.com/noib3/nvim-bufferline";
      license = with licenses; [ mit ];
    };
  };
  nvim-completion = buildVimPluginFrom2Nix {
    pname = "nvim-completion";
    version = "2022-09-10";
    src = fetchurl {
      url = "https://github.com/noib3/nvim-completion/archive/226d52cc7807e06207477b63dc0b78df9aca2672.tar.gz";
      sha256 = "1gwmkzqqbq6wdhln8jnii9vc4ba6ffag3ysna7lv8s0yh1lj47ii";
    };
    meta = with lib; {
      description = ":zap: An async autocompletion framework for Neovim";
      homepage = "https://github.com/noib3/nvim-completion";
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
    version = "2022-08-18";
    src = fetchurl {
      url = "https://github.com/notomo/cmdbuf.nvim/archive/26285127a413587632e6de50a63766322796cc85.tar.gz";
      sha256 = "09zf44bdczb1sx12lv7x8w9qrbb2n52dn6czfqxfb3m0f8a4rrqq";
    };
    meta = with lib; {
      description = "Alternative command-line window plugin for neovim";
      homepage = "https://github.com/notomo/cmdbuf.nvim";
      license = with licenses; [ mit ];
    };
  };
  gesture-nvim = buildVimPluginFrom2Nix {
    pname = "gesture-nvim";
    version = "2022-07-31";
    src = fetchurl {
      url = "https://github.com/notomo/gesture.nvim/archive/1f79ae130789462674e476a1814bae2c79b26fff.tar.gz";
      sha256 = "1sflk5agchwk2adh36kini12c4h4d9kb1rcqrazyk6lw1r87qk3d";
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
    version = "2022-09-04";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/30d23aa2e1ba204a74d5dfb99777e9acbe9dd2d6.tar.gz";
      sha256 = "0jff3jabbff4j01bmy8i5l5z0c9gcg84g98p5s7s5p6y7bfmr8pw";
    };
    meta = with lib; {
      description = ":brain: :muscle: // Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more";
      homepage = "https://github.com/numToStr/Comment.nvim";
      license = with licenses; [ mit ];
    };
  };
  colortils-nvim = buildVimPluginFrom2Nix {
    pname = "colortils-nvim";
    version = "2022-09-01";
    src = fetchurl {
      url = "https://github.com/nvim-colortils/colortils.nvim/archive/00baa1ec60be94bc52b0fed32d2aa32f146cddfb.tar.gz";
      sha256 = "10s5dmhhk5iv896r6f9j15vlmw7ciq9blddplj3ayjqa3pv9mnrb";
    };
    meta = with lib; {
      description = "Some color utils for neovim";
      homepage = "https://github.com/nvim-colortils/colortils.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  neo-tree-nvim = buildVimPluginFrom2Nix {
    pname = "neo-tree-nvim";
    version = "2022-08-19";
    src = fetchurl {
      url = "https://github.com/nvim-neo-tree/neo-tree.nvim/archive/a7d6f05e57487326fd70b24195c3b7a86a88b156.tar.gz";
      sha256 = "11npfc0p70xz09mvajhipw9c1w7w3khrbbsgikdimvl6m1nwfcrj";
    };
    meta = with lib; {
      description = "Neovim plugin to manage the file system and other tree like structures";
      homepage = "https://github.com/nvim-neo-tree/neo-tree.nvim";
      license = with licenses; [ mit ];
    };
  };
  neotest = buildVimPluginFrom2Nix {
    pname = "neotest";
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/nvim-neotest/neotest/archive/e682e446fa9fa88ba46f5a8162766811c8385b60.tar.gz";
      sha256 = "140iq1kikdhdq7x1ajkhbb70h2v89xl9pfg7lqdciipnqxkq9rli";
    };
    meta = with lib; {
      description = "An extensible framework for interacting with tests within NeoVim";
      homepage = "https://github.com/nvim-neotest/neotest";
      license = with licenses; [ mit ];
    };
  };
  telescope-bibtex-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-bibtex-nvim";
    version = "2022-07-30";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope-bibtex.nvim/archive/9bb88b3ca7c88d8d29e66e4656484eea1719a8ea.tar.gz";
      sha256 = "1jc3ysz9gpg84c1ibrqw33clnsvi561m93ghs2zwxa4qh80pl949";
    };
    meta = with lib; {
      description = "A telescope.nvim extension to search and paste bibtex entries into your TeX files";
      homepage = "https://github.com/nvim-telescope/telescope-bibtex.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-treesitter-context = buildVimPluginFrom2Nix {
    pname = "nvim-treesitter-context";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/nvim-treesitter/nvim-treesitter-context/archive/82631f666f186dbccb8190bc37a65d7cfab45d16.tar.gz";
      sha256 = "072fr5kqmgx1vnvvi96qr3wjqwcgddbrnjwydm96mgj6yc1vgylx";
    };
    meta = with lib; {
      description = "Show code context";
      homepage = "https://github.com/nvim-treesitter/nvim-treesitter-context";
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
  goto-breakpoints-nvim = buildVimPluginFrom2Nix {
    pname = "goto-breakpoints-nvim";
    version = "2022-08-18";
    src = fetchurl {
      url = "https://github.com/ofirgall/goto-breakpoints.nvim/archive/af43bb905cbff6c8ebb8e6438b75853b7baf1c74.tar.gz";
      sha256 = "16lf0b8wxfg8mjb6gkqyyv94irhixif0rzb40516v2hlfxz7sw8h";
    };
    meta = with lib; {
      description = "Cycle between breakpoints with keymappings for nvim-dap";
      homepage = "https://github.com/ofirgall/goto-breakpoints.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-hardline = buildVimPluginFrom2Nix {
    pname = "nvim-hardline";
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/ojroques/nvim-hardline/archive/81f8dafc1abfdd836f8b13abc903b0b82ca67c7b.tar.gz";
      sha256 = "0lhzyyh4jblrf75nc941a6pmv2bjhnhvkmn24d0q0vxadafi4d3f";
    };
    meta = with lib; {
      description = "A simple Neovim statusline";
      homepage = "https://github.com/ojroques/nvim-hardline";
      license = with licenses; [ bsd2 ];
    };
  };
  nvim-lspfuzzy = buildVimPluginFrom2Nix {
    pname = "nvim-lspfuzzy";
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/ojroques/nvim-lspfuzzy/archive/9badc1b6047d088f8c6e98cdbb01defd678e7451.tar.gz";
      sha256 = "1hjcmjzzy6dw228hxhpfy0dcbm6125l9bc3m5sdvn6igbp72s8x3";
    };
    meta = with lib; {
      description = "A Neovim plugin to make the LSP client use FZF";
      homepage = "https://github.com/ojroques/nvim-lspfuzzy";
      license = with licenses; [ bsd2 ];
    };
  };
  gopher-nvim = buildVimPluginFrom2Nix {
    pname = "gopher-nvim";
    version = "2022-07-11";
    src = fetchurl {
      url = "https://github.com/olexsmir/gopher.nvim/archive/80d06594259db519cfd047407d30a9871f0fe936.tar.gz";
      sha256 = "162vydh7x4w69yf8lqvxlpb5hb7kfm3p3q1nvl3c5vv02k523rg6";
    };
    meta = with lib; {
      description = "Neovim plugin for make golang development easiest";
      homepage = "https://github.com/olexsmir/gopher.nvim";
    };
  };
  persisted-nvim = buildVimPluginFrom2Nix {
    pname = "persisted-nvim";
    version = "2022-08-23";
    src = fetchurl {
      url = "https://github.com/olimorris/persisted.nvim/archive/321ba423671b7350366e70d859a994fbf595d0fd.tar.gz";
      sha256 = "04bqq3n4kqf14xjjs5jn7rsng1glwbw4cy0sld1rk6vrs2ic66ak";
    };
    meta = with lib; {
      description = "💾 Simple session management for Neovim with git branching, autosave/autoload and Telescope support";
      homepage = "https://github.com/olimorris/persisted.nvim";
      license = with licenses; [ mit ];
    };
  };
  poimandres-nvim = buildVimPluginFrom2Nix {
    pname = "poimandres-nvim";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/olivercederborg/poimandres.nvim/archive/9a1de86d74d069679fed1538db424494bfc2d402.tar.gz";
      sha256 = "1980jgr4nb6ns3zaslpwxx0nz8jgxqjkaphr1q73fhkm0878c29x";
    };
    meta = with lib; {
      description = "Poimandres colorscheme for Neovim written in Lua";
      homepage = "https://github.com/olivercederborg/poimandres.nvim";
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
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/p00f/cphelper.nvim/archive/c873e28fa743324bb949ef0f33eeaf49d059af08.tar.gz";
      sha256 = "0lb28iwmy2pky1y259b2vlpy029yn7c6hcsf523dgv26ny5q73j4";
    };
    meta = with lib; {
      description = "Neovim helper for competitive programming. https://sr.ht/~p00f/cphelper.nvim preferred";
      homepage = "https://github.com/p00f/cphelper.nvim";
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
  pantran-nvim = buildVimPluginFrom2Nix {
    pname = "pantran-nvim";
    version = "2022-09-05";
    src = fetchurl {
      url = "https://github.com/potamides/pantran.nvim/archive/2feb438aab4a994e8671502f03b8199b659728b8.tar.gz";
      sha256 = "13h77nfgj8bqbz3viiq4gd4r5fa1qwdr9i7hr64sjnqcgychpqag";
    };
    meta = with lib; {
      description = "Use your favorite machine translation engines without having to leave your favorite editor";
      homepage = "https://github.com/potamides/pantran.nvim";
      license = with licenses; [ mit ];
    };
  };
  github-nvim-theme = buildVimPluginFrom2Nix {
    pname = "github-nvim-theme";
    version = "2022-08-03";
    src = fetchurl {
      url = "https://github.com/projekt0n/github-nvim-theme/archive/b3f15193d1733cc4e9c9fe65fbfec329af4bdc2a.tar.gz";
      sha256 = "1n6il2yx01nm6q2w6nc2j1fagbfjdm1ic31g8fcjbndkpz8j3lbg";
    };
    meta = with lib; {
      description = "Github's Neovim themes ";
      homepage = "https://github.com/projekt0n/github-nvim-theme";
      license = with licenses; [ mit ];
    };
  };
  codeql-nvim = buildVimPluginFrom2Nix {
    pname = "codeql-nvim";
    version = "2022-09-05";
    src = fetchurl {
      url = "https://github.com/pwntester/codeql.nvim/archive/d5a55f7cff902931dc354b1cbfd34eda01cc32e0.tar.gz";
      sha256 = "1db5vanbnqz309mi5fd21hhs1lbr4fi34xnc070w9gmpqgm2vnpf";
    };
    meta = with lib; {
      description = "CodeQL plugin for Neovim";
      homepage = "https://github.com/pwntester/codeql.nvim";
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
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/ray-x/go.nvim/archive/4edd1c289e2fecc853926db9e65e94fb71d0199d.tar.gz";
      sha256 = "01c2gh0y6nkahfc0sdm067kgy6vs9y70yz5cr3gs2fxm8kq77dpf";
    };
    meta = with lib; {
      description = "Modern Go plugin for Neovim, based on gopls, treesitter AST, Dap and a variety of go tools";
      homepage = "https://github.com/ray-x/go.nvim";
      license = with licenses; [ mit ];
    };
  };
  guihua-lua = buildVimPluginFrom2Nix {
    pname = "guihua-lua";
    version = "2022-09-10";
    src = fetchurl {
      url = "https://github.com/ray-x/guihua.lua/archive/28455318b9ce0a6c1b44bcffa3ce27ab45c16be5.tar.gz";
      sha256 = "0sw97g6gzfj5h1ddv4gjzha7556d689z85jgfbxb2g1nypc2iqki";
    };
    meta = with lib; {
      description = "A GUI library for Neovim plugin developers";
      homepage = "https://github.com/ray-x/guihua.lua";
      license = with licenses; [ mit ];
    };
  };
  navigator-lua = buildVimPluginFrom2Nix {
    pname = "navigator-lua";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/ray-x/navigator.lua/archive/443fd4d5850fd5b471b66c55fdd3465157c4bd16.tar.gz";
      sha256 = "07lcgpgvxlv9v9n65959q8xafipxnlpkp3ix4s2xji0pagvxk62h";
    };
    meta = with lib; {
      description = "Source code analysis & navigation plugin for Neovim. Navigate codes like a breeze🎐.  Exploring LSP and 🌲Treesitter symbols a piece of 🍰. Take control like a boss 🦍";
      homepage = "https://github.com/ray-x/navigator.lua";
      license = with licenses; [ mit ];
    };
  };
  sad-nvim = buildVimPluginFrom2Nix {
    pname = "sad-nvim";
    version = "2022-08-30";
    src = fetchurl {
      url = "https://github.com/ray-x/sad.nvim/archive/01b7d84f4f73c8963f5933f09e88c833757bc7d8.tar.gz";
      sha256 = "1l0wbszvvmwhnf38165iyrrn5c952cv26f4wnnh3lxw23168xdim";
    };
    meta = with lib; {
      description = "Space Age seD in Neovim. A project-wide find and replace plugin for Neovim";
      homepage = "https://github.com/ray-x/sad.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  starry-nvim = buildVimPluginFrom2Nix {
    pname = "starry-nvim";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/ray-x/starry.nvim/archive/49caf295f2fe663842eaaf1e237e98ff3b58d795.tar.gz";
      sha256 = "00va52almpncc8sd1l9fvzx4mbbnf202n6xyzv4s5zaqqlml5f44";
    };
    meta = with lib; {
      description = "A pack of modern nvim color schemes: material, moonlight, Dracula (blood), Monokai, Mariana, Emerald, earlysummer, middlenight_blue... Fully support Treesitter, LSP and a variety of plugins";
      homepage = "https://github.com/ray-x/starry.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  web-tools-nvim = buildVimPluginFrom2Nix {
    pname = "web-tools-nvim";
    version = "2022-08-30";
    src = fetchurl {
      url = "https://github.com/ray-x/web-tools.nvim/archive/a289af77e14d224ab9770f9802d090f176dd340f.tar.gz";
      sha256 = "0h98qm0vkdr604psazikwalgx3nwjbk7an5906lsmqqzr6pma2lq";
    };
    meta = with lib; {
      description = "Neovim plugin for web developers";
      homepage = "https://github.com/ray-x/web-tools.nvim";
    };
  };
  heirline-nvim = buildVimPluginFrom2Nix {
    pname = "heirline-nvim";
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/rebelot/heirline.nvim/archive/8a8d66122ed05a47910b470ec3361258f6938798.tar.gz";
      sha256 = "064c29q1kpp2hdghvgkb0642r22rr2qgd9xzl496b6ph0i9m24gm";
    };
    meta = with lib; {
      description = "Heirline.nvim is a no-nonsense Neovim Statusline plugin designed around recursive inheritance to be exceptionally fast and versatile";
      homepage = "https://github.com/rebelot/heirline.nvim";
      license = with licenses; [ mit ];
    };
  };
  telekasten-nvim = buildVimPluginFrom2Nix {
    pname = "telekasten-nvim";
    version = "2022-08-19";
    src = fetchurl {
      url = "https://github.com/renerocksai/telekasten.nvim/archive/fdb089daf6d66e9d559645e664a172ff5b6a5ddd.tar.gz";
      sha256 = "1j85343b6fi4w0cklmak1kc5mrnclrgnabbm4br4jfc9zxlkgdj9";
    };
    meta = with lib; {
      description = "A Neovim (lua) plugin for working with a markdown zettelkasten / wiki and mixing it with a journal, based on telescope.nvim";
      homepage = "https://github.com/renerocksai/telekasten.nvim";
      license = with licenses; [ mit ];
    };
  };
  other-nvim = buildVimPluginFrom2Nix {
    pname = "other-nvim";
    version = "2022-08-03";
    src = fetchurl {
      url = "https://github.com/rgroli/other.nvim/archive/a2ae9e03d08c6c5e8f60cc1db58cbf4ada2ae338.tar.gz";
      sha256 = "0j2xvn7l2ipzpxgafdwlg919lp4fjz5gg6vzv9hhg43m4vpm1w8p";
    };
    meta = with lib; {
      description = "Open alternative files for the current buffer";
      homepage = "https://github.com/rgroli/other.nvim";
      license = with licenses; [ mit ];
    };
  };
  vim-gfm-syntax = buildVimPluginFrom2Nix {
    pname = "vim-gfm-syntax";
    version = "2022-08-01";
    src = fetchurl {
      url = "https://github.com/rhysd/vim-gfm-syntax/archive/95ec295ccc803afc925c01e6efe328779e1261e9.tar.gz";
      sha256 = "0fs8i7jn3jkr69lpnjasi38prj506j91gyc0csj06jz1j3lj4bki";
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
  paperplanes-nvim = buildVimPluginFrom2Nix {
    pname = "paperplanes-nvim";
    version = "2022-08-12";
    src = fetchurl {
      url = "https://github.com/rktjmp/paperplanes.nvim/archive/a47d7e3a388bd469ddd6dd1c794a09a71e47b3dc.tar.gz";
      sha256 = "1133j68l4lwwy8f9qahwhrbvzqx6h9s9innh31b72gd5w6c17q3r";
    };
    meta = with lib; {
      description = "Neovim :airplane: Pastebins";
      homepage = "https://github.com/rktjmp/paperplanes.nvim";
      license = with licenses; [ mit ];
    };
  };
  pounce-nvim = buildVimPluginFrom2Nix {
    pname = "pounce-nvim";
    version = "2022-08-23";
    src = fetchurl {
      url = "https://github.com/rlane/pounce.nvim/archive/a573820b20882c70d241a1ac94aa27670442c027.tar.gz";
      sha256 = "1270m2brapavgvv61y718pap2x11x3iznn0hknyjygvxiql1pjxg";
    };
    meta = with lib; {
      description = "Incremental fuzzy search motion plugin for Neovim";
      homepage = "https://github.com/rlane/pounce.nvim";
    };
  };
  onenord-nvim = buildVimPluginFrom2Nix {
    pname = "onenord-nvim";
    version = "2022-08-26";
    src = fetchurl {
      url = "https://github.com/rmehri01/onenord.nvim/archive/66f3c29ab54993d37030bd200602fc99278d0654.tar.gz";
      sha256 = "1mpwcb2nmb6p9jkbv9rrc95n32lp3a7byv5426zbq93zim21zxvq";
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
    version = "2022-08-24";
    src = fetchurl {
      url = "https://github.com/rockyzhang24/arctic.nvim/archive/c717865f01f82d182f56f41d0ab029bd8e79d2e2.tar.gz";
      sha256 = "1csl7aaz1mrfqnncwasnp3n4g6a22ikpvbz0462mp27cv9x0k5bx";
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
  rose-pine = buildVimPluginFrom2Nix {
    pname = "rose-pine";
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/rose-pine/neovim/archive/f739adcaf81ee8cba04b67d287b231c70416b779.tar.gz";
      sha256 = "04z0qnbamy95602lwmvhpchk8cryribk0fgwr9ipvmrsbnvadfs4";
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
    version = "2022-07-30";
    src = fetchurl {
      url = "https://github.com/savq/paq-nvim/archive/bc5950b990729464f2493b1eaab5a7721bd40bf5.tar.gz";
      sha256 = "1ydmrzyhxqwf4a9mmarzz2j159y0664mlr5yff47anc1z7l0la52";
    };
    meta = with lib; {
      description = "🌚  Neovim package manager";
      homepage = "https://github.com/savq/paq-nvim";
      license = with licenses; [ mit ];
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
    version = "2022-09-04";
    src = fetchurl {
      url = "https://github.com/Abstract-IDE/Abstract-cs/archive/a04e3682beea886b55950b0928390f8c41f2d5f9.tar.gz";
      sha256 = "0frlahpwccbxvd4n64ip2zljma7blfq44x6r9chsfxqc4yznnl0m";
    };
    meta = with lib; {
      description = "Colorscheme for (neo)vim written in lua, specially made for roshnivim with Tree-sitter support";
      homepage = "https://github.com/Abstract-IDE/Abstract-cs";
    };
  };
  nvim-numbertoggle = buildVimPluginFrom2Nix {
    pname = "nvim-numbertoggle";
    version = "2022-07-27";
    src = fetchurl {
      url = "https://github.com/sitiom/nvim-numbertoggle/archive/1b10222a338b511a9f54ad4ace9abe1d054fdf3b.tar.gz";
      sha256 = "09awxv6wvymflsxsgc998cfwfg337zrvrcllspv7vcidwgwy3fb0";
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
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/smjonas/inc-rename.nvim/archive/09e980117fd7788674a051ce623614a209766fb2.tar.gz";
      sha256 = "1l9h8n40kzls7y1pkz0b232izh58g2nwpv50d8g59lfblqzzq2ki";
    };
    meta = with lib; {
      description = "Incremental LSP renaming based on Neovim's command-preview feature";
      homepage = "https://github.com/smjonas/inc-rename.nvim";
      license = with licenses; [ mit ];
    };
  };
  snippet-converter-nvim = buildVimPluginFrom2Nix {
    pname = "snippet-converter-nvim";
    version = "2022-08-29";
    src = fetchurl {
      url = "https://github.com/smjonas/snippet-converter.nvim/archive/d1298102ed940a4a9423cf2bafe354c123c74d04.tar.gz";
      sha256 = "1y2dii462bh0pv8hvb86qr036gpnlfmyrfmkm6pwpfxzcbmvi6v2";
    };
    meta = with lib; {
      description = "Bundle snippets from multiple sources and convert them to your format of choice";
      homepage = "https://github.com/smjonas/snippet-converter.nvim";
      license = with licenses; [ mpl20 ];
    };
  };
  hydrovim = buildVimPluginFrom2Nix {
    pname = "hydrovim";
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/smzm/hydrovim/archive/a9ba8146539f2f0bfd71f763d13ccbe36865e248.tar.gz";
      sha256 = "18w5hc833wdwihi5r47c6i73klkcf96cgl433canl2f14klm6d55";
    };
    meta = with lib; {
      description = "➡️ Run python code inside Neovim ";
      homepage = "https://github.com/smzm/hydrovim";
    };
  };
  yaml-companion-nvim = buildVimPluginFrom2Nix {
    pname = "yaml-companion-nvim";
    version = "2022-09-06";
    src = fetchurl {
      url = "https://github.com/someone-stole-my-name/yaml-companion.nvim/archive/298bbcd8517b24fff64c06d357f2d283a272d33a.tar.gz";
      sha256 = "1w3fxcj2dvmmmpj2gwgmnb7s7qy27vhar8fw800f5g344yvd44p3";
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
  gkeep-nvim = buildVimPluginFrom2Nix {
    pname = "gkeep-nvim";
    version = "2022-09-02";
    src = fetchurl {
      url = "https://github.com/stevearc/gkeep.nvim/archive/f13d8156132c16082e083c20b90f5dcfda0c1aec.tar.gz";
      sha256 = "0hc4msa3vawr7w8991sj3097l4hf0pi1ml7zls93gp5csvcfakvl";
    };
    meta = with lib; {
      description = "Google Keep integration for Neovim";
      homepage = "https://github.com/stevearc/gkeep.nvim";
      license = with licenses; [ mit ];
    };
  };
  overseer-nvim = buildVimPluginFrom2Nix {
    pname = "overseer-nvim";
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/stevearc/overseer.nvim/archive/6fd97ed194d6bb35a954b541a3ec8f13107577ac.tar.gz";
      sha256 = "1ynypw83pqv8zv61dszw2jfnj1ac5870wca34c9wka3qh60nxb1s";
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
  smart-term-esc-nvim = buildVimPluginFrom2Nix {
    pname = "smart-term-esc-nvim";
    version = "2021-09-27";
    src = fetchurl {
      url = "https://github.com/sychen52/smart-term-esc.nvim/archive/168cd1a9e4649038e356b293005e5714e6e9f190.tar.gz";
      sha256 = "1lldf028a9a3a721avrwzai60msiaib30a18rsa98wa5fnvsi60j";
    };
    meta = with lib; {
      description = "Escape terminal \"smartly\" with <Esc> in Neovim";
      homepage = "https://github.com/sychen52/smart-term-esc.nvim";
    };
  };
  nlsp-settings-nvim = buildVimPluginFrom2Nix {
    pname = "nlsp-settings-nvim";
    version = "2022-09-10";
    src = fetchurl {
      url = "https://github.com/tamago324/nlsp-settings.nvim/archive/84e9a803bb31c1eb4265b43a55883f5a90a0b31f.tar.gz";
      sha256 = "0kzlkr42cda67lnm1hmzm5i44dj7gnc0a6jda6i538ql93x12zb9";
    };
    meta = with lib; {
      description = "A plugin for setting Neovim LSP with JSON or YAML files";
      homepage = "https://github.com/tamago324/nlsp-settings.nvim";
      license = with licenses; [ mit ];
    };
  };
  staline-nvim = buildVimPluginFrom2Nix {
    pname = "staline-nvim";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/tamton-aquib/staline.nvim/archive/c2ac9411815cf7fb135d798174ff5782e1b64075.tar.gz";
      sha256 = "02a17irk28pl5ndmjy1x9mp91kxm75ihcwax2rdzvyy0hdw9qwj1";
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
    version = "2022-09-04";
    src = fetchurl {
      url = "https://github.com/ThemerCorp/themer.lua/archive/38f11ad63a03cfbabb035d899443a1591a3b0fec.tar.gz";
      sha256 = "1shx9hpv9d56q13p8jwyaqczkbk84d6181dbmzm0bjrv4kl2yl3h";
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
    version = "2022-07-27";
    src = fetchurl {
      url = "https://github.com/tiagovla/tokyodark.nvim/archive/b8edc0d7b20e938c5ca8cd32150f4cb796250b2d.tar.gz";
      sha256 = "13ji9kixr97zwrq45nxjc07g9mg328ky2wwr3rf8q5sbcwzi5hk5";
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
  reach-nvim = buildVimPluginFrom2Nix {
    pname = "reach-nvim";
    version = "2022-08-23";
    src = fetchurl {
      url = "https://github.com/toppair/reach.nvim/archive/f56c93d7c37db0466c40b58e3b4f57202e06d88d.tar.gz";
      sha256 = "1znz7kizbkhn1wssqbg1syy861ydzxrp0j5swnb0v34f1d16qg21";
    };
    meta = with lib; {
      description = "Buffer, mark, tabpage, colorscheme switcher for Neovim";
      homepage = "https://github.com/toppair/reach.nvim";
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
  hibiscus-nvim = buildVimPluginFrom2Nix {
    pname = "hibiscus-nvim";
    version = "2022-08-28";
    src = fetchurl {
      url = "https://github.com/udayvir-singh/hibiscus.nvim/archive/dbb9b842bce5c51ab569c86a862bf779377f7a79.tar.gz";
      sha256 = "1ji71a7f036yrpwv2s0firp6vchk27jq2dyr0cajqcyw373xg0vd";
    };
    meta = with lib; {
      description = ":hibiscus: Flavored Fennel Macros for Neovim";
      homepage = "https://github.com/udayvir-singh/hibiscus.nvim";
      license = with licenses; [ mit ];
    };
  };
  tangerine-nvim = buildVimPluginFrom2Nix {
    pname = "tangerine-nvim";
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/udayvir-singh/tangerine.nvim/archive/5787a8abfa080bfe4905636d3c5b65d3fb450f65.tar.gz";
      sha256 = "15z1rsmga5ybfhp5dsx2i8dkhcfdq0q6xk3asy0ggsvfjn37bgqq";
    };
    meta = with lib; {
      description = "🍊 Sweet Fennel integration for Neovim";
      homepage = "https://github.com/udayvir-singh/tangerine.nvim";
      license = with licenses; [ mit ];
    };
  };
  complementree-nvim = buildVimPluginFrom2Nix {
    pname = "complementree-nvim";
    version = "2022-08-16";
    src = fetchurl {
      url = "https://github.com/vigoux/complementree.nvim/archive/df34723381373b2a91f0092fe8851b43e5ba9eaf.tar.gz";
      sha256 = "1vsz8dw7wdqy35ksmrccignh7zgnkznc4xka5jrvz500w9wpav8l";
    };
    meta = with lib; {
      description = "Tree-sitter powered syntax-aware completion framework";
      homepage = "https://github.com/vigoux/complementree.nvim";
      license = with licenses; [ bsd3 ];
    };
  };
  mason-nvim = buildVimPluginFrom2Nix {
    pname = "mason-nvim";
    version = "2022-09-11";
    src = fetchurl {
      url = "https://github.com/williamboman/mason.nvim/archive/6a2b45bad60a5ffe44c5b2423fd70d5a7a60c5ba.tar.gz";
      sha256 = "00fmfdy347hkznm75crbp1x2dickpfi9ph0nxn2cx7krccz0j6hk";
    };
    meta = with lib; {
      description = "Portable package manager for Neovim that runs everywhere Neovim runs. Easily install and manage LSP servers, DAP servers, linters, and formatters";
      homepage = "https://github.com/williamboman/mason.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  nvim-lsp-installer = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-installer";
    version = "2022-08-17";
    src = fetchurl {
      url = "https://github.com/williamboman/nvim-lsp-installer/archive/ae913cb4fd62d7a84fb1582e11f2e15b4d597123.tar.gz";
      sha256 = "0hrpi4i5gqcxjkd6lnx5spkay8mzv20c5hkivf8z0jk4phi1wz07";
    };
    meta = with lib; {
      description = "⚠️ Further development has moved to https://github.com/williamboman/mason.nvim!";
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
    version = "2022-09-08";
    src = fetchurl {
      url = "https://github.com/nvim-pack/nvim-spectre/archive/766e3667c49c498afa0821dfcc758cfa6f581f44.tar.gz";
      sha256 = "12740capwvx9fkk8adp1wikmk32pcwq0skhh4674317wjd4is35f";
    };
    meta = with lib; {
      description = "Find the enemy and replace them with dark power";
      homepage = "https://github.com/nvim-pack/nvim-spectre";
      license = with licenses; [ mit ];
    };
  };
  windline-nvim = buildVimPluginFrom2Nix {
    pname = "windline-nvim";
    version = "2022-09-04";
    src = fetchurl {
      url = "https://github.com/windwp/windline.nvim/archive/da7fd528ffd9c927acaa14bc37dbfb37b4a323a2.tar.gz";
      sha256 = "0pby654dj9xddwvh7s1pxc14qwqbk14ckynwdq5vi25rf98l793f";
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
    version = "2022-08-09";
    src = fetchurl {
      url = "https://github.com/xeluxee/competitest.nvim/archive/c86a94c5bd2a1edb69d2f77616005423a65949e0.tar.gz";
      sha256 = "0qg8mqb9nrnxjxb56ij9yn5npnns4kwfnbjz7a07ydgqr5sai1wc";
    };
    meta = with lib; {
      description = "CompetiTest.nvim is a Neovim plugin to automate testcases management and checking for Competitive Programming";
      homepage = "https://github.com/xeluxee/competitest.nvim";
    };
  };
  link-visitor-nvim = buildVimPluginFrom2Nix {
    pname = "link-visitor-nvim";
    version = "2022-08-30";
    src = fetchurl {
      url = "https://github.com/xiyaowong/link-visitor.nvim/archive/d151a85a3b29251e8f1190b87e1b409425bbe313.tar.gz";
      sha256 = "096cshd6shg21prjcz6mi0icvlz5c05hgr26m66x738mjmg52g0v";
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
    version = "2022-08-13";
    src = fetchurl {
      url = "https://github.com/xiyaowong/virtcolumn.nvim/archive/cd9485d64a0763c5572272e03d70cbff1f91fde0.tar.gz";
      sha256 = "0vizmfk28ahfi89dzqg7ag3j7frp7yhjsllcyryfaiv6hvviqa60";
    };
    meta = with lib; {
      description = "Display a line as the colorcolumn";
      homepage = "https://github.com/xiyaowong/virtcolumn.nvim";
    };
  };
  nvim-hlchunk = buildVimPluginFrom2Nix {
    pname = "nvim-hlchunk";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/yaocccc/nvim-hlchunk/archive/a7df7cfb29f31e27a8222876f8d5d912c37e98b7.tar.gz";
      sha256 = "1z1ywcy0mwnb58z7zzbj4vd8irqmjxl2nki5b0whlk73mpj69fc2";
    };
    meta = with lib; {
      description = "hignlight chunk numbercolumn plug of nvim";
      homepage = "https://github.com/yaocccc/nvim-hlchunk";
      license = with licenses; [ mit ];
    };
  };
  nvim-lines-lua = buildVimPluginFrom2Nix {
    pname = "nvim-lines-lua";
    version = "2022-09-07";
    src = fetchurl {
      url = "https://github.com/yaocccc/nvim-lines.lua/archive/64e8753b29bf35ace2369657244181e3eeecad51.tar.gz";
      sha256 = "0068775ibdc044ndzylpplf1jy8fmnlgsd51axk80wpnswmfx99s";
    };
    meta = with lib; {
      description = "a neovim statusline & tabline plug";
      homepage = "https://github.com/yaocccc/nvim-lines.lua";
      license = with licenses; [ mit ];
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
    version = "2022-08-17";
    src = fetchurl {
      url = "https://github.com/Yazeed1s/minimal.nvim/archive/b2e466f29ae9fa06142f05de8e28476f0ccea8ca.tar.gz";
      sha256 = "1p3iwa0n4932nhydgq4qwhr692qds04yqjzhb1lqxw6qbk2c0cxq";
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
    version = "2022-09-09";
    src = fetchurl {
      url = "https://github.com/zbirenbaum/copilot-cmp/archive/a796f046a734f10100152a2c1180ffdcec06f2a3.tar.gz";
      sha256 = "1dwvb8pbdslhh24pdq9w59lcjyx5nrm96fkqpl5v9kx7bk8zmp8n";
    };
    meta = with lib; {
      description = "Lua plugin to turn github copilot into a cmp source";
      homepage = "https://github.com/zbirenbaum/copilot-cmp";
      license = with licenses; [ mit ];
    };
  };
  color-picker-nvim = buildVimPluginFrom2Nix {
    pname = "color-picker-nvim";
    version = "2022-08-16";
    src = fetchurl {
      url = "https://github.com/ziontee113/color-picker.nvim/archive/2b4a4a408278271909e3eb13fe0715f856c7b4d8.tar.gz";
      sha256 = "0d3q37xxs2bn8ncf36vx8cng8vp5gidg89bd28yywixv289nxdnx";
    };
    meta = with lib; {
      description = "A powerful Neovim plugin that lets users choose & modify RGB/HSL/HEX colors. ";
      homepage = "https://github.com/ziontee113/color-picker.nvim";
      license = with licenses; [ mit ];
    };
  };
  icon-picker-nvim = buildVimPluginFrom2Nix {
    pname = "icon-picker-nvim";
    version = "2022-08-28";
    src = fetchurl {
      url = "https://github.com/ziontee113/icon-picker.nvim/archive/0f3b2648f6f8e788bc8dfe37bc9bb18b565cfc3c.tar.gz";
      sha256 = "1a2mfd311bi9z19japb82am84wq5yk893y78qvi4q4z91lvw8vkf";
    };
    meta = with lib; {
      description = "This is a Neovim plugin that helps you pick Nerd Font Icons, Symbols & Emojis";
      homepage = "https://github.com/ziontee113/icon-picker.nvim";
      license = with licenses; [ mit ];
    };
  };
  syntax-tree-surfer = buildVimPluginFrom2Nix {
    pname = "syntax-tree-surfer";
    version = "2022-09-02";
    src = fetchurl {
      url = "https://github.com/ziontee113/syntax-tree-surfer/archive/97f2003836bac01af845c70d8365f8fe17b620a9.tar.gz";
      sha256 = "1h8cirqn1hdps1a7mhpgz5mjbd5wy2jg8wmdw620k9g3835ihvz3";
    };
    meta = with lib; {
      description = "A plugin for Neovim that helps you surf through your document and move elements around using the nvim-treesitter API";
      homepage = "https://github.com/ziontee113/syntax-tree-surfer";
      license = with licenses; [ mit ];
    };
  };
}
