{ lib, buildVimPluginFrom2Nix, fetchurl }:

{
  nvim-revJ-lua = buildVimPluginFrom2Nix {
    pname = "nvim-revJ-lua";
    version = "2021-09-12";
    src = fetchurl {
      url = "https://github.com/AckslD/nvim-revJ.lua/archive/97be0965f9a0944629ba67e5fd0b05b898d34e61.tar.gz";
      sha256 = "1ya10gh7abkydmchy5b8r83gfi9hcrba66scgwd1gb2y33ayqgnj";
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
    version = "2021-11-02";
    src = fetchurl {
      url = "https://github.com/CRAG666/code_runner.nvim/archive/88f58cf601fa2ba8b785fcad81437092d0414f1c.tar.gz";
      sha256 = "0zin1mxmwjr10i0azigvpvjx8k5hgvsd77rjz3pqgvyp08zgr1x0";
    };
    meta = with lib; {
      description = "The best code runner you could have, it is like the one in vscode but with super powers, it manages projects like in intellij but without being slow";
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
    version = "2021-12-02";
    src = fetchurl {
      url = "https://github.com/David-Kunz/jester/archive/2f99240f58fed74beac858249b1c0a5b1a79d3c6.tar.gz";
      sha256 = "090agnhfjgsi7k70ab1976m9g5nr9p4v1c8mvqnvdp6y96v0zw80";
    };
    meta = with lib; {
      description = "A Neovim plugin to easily run and debug Jest tests";
      homepage = "https://github.com/David-Kunz/jester";
      license = with licenses; [ unlicense ];
    };
  };
  aquarium-vim = buildVimPluginFrom2Nix {
    pname = "aquarium-vim";
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/FrenzyExists/aquarium-vim/archive/a21ca6bc5ef242d6552631683be6a84e46551d4d.tar.gz";
      sha256 = "1vzqhjajhibr3ighzfp166av0k2ggmmi0sn6nxqzbkby5swizplb";
    };
    meta = with lib; {
      description = "🌊 Aquarium, a simple vibrant dark theme for vim 🗒";
      homepage = "https://github.com/FrenzyExists/aquarium-vim";
      license = with licenses; [ mit ];
    };
  };
  nvim-ts-context-commentstring = buildVimPluginFrom2Nix {
    pname = "nvim-ts-context-commentstring";
    version = "2021-12-13";
    src = fetchurl {
      url = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring/archive/097df33c9ef5bbd3828105e4bee99965b758dc3f.tar.gz";
      sha256 = "1vmhz621k9i0x6i92869bg918bsnahhcsg36jyj07gwfh3b3vpz5";
    };
    meta = with lib; {
      description = "Neovim treesitter plugin for setting the commentstring based on the cursor location in a file";
      homepage = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring";
      license = with licenses; [ mit ];
    };
  };
  LuaSnip = buildVimPluginFrom2Nix {
    pname = "LuaSnip";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/L3MON4D3/LuaSnip/archive/1a026154832b19b8f58ad2c2751336321d7d6eb5.tar.gz";
      sha256 = "0k93i98pwcm430141z5c18851q78xzxxadafhl9nxg6whi12bqia";
    };
    meta = with lib; {
      description = "Snippet Engine for Neovim written in Lua";
      homepage = "https://github.com/L3MON4D3/LuaSnip";
      license = with licenses; [ asl20 ];
    };
  };
  OneTerm-nvim = buildVimPluginFrom2Nix {
    pname = "OneTerm-nvim";
    version = "2021-07-30";
    src = fetchurl {
      url = "https://github.com/LoricAndre/OneTerm.nvim/archive/bc8924571aa1438c7fa23ada509089aed3f382a1.tar.gz";
      sha256 = "17jgcymyhwlipy6di08v7fs72yaqhrnawdwfx0bi561ax22kzl2d";
    };
    meta = with lib; {
      description = "One terminal plugin to rule them all ! (eventually)";
      homepage = "https://github.com/LoricAndre/OneTerm.nvim";
    };
  };
  uwu-vim = buildVimPluginFrom2Nix {
    pname = "uwu-vim";
    version = "2021-12-10";
    src = fetchurl {
      url = "https://github.com/Mangeshrex/uwu.vim/archive/2b91dd9f817b3fba898b51492c404f136e11576c.tar.gz";
      sha256 = "1v8ppbl862b6hjsbrg4syv6gya59hxm1ldlrjyr3s9f0pd7xlcqd";
    };
    meta = with lib; {
      description = "🎨 A beautiful and dark vim colorscheme. ";
      homepage = "https://github.com/Mangeshrex/uwu.vim";
      license = with licenses; [ mit ];
    };
  };
  tidy-nvim = buildVimPluginFrom2Nix {
    pname = "tidy-nvim";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/mcauley-penney/tidy.nvim/archive/25715ac21fd620e97cd3cb0cdb36858c213a5d08.tar.gz";
      sha256 = "0ykdkcw53a8cfd2l4237mspvg7yd1ap1jscmv759wp8qzj1yy6j0";
    };
    meta = with lib; {
      description = "A small Neovim plugin to remove trailing whitespace and empty lines at end of file on every save";
      homepage = "https://github.com/mcauley-penney/tidy.nvim";
    };
  };
  vscode-nvim = buildVimPluginFrom2Nix {
    pname = "vscode-nvim";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/Mofiqul/vscode.nvim/archive/210fbab6d9ad1d1120226da8d61c96a17da8e5d4.tar.gz";
      sha256 = "026p553v190szdsgxjwq8kx5jnhm9hc10klwkynygjj0wjqlp06g";
    };
    meta = with lib; {
      description = "Neovim/Vim color scheme inspired by Dark+ and Light+ theme in Visual Studio Code";
      homepage = "https://github.com/Mofiqul/vscode.nvim";
      license = with licenses; [ mit ];
    };
  };
  nui-nvim = buildVimPluginFrom2Nix {
    pname = "nui-nvim";
    version = "2021-12-20";
    src = fetchurl {
      url = "https://github.com/MunifTanjim/nui.nvim/archive/5799279fc8da92b38291a0a42bdb64cd17c3b42f.tar.gz";
      sha256 = "0ky8y3wkf9m8v3m3vg5g5077nlrzh0kfw732q6c0ky1b55iy5lwd";
    };
    meta = with lib; {
      description = "UI Component Library for Neovim";
      homepage = "https://github.com/MunifTanjim/nui.nvim";
      license = with licenses; [ mit ];
    };
  };
  due-nvim = buildVimPluginFrom2Nix {
    pname = "due-nvim";
    version = "2021-07-04";
    src = fetchurl {
      url = "https://github.com/NFrid/due.nvim/archive/86b08fc1dbaa5b2dc1502827a9be150add114723.tar.gz";
      sha256 = "1kk5gmzhfwmh5vpz0f1qg3di8l3r9jl0vkaxdf3sza0ccmlk4kfl";
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
    version = "2021-10-20";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/doom-one.nvim/archive/169734e4dc29bb9cab2a608f7504b159621b58ff.tar.gz";
      sha256 = "0nliwkd58b41ni1x2n9hx6s3jlrl3zjprcjzqj09b0dnh17sl0ip";
    };
    meta = with lib; {
      description = "doom-emacs' doom-one Lua port for Neovim";
      homepage = "https://github.com/NTBBloodbath/doom-one.nvim";
      license = with licenses; [ mit ];
    };
  };
  galaxyline-nvim = buildVimPluginFrom2Nix {
    pname = "galaxyline-nvim";
    version = "2021-12-16";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/galaxyline.nvim/archive/5a2151da17d88403fe7ded65c07be266d8cbc800.tar.gz";
      sha256 = "1a4d3fn37xbjbz0ixp5dgc1hy2a2ni6djz87spmcblnp79b12w85";
    };
    meta = with lib; {
      description = "neovim statusline plugin written in lua ";
      homepage = "https://github.com/NTBBloodbath/galaxyline.nvim";
      license = with licenses; [ mit ];
    };
  };
  rest-nvim = buildVimPluginFrom2Nix {
    pname = "rest-nvim";
    version = "2021-12-20";
    src = fetchurl {
      url = "https://github.com/NTBBloodbath/rest.nvim/archive/9800b593034770fee5eb460ff0e8f0b13de83300.tar.gz";
      sha256 = "05psrmcj6psqcrda6p3wiw4a1630vxjwdbxw36bjk0jzbxwxn96f";
    };
    meta = with lib; {
      description = "A fast Neovim http client written in Lua";
      homepage = "https://github.com/NTBBloodbath/rest.nvim";
      license = with licenses; [ mit ];
    };
  };
  themer-lua = buildVimPluginFrom2Nix {
    pname = "themer-lua";
    version = "2021-11-07";
    src = fetchurl {
      url = "https://github.com/NarutoXY/themer.lua/archive/aefb059e0ec3368f5bada6cdaf0ab439558531c5.tar.gz";
      sha256 = "17b4bnzg0hx5i642ilb7jggx0x9bc7fm6im8nsi7q8379zis7rxb";
    };
    meta = with lib; {
      description = "A simple, minimal highlighter plugin for neovim";
      homepage = "https://github.com/NarutoXY/themer.lua";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-hybrid = buildVimPluginFrom2Nix {
    pname = "nvim-hybrid";
    version = "2021-07-31";
    src = fetchurl {
      url = "https://github.com/PHSix/nvim-hybrid/archive/4d605e89f228d370a70cf8e265d0543f3d2fc21a.tar.gz";
      sha256 = "0agya0grnz753xwpk7ibgs2xk6hf7rg26bqhf1wmk1rhjnrfrvph";
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
  DAPInstall-nvim = buildVimPluginFrom2Nix {
    pname = "DAPInstall-nvim";
    version = "2021-11-05";
    src = fetchurl {
      url = "https://github.com/Pocco81/DAPInstall.nvim/archive/dd09e9dd3a6e29f02ac171515b8a089fb82bb425.tar.gz";
      sha256 = "00y8s1qd2b2x96ighc1mybmrp4w53dz1k57042xq3fmz0zk28jvi";
    };
    meta = with lib; {
      description = "🦆 A NeoVim plugin for managing several debuggers for Nvim-dap";
      homepage = "https://github.com/Pocco81/DAPInstall.nvim";
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
    version = "2021-11-28";
    src = fetchurl {
      url = "https://github.com/RRethy/nvim-treesitter-textsubjects/archive/2368f8b0ee1f93ae05cdd37f318ed26ef62c8878.tar.gz";
      sha256 = "1fxdq6y75s756mni3dmzy0288hdxc8ckyl9qldypfsc4znv1mqb4";
    };
    meta = with lib; {
      description = "Location and syntax aware text objects which *do what you mean*";
      homepage = "https://github.com/RRethy/nvim-treesitter-textsubjects";
      license = with licenses; [ asl20 ];
    };
  };
  gruvy = buildVimPluginFrom2Nix {
    pname = "gruvy";
    version = "2021-12-01";
    src = fetchurl {
      url = "https://github.com/RishabhRD/gruvy/archive/17e1723d261acbc93d4d40ec42f07548261d11cb.tar.gz";
      sha256 = "0klxkxiwck0bm0vvg7cnyfp9kp7cydckgpji61663k81wq9aixa8";
    };
    meta = with lib; {
      description = "Gruvbuddy port independent of colorbuddy";
      homepage = "https://github.com/RishabhRD/gruvy";
    };
  };
  lspactions = buildVimPluginFrom2Nix {
    pname = "lspactions";
    version = "2021-11-15";
    src = fetchurl {
      url = "https://github.com/RishabhRD/lspactions/archive/78fb8c11c7a72af5a228bb3000e989141b66b968.tar.gz";
      sha256 = "1w7rhz1bb6spx37xbw4pgjs3kf349j5205ni4y7azpdcbgvsf9i8";
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
    version = "2021-10-20";
    src = fetchurl {
      url = "https://github.com/Xuyuanp/yanil/archive/b9adf1325636c103a0a4658bfcc6d52c67b9229f.tar.gz";
      sha256 = "0k30zaldynmpr4jdx8sq8ygdzf5a2g1w5cclhl1xkgy8hfmn5qmc";
    };
    meta = with lib; {
      description = "Yet Another Nerdtree In Lua";
      homepage = "https://github.com/Xuyuanp/yanil";
      license = with licenses; [ asl20 ];
    };
  };
  tabout-nvim = buildVimPluginFrom2Nix {
    pname = "tabout-nvim";
    version = "2021-12-15";
    src = fetchurl {
      url = "https://github.com/abecodes/tabout.nvim/archive/6ff556b1b2274c8ba3eaedbf62339789e79baca8.tar.gz";
      sha256 = "1gbfm1wibssmks1yy213jb8ii5x2765jxdk17q83xxf1l30kg695";
    };
    meta = with lib; {
      description = "tabout plugin for neovim";
      homepage = "https://github.com/abecodes/tabout.nvim";
      license = with licenses; [ unlicense ];
    };
  };
  neoline-vim = buildVimPluginFrom2Nix {
    pname = "neoline-vim";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/adelarsq/neoline.vim/archive/6ad1cc3e5429b6f52bed19460fda1e24c6e6c103.tar.gz";
      sha256 = "1fg7xsqfv74v37p6fn5k0bawi92h7bnsfmdpd1znwjlm5w9hvx4h";
    };
    meta = with lib; {
      description = "Status Line for Neovim focused on beauty and performance ✅";
      homepage = "https://github.com/adelarsq/neoline.vim";
      license = with licenses; [ mit ];
    };
  };
  apprentice-nvim = buildVimPluginFrom2Nix {
    pname = "apprentice-nvim";
    version = "2021-12-12";
    src = fetchurl {
      url = "https://github.com/adisen99/apprentice.nvim/archive/92d1e12bd98ff601328ae748534e7fd46017d900.tar.gz";
      sha256 = "1nckfcain5rfin2kpz9bm3gashgbkcg3pyxgfxzvlvygaxp4i8qc";
    };
    meta = with lib; {
      description = "Apprentice color scheme for Neovim written in Lua";
      homepage = "https://github.com/adisen99/apprentice.nvim";
      license = with licenses; [ mit ];
    };
  };
  codeschool-nvim = buildVimPluginFrom2Nix {
    pname = "codeschool-nvim";
    version = "2021-12-12";
    src = fetchurl {
      url = "https://github.com/adisen99/codeschool.nvim/archive/a6eb99d642d40b5f575cb585485780d8422c27d2.tar.gz";
      sha256 = "1g0yp369dn3hih9fh6v3n1xh0gqfn3jkm2fbjhzfgxsg8parr8mk";
    };
    meta = with lib; {
      description = "Codeschool colorscheme for neovim written in lua with treesitter and built-in lsp support";
      homepage = "https://github.com/adisen99/codeschool.nvim";
      license = with licenses; [ mit ];
    };
  };
  project-nvim = buildVimPluginFrom2Nix {
    pname = "project-nvim";
    version = "2021-11-06";
    src = fetchurl {
      url = "https://github.com/ahmedkhalf/project.nvim/archive/71d0e23dcfc43cfd6bb2a97dc5a7de1ab47a6538.tar.gz";
      sha256 = "0jc7wx1x70w29zgls117fj620misf2pgiwjki5kc6zk6xczcyazi";
    };
    meta = with lib; {
      description = "The superior project management solution for neovim";
      homepage = "https://github.com/ahmedkhalf/project.nvim";
      license = with licenses; [ asl20 ];
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
    version = "2021-12-02";
    src = fetchurl {
      url = "https://github.com/akinsho/flutter-tools.nvim/archive/9c7648234e382101e0a9d6b0f031869b52154833.tar.gz";
      sha256 = "0d8scrxin5kncfdgx5zm5hw0kzzp8wwbd6v7hvai9lqq80wrdbxv";
    };
    meta = with lib; {
      description = "Tools to help create flutter apps in neovim using the native lsp";
      homepage = "https://github.com/akinsho/flutter-tools.nvim";
      license = with licenses; [ mit ];
    };
  };
  toggleterm-nvim = buildVimPluginFrom2Nix {
    pname = "toggleterm-nvim";
    version = "2021-11-24";
    src = fetchurl {
      url = "https://github.com/akinsho/toggleterm.nvim/archive/265bbff68fbb8b2a5fb011272ec469850254ec9f.tar.gz";
      sha256 = "12ixg2wgbpl10mkyb626kmnwr86g4csk3kxrqy9lnf6m5nql762j";
    };
    meta = with lib; {
      description = "A neovim lua plugin to help easily manage multiple terminal windows";
      homepage = "https://github.com/akinsho/toggleterm.nvim";
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
  cmp-tmux = buildVimPluginFrom2Nix {
    pname = "cmp-tmux";
    version = "2021-12-20";
    src = fetchurl {
      url = "https://github.com/andersevenrud/cmp-tmux/archive/43a626173a775e4909338e0b6c2d9109b5f3bcda.tar.gz";
      sha256 = "0i426ms7cmaa6yjv2j76b058ysl1pxd032s1hjqcgcvqsqgiaxp0";
    };
    meta = with lib; {
      description = "Tmux completion source for nvim-cmp and nvim-compe";
      homepage = "https://github.com/andersevenrud/cmp-tmux";
      license = with licenses; [ mit ];
    };
  };
  nordic-nvim = buildVimPluginFrom2Nix {
    pname = "nordic-nvim";
    version = "2021-12-20";
    src = fetchurl {
      url = "https://github.com/andersevenrud/nordic.nvim/archive/c348fba712af0c15bfdf23b396fdcb0311dfbae9.tar.gz";
      sha256 = "15f0hamqwir28v11amdbppqmk7kpxcwp3f060jvcwp7y8cpq5d41";
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
  statusline-lua = buildVimPluginFrom2Nix {
    pname = "statusline-lua";
    version = "2021-09-28";
    src = fetchurl {
      url = "https://github.com/beauwilliams/statusline.lua/archive/0fb05f21dfdf383a82777e62947efd87a3532143.tar.gz";
      sha256 = "14xrlfwaa4699qxzqibdi5n7w6qz60vzccp4f8lizn5qgy228srx";
    };
    meta = with lib; {
      description = "A zero-config minimal statusline for neovim written in lua featuring awesome integrations and blazing speed!";
      homepage = "https://github.com/beauwilliams/statusline.lua";
      license = with licenses; [ mit ];
    };
  };
  nvim-luadev = buildVimPluginFrom2Nix {
    pname = "nvim-luadev";
    version = "2021-11-30";
    src = fetchurl {
      url = "https://github.com/bfredl/nvim-luadev/archive/862acd36430b61a69a52cbadf877a1057077afe9.tar.gz";
      sha256 = "0g9rnxbyshh8mnkg28c3im3nxbpnc4abdlqdbi7na6sm5hqbqb37";
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
  surround-nvim = buildVimPluginFrom2Nix {
    pname = "surround-nvim";
    version = "2021-12-16";
    src = fetchurl {
      url = "https://github.com/blackCauldron7/surround.nvim/archive/59a0ef7d7f8da05f9e03075186b6de754e85c42c.tar.gz";
      sha256 = "0i83pq6j7awdgpgk03258ghrndc6zf0a89frzjvs2hnsy7qx15cq";
    };
    meta = with lib; {
      description = "A surround text object plugin for neovim written in lua";
      homepage = "https://github.com/blackCauldron7/surround.nvim";
    };
  };
  vim-moonfly-colors = buildVimPluginFrom2Nix {
    pname = "vim-moonfly-colors";
    version = "2021-12-09";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-moonfly-colors/archive/7d8badd5e1355d7a1f33033249d6a286efcd0d47.tar.gz";
      sha256 = "0qxxgkxp2pwyzyc6hmc15n0yws6j06xr0kficj7v7d90xkzgr72p";
    };
    meta = with lib; {
      description = "A dark color scheme for Vim";
      homepage = "https://github.com/bluz71/vim-moonfly-colors";
      license = with licenses; [ mit ];
    };
  };
  vim-nightfly-guicolors = buildVimPluginFrom2Nix {
    pname = "vim-nightfly-guicolors";
    version = "2021-12-09";
    src = fetchurl {
      url = "https://github.com/bluz71/vim-nightfly-guicolors/archive/d75a30e3874a9746d563634010accae4c463dc22.tar.gz";
      sha256 = "0j41cfgj4gwaxkwr8430sw8hnkghp8nsbwsmhmpc32028xi8gflp";
    };
    meta = with lib; {
      description = "Another dark color scheme for Vim";
      homepage = "https://github.com/bluz71/vim-nightfly-guicolors";
      license = with licenses; [ mit ];
    };
  };
  catppuccin = buildVimPluginFrom2Nix {
    pname = "catppuccin";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/catppuccin/nvim/archive/263048b150df8d83b992c86809ee46aa5c0baf74.tar.gz";
      sha256 = "04wwp13w5qb0rbslll6zvqn18jyhi6svy4r92c9p0nnd5ivb9ny8";
    };
    meta = with lib; {
      description = "🍨 Catppuccin theme for NeoVim";
      homepage = "https://github.com/catppuccin/nvim";
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
  nvim-biscuits = buildVimPluginFrom2Nix {
    pname = "nvim-biscuits";
    version = "2021-11-12";
    src = fetchurl {
      url = "https://github.com/code-biscuits/nvim-biscuits/archive/15a0cb1273bd36d5a734210cdc3406fb4bcfb733.tar.gz";
      sha256 = "1jzdgnay2n07r3966w0v19yh34p60rdbbac8nfsg15fs188bbi88";
    };
    meta = with lib; {
      description = "A neovim port of Assorted Biscuits. Ends up with more supported languages too";
      homepage = "https://github.com/code-biscuits/nvim-biscuits";
      license = with licenses; [ mit ];
    };
  };
  nvim-go = buildVimPluginFrom2Nix {
    pname = "nvim-go";
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/crispgm/nvim-go/archive/b241709ceb27d1f8b6987c9b59f42e2e0441581f.tar.gz";
      sha256 = "0dgs7v5haxd3i2hivqqh80wnnflw67c7ibgi2z8q7bv7gd6lkdl4";
    };
    meta = with lib; {
      description = "A minimal implementation of Golang development plugin for Neovim";
      homepage = "https://github.com/crispgm/nvim-go";
      license = with licenses; [ mit ];
    };
  };
  nvim-tabline = buildVimPluginFrom2Nix {
    pname = "nvim-tabline";
    version = "2021-10-18";
    src = fetchurl {
      url = "https://github.com/crispgm/nvim-tabline/archive/d26d384eae4e052367ba83949e25396556f32598.tar.gz";
      sha256 = "10sw0h26kd6hzgs1x7v198i9r9har9lh7jzh1yqpa7rf7nb26hw1";
    };
    meta = with lib; {
      description = "nvim port of tabline.vim with Lua";
      homepage = "https://github.com/crispgm/nvim-tabline";
      license = with licenses; [ mit ];
    };
  };
  telescope-heading-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-heading-nvim";
    version = "2021-12-02";
    src = fetchurl {
      url = "https://github.com/crispgm/telescope-heading.nvim/archive/59b3ada4fee3168b50f452366b2dd47c8f0b8076.tar.gz";
      sha256 = "1k33hghccs3mcml8dfn74m50hxlgkwzy50b97xq9qjxlgqa1jcl7";
    };
    meta = with lib; {
      description = "An extension for telescope.nvim that allows you to switch between headings";
      homepage = "https://github.com/crispgm/telescope-heading.nvim";
      license = with licenses; [ mit ];
    };
  };
  neogen = buildVimPluginFrom2Nix {
    pname = "neogen";
    version = "2021-12-08";
    src = fetchurl {
      url = "https://github.com/danymat/neogen/archive/19a222a080a3f6d7540fa37f925f147a309824df.tar.gz";
      sha256 = "0wqrdjbhh60zhx1iia2qvqcpnmhzw0ag083l5qljx09i41kwqdbj";
    };
    meta = with lib; {
      description = "A better annotation generator. Supports multiple languages and annotation conventions";
      homepage = "https://github.com/danymat/neogen";
      license = with licenses; [ gpl3Only ];
    };
  };
  bubbly-nvim = buildVimPluginFrom2Nix {
    pname = "bubbly-nvim";
    version = "2021-11-15";
    src = fetchurl {
      url = "https://github.com/datwaft/bubbly.nvim/archive/e5810ac2718201d3476b67be665dfbe82ce09dcc.tar.gz";
      sha256 = "1mcxb675xmppwasc0xg6216nj4a4rhd0s9bw801f50qvbrg5i2rw";
    };
    meta = with lib; {
      description = "Bubbly statusline for neovim";
      homepage = "https://github.com/datwaft/bubbly.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-markdown-preview = buildVimPluginFrom2Nix {
    pname = "nvim-markdown-preview";
    version = "2021-12-07";
    src = fetchurl {
      url = "https://github.com/davidgranstrom/nvim-markdown-preview/archive/940c856932ad81e784f16a47e24193821a8fa8fd.tar.gz";
      sha256 = "06wqdr3ymkwvpbjg5qlcg7x6p0jn37sp8802kl4i1k07jy45n3rm";
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
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/davidgranstrom/scnvim/archive/d95785b5f3ec81937b7d4ed2cab711a8c69b87b0.tar.gz";
      sha256 = "1raybwjs2xr388cm1k9lx8llqmh3akki13wabmkpfkkhf996a166";
    };
    meta = with lib; {
      description = "Neovim frontend for SuperCollider";
      homepage = "https://github.com/davidgranstrom/scnvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-snippy = buildVimPluginFrom2Nix {
    pname = "nvim-snippy";
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/dcampos/nvim-snippy/archive/f6673057a3ba0fee4a09c9607a7f8c138eec3f8e.tar.gz";
      sha256 = "0q66j9pz5phzs3iznl8jc6q86i3j7h5zlkfqllyisgzd3wf4znq3";
    };
    meta = with lib; {
      description = "Snippet plugin for Neovim";
      homepage = "https://github.com/dcampos/nvim-snippy";
      license = with licenses; [ mit ];
    };
  };
  bullets-vim = buildVimPluginFrom2Nix {
    pname = "bullets-vim";
    version = "2021-06-18";
    src = fetchurl {
      url = "https://github.com/dkarter/bullets.vim/archive/39d90278a20e754105a9b628f8b1bd430e5d5713.tar.gz";
      sha256 = "0hyjlq3rkgry6jj53hayi39kv2qdy6afg6vfb19zan3r489bzsq1";
    };
    meta = with lib; {
      description = "🔫 Bullets.vim is a Vim/NeoVim plugin for automated bullet lists";
      homepage = "https://github.com/dkarter/bullets.vim";
    };
  };
  mini-nvim = buildVimPluginFrom2Nix {
    pname = "mini-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/echasnovski/mini.nvim/archive/5dbb950194ae4038d87b6fb3e01d204b9609e0f6.tar.gz";
      sha256 = "16knr6y2q15wwzy94w19gn1jal5ikfx6kymg5lkcda5x1d64mql0";
    };
    meta = with lib; {
      description = "Neovim plugin with collection of minimal, independent, and fast Lua modules dedicated to improve Neovim (version 0.5 and higher) experience";
      homepage = "https://github.com/echasnovski/mini.nvim";
      license = with licenses; [ mit ];
    };
  };
  goimpl-nvim = buildVimPluginFrom2Nix {
    pname = "goimpl-nvim";
    version = "2021-12-07";
    src = fetchurl {
      url = "https://github.com/edolphin-ydf/goimpl.nvim/archive/90618773b151c7cc05460c26d87ffa00648f0071.tar.gz";
      sha256 = "1xsywfx1v9dxphk6z6w80dpgzwaf53ks0l13iyckxc8v6y3cdw3k";
    };
    meta = with lib; {
      description = "Generate stub for interface on a type";
      homepage = "https://github.com/edolphin-ydf/goimpl.nvim";
    };
  };
  clipboard-image-nvim = buildVimPluginFrom2Nix {
    pname = "clipboard-image-nvim";
    version = "2021-12-07";
    src = fetchurl {
      url = "https://github.com/ekickx/clipboard-image.nvim/archive/b3856386bde5909ae81f13dbb194d3fc036e2889.tar.gz";
      sha256 = "13i6nqjvagxqxw3yxl3lajg4v8cjaf8p7hjd056i6cbn2crf1svb";
    };
    meta = with lib; {
      description = "Neovim Lua plugin to paste image from clipboard";
      homepage = "https://github.com/ekickx/clipboard-image.nvim";
      license = with licenses; [ mit ];
    };
  };
  glow-nvim = buildVimPluginFrom2Nix {
    pname = "glow-nvim";
    version = "2021-12-14";
    src = fetchurl {
      url = "https://github.com/ellisonleao/glow.nvim/archive/d86281307ce2898d0fcd85ecb0865fc1dd2f2578.tar.gz";
      sha256 = "1wgshkgank2qv65a5zrhlfdyvsaqwi201hv1j5ylfswi7fa390vg";
    };
    meta = with lib; {
      description = "A markdown preview directly in your neovim";
      homepage = "https://github.com/ellisonleao/glow.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-lastplace = buildVimPluginFrom2Nix {
    pname = "nvim-lastplace";
    version = "2021-10-15";
    src = fetchurl {
      url = "https://github.com/ethanholz/nvim-lastplace/archive/30fe710d4417cc67950bbce6b2ec2ac0ff430e12.tar.gz";
      sha256 = "0mlwzww2pkkswlgc3548azq0k34arcivpmaixr8dm069g0cqyk0m";
    };
    meta = with lib; {
      description = "A Lua rewrite of vim-lastplace";
      homepage = "https://github.com/ethanholz/nvim-lastplace";
      license = with licenses; [ mit ];
    };
  };
  feline-nvim = buildVimPluginFrom2Nix {
    pname = "feline-nvim";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/feline-nvim/feline.nvim/archive/29f5cbfcecf563df84ac3b0e31e54e7b23e5331f.tar.gz";
      sha256 = "0x3vipzxy5gmdsxa8mdn8fbyywxhx56d4lbx6x3lgk351xg076qx";
    };
    meta = with lib; {
      description = "A minimal, stylish and customizable statusline for Neovim written in Lua";
      homepage = "https://github.com/feline-nvim/feline.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  renamer-nvim = buildVimPluginFrom2Nix {
    pname = "renamer-nvim";
    version = "2021-12-19";
    src = fetchurl {
      url = "https://github.com/filipdutescu/renamer.nvim/archive/814ddbb11602e3c8b2af166b4d1e029272ab796f.tar.gz";
      sha256 = "10pbmn2iz01h1f5m2m3cpc07k4ffjdci5n5y9sff42vxk5yvnblg";
    };
    meta = with lib; {
      description = "VS Code-like renaming UI for Neovim, writen in Lua";
      homepage = "https://github.com/filipdutescu/renamer.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  lua-dev-nvim = buildVimPluginFrom2Nix {
    pname = "lua-dev-nvim";
    version = "2021-12-10";
    src = fetchurl {
      url = "https://github.com/folke/lua-dev.nvim/archive/4331626b02f636433b504b9ab6a8c11fb9de4a24.tar.gz";
      sha256 = "0m7cgff48k8skxwzhvsc6ycsw1pqqhmcckfdzx75jqibga94i7gc";
    };
    meta = with lib; {
      description = "💻  Dev setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API";
      homepage = "https://github.com/folke/lua-dev.nvim";
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
    version = "2021-12-13";
    src = fetchurl {
      url = "https://github.com/gbprod/cutlass.nvim/archive/ecb8b58d240df16f6079f69133c606aa072a4336.tar.gz";
      sha256 = "12kbzh3014r1jwzh0in6i0wrbz2nsimzd307zixd94l2pilx4c70";
    };
    meta = with lib; {
      description = "Plugin that adds a 'cut' operation separate from 'delete' ";
      homepage = "https://github.com/gbprod/cutlass.nvim";
      license = with licenses; [ wtfpl ];
    };
  };
  substitute-nvim = buildVimPluginFrom2Nix {
    pname = "substitute-nvim";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/gbprod/substitute.nvim/archive/10422a2304c826571aeee71c48fc7e38675739c2.tar.gz";
      sha256 = "1r4653ppyd3lj4kgmai6qns1lkj05k9aagfjf2s2a1rl83qj7f6c";
    };
    meta = with lib; {
      description = "Neovim plugin introducing a new operator motions to quickly replace text";
      homepage = "https://github.com/gbprod/substitute.nvim";
      license = with licenses; [ wtfpl ];
    };
  };
  nvim-commaround = buildVimPluginFrom2Nix {
    pname = "nvim-commaround";
    version = "2021-12-16";
    src = fetchurl {
      url = "https://github.com/gennaro-tedesco/nvim-commaround/archive/f3fd6816f6c26658dae22b7d3396c118d1d500cc.tar.gz";
      sha256 = "1gc6s95cj0q1d0nmpsxanx4aawd0fb1gzjcfmjav7mz7xlag7jqc";
    };
    meta = with lib; {
      description = "nvim plugin to toggle comments on and off";
      homepage = "https://github.com/gennaro-tedesco/nvim-commaround";
      license = with licenses; [ mit ];
    };
  };
  firenvim = buildVimPluginFrom2Nix {
    pname = "firenvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/glacambre/firenvim/archive/804d6c4bbbdc7f4b679617f88f8136e3b38bee37.tar.gz";
      sha256 = "0b8104nns1538la0ris7sij4sqk58lkr29g00d89j3hh05s9bg8n";
    };
    meta = with lib; {
      description = "Embed Neovim in Chrome, Firefox, Thunderbird and many other pieces of software";
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
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/goolord/alpha-nvim/archive/914efd31aa5c8ccfcbce745deb95981e7ebaeb96.tar.gz";
      sha256 = "1i46lxl6q9z82lxbv294jl3kb6kqicw0ar47dkj023cg158hhz9p";
    };
    meta = with lib; {
      description = "a lua powered greeter like vim-startify / dashboard-nvim";
      homepage = "https://github.com/goolord/alpha-nvim";
      license = with licenses; [ mit ];
    };
  };
  reaper-keys = buildVimPluginFrom2Nix {
    pname = "reaper-keys";
    version = "2021-08-23";
    src = fetchurl {
      url = "https://github.com/gwatcha/reaper-keys/archive/8435f68d16d75bf1358128f5cab62318c3c79b6f.tar.gz";
      sha256 = "1b2ik3zps0gmyhjcp0pw4m7iiyi0fcyw044lzi7h2b87r5niwjii";
    };
    meta = with lib; {
      description = " vim-bindings for Reaper";
      homepage = "https://github.com/gwatcha/reaper-keys";
      license = with licenses; [ mit ];
    };
  };
  fcitx-nvim = buildVimPluginFrom2Nix {
    pname = "fcitx-nvim";
    version = "2021-12-11";
    src = fetchurl {
      url = "https://github.com/h-hg/fcitx.nvim/archive/045a2720a65604a645e0f0ca217075e83b6b375b.tar.gz";
      sha256 = "0rccpwqmklphwrbrvsyaxf90p7gxkjgig7khfwzdgxpjvhhaqn62";
    };
    meta = with lib; {
      description = "A Neovim plugin writing in Lua to switch and restore fcitx state for each buffer";
      homepage = "https://github.com/h-hg/fcitx.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-startup-lua = buildVimPluginFrom2Nix {
    pname = "nvim-startup-lua";
    version = "2021-10-10";
    src = fetchurl {
      url = "https://github.com/henriquehbr/nvim-startup.lua/archive/3b21882d59fa4e06b2e138156a42dea3f6fea212.tar.gz";
      sha256 = "08wgv892isdcx1lp54kx8c1k7j70xzlcx6ik987rcw9p6baviv55";
    };
    meta = with lib; {
      description = "Displays neovim startup time";
      homepage = "https://github.com/henriquehbr/nvim-startup.lua";
      license = with licenses; [ mit ];
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
    version = "2021-05-20";
    src = fetchurl {
      url = "https://github.com/hylang/vim-hy/archive/3610c0039a8819ace03c10c246012b2703928fd6.tar.gz";
      sha256 = "0x5wsq9s81szl06sc6a1vakqx8ybgmvbi5l6himlzajj2gj6n78a";
    };
    meta = with lib; {
      description = "Vim files and plugins for Hy";
      homepage = "https://github.com/hylang/vim-hy";
    };
  };
  fzf-lua = buildVimPluginFrom2Nix {
    pname = "fzf-lua";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/ibhagwan/fzf-lua/archive/5396fa198f4cbe31cb2763f36b6aa2cce9b86953.tar.gz";
      sha256 = "1mk5lk9d7shb0p453nsw8rr7ccpwqivx5hzzk160g708z6xfidmm";
    };
    meta = with lib; {
      description = "Improved fzf.vim written in lua";
      homepage = "https://github.com/ibhagwan/fzf-lua";
      license = with licenses; [ agpl3Only ];
    };
  };
  vim-fish-inkch = buildVimPluginFrom2Nix {
    pname = "vim-fish-inkch";
    version = "2021-05-21";
    src = fetchurl {
      url = "https://github.com/inkch/vim-fish/archive/9e2472a8f3f3953f23343b3e053d80ad0ce6a25f.tar.gz";
      sha256 = "0qki316p7ff145i2vls6va0izjgvhswl56chxnlnv0sjw4v0vayp";
    };
    meta = with lib; {
      description = "Vim support for editing fish scripts";
      homepage = "https://github.com/inkch/vim-fish";
      license = with licenses; [ mit ];
    };
  };
  fm-nvim = buildVimPluginFrom2Nix {
    pname = "fm-nvim";
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/is0n/fm-nvim/archive/d5bcc9d83731a29d89f23d61be9cfa89a19493be.tar.gz";
      sha256 = "13kmba1ljza5d1ahg040r0wawvvk2v2g580nlnvj2bbr824syqcc";
    };
    meta = with lib; {
      description = "🗂 Neovim plugin that lets you use your favorite terminal file managers (and fuzzy finders) from within Neovim";
      homepage = "https://github.com/is0n/fm-nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  jaq-nvim = buildVimPluginFrom2Nix {
    pname = "jaq-nvim";
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/is0n/jaq-nvim/archive/9b46f9b68bcb0e06031ae1c3e0c8d9e09be32c3a.tar.gz";
      sha256 = "0vh9cjyig97wdrdhf1729n9phma85qpvq3f5rkxsjimr100v4yd6";
    };
    meta = with lib; {
      description = "⚙️ Just Another Quickrun Plugin for Neovim in Lua";
      homepage = "https://github.com/is0n/jaq-nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  modus-theme-vim = buildVimPluginFrom2Nix {
    pname = "modus-theme-vim";
    version = "2021-11-09";
    src = fetchurl {
      url = "https://github.com/ishan9299/modus-theme-vim/archive/0c91d5218b107fa35c83d3cb7458e09eb1798946.tar.gz";
      sha256 = "08xpygxwdv8ngr8hdzx14zafw8lvhm323cm3ps360dsi5pmcv6py";
    };
    meta = with lib; {
      description = "Port of modus-themes in neovim";
      homepage = "https://github.com/ishan9299/modus-theme-vim";
      license = with licenses; [ mit ];
    };
  };
  mkdnflow-nvim = buildVimPluginFrom2Nix {
    pname = "mkdnflow-nvim";
    version = "2021-11-10";
    src = fetchurl {
      url = "https://github.com/jakewvincent/mkdnflow.nvim/archive/47450da5af78c38eb48a3b7b8a4d19f361ae2027.tar.gz";
      sha256 = "13jkga9yzxr579cs2v43cmpx63i8lykwsp8ix0m60afpyxk0rd69";
    };
    meta = with lib; {
      description = "Tools for markdown notebook navigation and management";
      homepage = "https://github.com/jakewvincent/mkdnflow.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  texmagic-nvim = buildVimPluginFrom2Nix {
    pname = "texmagic-nvim";
    version = "2021-09-01";
    src = fetchurl {
      url = "https://github.com/jakewvincent/texmagic.nvim/archive/f52a37bc0132ec768fc68e4222fc6ac84483afe5.tar.gz";
      sha256 = "16kfi6ibcbbi2hfd1bqkfnh28g0qw9wvibv478fsf3bpxg63zfqm";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/jakewvincent/texmagic.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-magic = buildVimPluginFrom2Nix {
    pname = "nvim-magic";
    version = "2021-10-09";
    src = fetchurl {
      url = "https://github.com/jameshiew/nvim-magic/archive/6c04695c2f4a6d15dbb3d370328865878e6fbc29.tar.gz";
      sha256 = "1zkhks3nz88xbh8n2rjp6sl58kbxcsq2zbr1hj9xr8zbxq4p7p1j";
    };
    meta = with lib; {
      description = ":genie: Pluggable framework for using AI code assistance in Neovim";
      homepage = "https://github.com/jameshiew/nvim-magic";
      license = with licenses; [ mit ];
    };
  };
  instant-nvim = buildVimPluginFrom2Nix {
    pname = "instant-nvim";
    version = "2021-10-26";
    src = fetchurl {
      url = "https://github.com/jbyuki/instant.nvim/archive/c02d72267b12130609b7ad39b76cf7f4a3bc9554.tar.gz";
      sha256 = "1sdd8sw2k6vhf8146288dmhxm4kmmkdby0y64y4di6dxf3nr39ps";
    };
    meta = with lib; {
      description = "collaborative editing in Neovim using built-in capabilities";
      homepage = "https://github.com/jbyuki/instant.nvim";
      license = with licenses; [ mit ];
    };
  };
  nabla-nvim = buildVimPluginFrom2Nix {
    pname = "nabla-nvim";
    version = "2021-11-08";
    src = fetchurl {
      url = "https://github.com/jbyuki/nabla.nvim/archive/549db603607c8ac8509e54482a6339a1d3286af6.tar.gz";
      sha256 = "14289hxj2ir54gmmcl36d494r1r8y76wzwr9fn0ayhqqrsl9pkjw";
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
    version = "2021-06-14";
    src = fetchurl {
      url = "https://github.com/jghauser/auto-pandoc.nvim/archive/f579c40e245d778b95d65fad3cf8a95de1921993.tar.gz";
      sha256 = "1wjh6my5lms4hmxrr3pd7smd5y3i6wmw8jc7r38dwbjdy4bx443m";
    };
    meta = with lib; {
      description = "A neovim plugin leveraging pandoc to help you convert your markdown files. It takes pandoc options from yaml blocks";
      homepage = "https://github.com/jghauser/auto-pandoc.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  follow-md-links-nvim = buildVimPluginFrom2Nix {
    pname = "follow-md-links-nvim";
    version = "2021-06-12";
    src = fetchurl {
      url = "https://github.com/jghauser/follow-md-links.nvim/archive/4680cd445645e6c49d8436a346dd39e2e614bee9.tar.gz";
      sha256 = "1ca6hdnl1x4w9s14907wwjnr2vqqclydb0wg6brnc91gf55i4dma";
    };
    meta = with lib; {
      description = "A neovim plugin allowing you to easily follow local markdown links";
      homepage = "https://github.com/jghauser/follow-md-links.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  kitty-runner-nvim = buildVimPluginFrom2Nix {
    pname = "kitty-runner-nvim";
    version = "2021-06-16";
    src = fetchurl {
      url = "https://github.com/jghauser/kitty-runner.nvim/archive/863a306e789f6351f8d98467b978337043d6e097.tar.gz";
      sha256 = "1mv17wpf4ky530xzzs59mri74nnfr523xy08qgbkkwdv8p43hdlm";
    };
    meta = with lib; {
      description = "A neovim plugin allowing you to easily send lines from the current buffer to another kitty terminal";
      homepage = "https://github.com/jghauser/kitty-runner.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  mkdir-nvim = buildVimPluginFrom2Nix {
    pname = "mkdir-nvim";
    version = "2021-06-20";
    src = fetchurl {
      url = "https://github.com/jghauser/mkdir.nvim/archive/caa4178dae081850230f2f05699fef8e83b59ded.tar.gz";
      sha256 = "1j6drx0s19z2gjvj3f7mfz60q0zd4zxffvgw3l7baxmphm9ajhgn";
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
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/null-ls.nvim/archive/b7de45a0e62bf93f19db2b43ecded48c5763248d.tar.gz";
      sha256 = "0c1ha378yh3822pgnmvd53zgrpjnil0368vhb52wwvbdcy11sps0";
    };
    meta = with lib; {
      description = "Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua";
      homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
    };
  };
  mdeval-nvim = buildVimPluginFrom2Nix {
    pname = "mdeval-nvim";
    version = "2021-10-02";
    src = fetchurl {
      url = "https://github.com/jubnzv/mdeval.nvim/archive/8bd902e9e1bca70fb818a72b3fa20056bbf283ab.tar.gz";
      sha256 = "10w8mspwmbbcbaz6mcxmw8inj143ajfbwsjbzjj38qmfa8qnbb8z";
    };
    meta = with lib; {
      description = "A Neovim plugin that evaluates code blocks inside documents";
      homepage = "https://github.com/jubnzv/mdeval.nvim";
      license = with licenses; [ mit ];
    };
  };
  virtual-types-nvim = buildVimPluginFrom2Nix {
    pname = "virtual-types-nvim";
    version = "2021-11-06";
    src = fetchurl {
      url = "https://github.com/jubnzv/virtual-types.nvim/archive/9ef9f31c58cc9deb914ee728b8bda8f217f9d1c7.tar.gz";
      sha256 = "0v6csm4s9gnhcym3h87nmsm4hxdiwhlgwakjjwmi0hqy0n389shb";
    };
    meta = with lib; {
      description = "A Neovim plugin that shows type annotations as virtual text";
      homepage = "https://github.com/jubnzv/virtual-types.nvim";
      license = with licenses; [ mit ];
    };
  };
  telescope-zoxide = buildVimPluginFrom2Nix {
    pname = "telescope-zoxide";
    version = "2021-10-21";
    src = fetchurl {
      url = "https://github.com/jvgrootveld/telescope-zoxide/archive/b51b7f4ba0e2a08bc764fb2ee39e0bc68eec79b5.tar.gz";
      sha256 = "1piv2lqiyjha81bknnksadyrxdbc6yn03gb03raxq4ib6rcfk0fa";
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
  nvim-config-local = buildVimPluginFrom2Nix {
    pname = "nvim-config-local";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/klen/nvim-config-local/archive/3a9c4c7d4be706f524a11168dd78c4efbfd3d644.tar.gz";
      sha256 = "1rp03n7k8mwsjsxya8kabajb39q1ckaral4vc4zsy8ahp7kbhp2w";
    };
    meta = with lib; {
      description = "Secure load local config files for neovim";
      homepage = "https://github.com/klen/nvim-config-local";
      license = with licenses; [ mit ];
    };
  };
  vacuumline-nvim = buildVimPluginFrom2Nix {
    pname = "vacuumline-nvim";
    version = "2021-08-11";
    src = fetchurl {
      url = "https://github.com/konapun/vacuumline.nvim/archive/cdbd3e931d062f1ce6b8fb1a22e87ea5754b654a.tar.gz";
      sha256 = "1w4im5hlx9zpcym584ym5cklr388g72hx5d8249ff2b0pj2s7np9";
    };
    meta = with lib; {
      description = "A prebuilt configuration for galaxyline inspired by airline";
      homepage = "https://github.com/konapun/vacuumline.nvim";
      license = with licenses; [ mit ];
    };
  };
  orgmode = buildVimPluginFrom2Nix {
    pname = "orgmode";
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/nvim-orgmode/orgmode/archive/8e3edfa5066db396a2f51f2e90f56c5914b00840.tar.gz";
      sha256 = "1y74xdc79daz5br3kn3c3fa07ns108jp2s92a68lmcsr8dy0c40z";
    };
    meta = with lib; {
      description = "Orgmode clone written in Lua for Neovim 0.5+";
      homepage = "https://github.com/nvim-orgmode/orgmode";
      license = with licenses; [ mit ];
    };
  };
  substrata-nvim = buildVimPluginFrom2Nix {
    pname = "substrata-nvim";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/kvrohit/substrata.nvim/archive/53146957d604db6cc2dc3422e48e9b713a56a9b5.tar.gz";
      sha256 = "18rm16q26lkqyq9cv4smrbin6qipb8w5v3bhzfm0jivf33gzd0k4";
    };
    meta = with lib; {
      description = " A cold, dark color scheme for Neovim";
      homepage = "https://github.com/kvrohit/substrata.nvim";
    };
  };
  blue-moon = buildVimPluginFrom2Nix {
    pname = "blue-moon";
    version = "2021-12-05";
    src = fetchurl {
      url = "https://github.com/kyazdani42/blue-moon/archive/fb0f23237be972dcdfd6e2ac9cf5c6a95d6d80b5.tar.gz";
      sha256 = "1dyl1m3l984g1xlzpn7iwj5mn9izzvvcm5qz3nn9znwvb1s48wnl";
    };
    meta = with lib; {
      description = "A dark color scheme for Neovim derived from palenight and carbonight";
      homepage = "https://github.com/kyazdani42/blue-moon";
    };
  };
  litee-nvim = buildVimPluginFrom2Nix {
    pname = "litee-nvim";
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/ldelossa/litee.nvim/archive/1734728b2e7d1700b53a6747bceeb79bad0bf3e3.tar.gz";
      sha256 = "0s9w3ph2974mf41b7hbak5n4smwiz1c31zm4k33zcz876296qfyv";
    };
    meta = with lib; {
      description = "Neovim's missing IDE features";
      homepage = "https://github.com/ldelossa/litee.nvim";
    };
  };
  vimdark = buildVimPluginFrom2Nix {
    pname = "vimdark";
    version = "2021-11-24";
    src = fetchurl {
      url = "https://github.com/ldelossa/vimdark/archive/d227bd0ebb48bb36baf87528214d67fb4eb537ab.tar.gz";
      sha256 = "1aywlxrc0hz45k72dqkvspikrrjfn0qaq0kp2fkiw9a99xsgymy4";
    };
    meta = with lib; {
      description = "A dark theme for vim based on vim-monotonic and chrome's dark reader";
      homepage = "https://github.com/ldelossa/vimdark";
      license = with licenses; [ mit ];
    };
  };
  spellsitter-nvim = buildVimPluginFrom2Nix {
    pname = "spellsitter-nvim";
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/lewis6991/spellsitter.nvim/archive/d2e280aa3a3e239b12e24d96863d48744a76d764.tar.gz";
      sha256 = "1dckc0mdyzpfg7dyzv1fapvbmcy83z2afaxs6yfypqx4rd8dskzp";
    };
    meta = with lib; {
      description = "Treesitter powered spellchecker";
      homepage = "https://github.com/lewis6991/spellsitter.nvim";
      license = with licenses; [ mit ];
    };
  };
  github-colors = buildVimPluginFrom2Nix {
    pname = "github-colors";
    version = "2021-10-04";
    src = fetchurl {
      url = "https://github.com/lourenci/github-colors/archive/b395297a9909abe5f749e6c336e92e7f87631efd.tar.gz";
      sha256 = "0xkc3sx6riqsz0y194nqb3nz6aii85iz0zczdxyv4jqkim5sicli";
    };
    meta = with lib; {
      description = "Yet another GitHub colorscheme";
      homepage = "https://github.com/lourenci/github-colors";
      license = with licenses; [ mit ];
    };
  };
  cmp-rg = buildVimPluginFrom2Nix {
    pname = "cmp-rg";
    version = "2021-12-03";
    src = fetchurl {
      url = "https://github.com/lukas-reineke/cmp-rg/archive/7a95aa7eefceed1eac6907889d1d8812b6b051d4.tar.gz";
      sha256 = "0gji56qr3jfzrf8q6b4qn2iin47prarj70hjz1vzfblcciz99hwh";
    };
    meta = with lib; {
      description = "ripgrep source for nvim-cmp";
      homepage = "https://github.com/lukas-reineke/cmp-rg";
      license = with licenses; [ mit ];
    };
  };
  nnn-nvim = buildVimPluginFrom2Nix {
    pname = "nnn-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/luukvbaal/nnn.nvim/archive/53086c21ae7e96c9c1f834ddde9ee961105a4e47.tar.gz";
      sha256 = "09fmkkfjz09c3bqdpq014kd2szx840446qyaa1fpbai511bs602d";
    };
    meta = with lib; {
      description = "File manager for Neovim powered by nnn";
      homepage = "https://github.com/luukvbaal/nnn.nvim";
      license = with licenses; [ bsd3 ];
    };
  };
  plugin-template-nvim = buildVimPluginFrom2Nix {
    pname = "plugin-template-nvim";
    version = "2021-04-24";
    src = fetchurl {
      url = "https://github.com/m00qek/plugin-template.nvim/archive/a5770ca714af2506cb6c722b9201a74f9fec0acf.tar.gz";
      sha256 = "135lwlvi9zf2z2ff4z9nbdgxa1l7jy0cnddmh22qna4kx855l91y";
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
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/marko-cerovac/material.nvim/archive/01bc589748549bb72cb63c61de9712c7d8e52f51.tar.gz";
      sha256 = "0s8syw5vjp86c2fjjb44www84ykdfxzhwrpwpshfw276b2x0b9y9";
    };
    meta = with lib; {
      description = ":trident: Material colorscheme for NeoVim written in Lua with built-in support for native LSP, TreeSitter and many more plugins";
      homepage = "https://github.com/marko-cerovac/material.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  JABS-nvim = buildVimPluginFrom2Nix {
    pname = "JABS-nvim";
    version = "2021-09-22";
    src = fetchurl {
      url = "https://github.com/matbme/JABS.nvim/archive/936629d6b1658cc5351be5e26bf84ae8a4ffd601.tar.gz";
      sha256 = "1qwb9crs35bcwvrmnsckpiap11zpmy9cabiarl5dkl80zgq3wfv8";
    };
    meta = with lib; {
      description = "Just Another Buffer Switcher for Neovim";
      homepage = "https://github.com/matbme/JABS.nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  zenbones-nvim = buildVimPluginFrom2Nix {
    pname = "zenbones-nvim";
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/mcchrish/zenbones.nvim/archive/817c9f62c0e4270d3de5361f7c435783d5f77df1.tar.gz";
      sha256 = "1452faxni82j4q7fij9zh7zshmyjd2chl42j10hykhmpmqivcr6x";
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
    version = "2021-12-19";
    src = fetchurl {
      url = "https://github.com/michaelb/sniprun/archive/4ab5996d2d2bbfabee9c5711e00078ee99d6817d.tar.gz";
      sha256 = "1z5k01r5fsq68zbwf3d3n82yfk0ix52p3wygfhx80pg121ahc4qr";
    };
    meta = with lib; {
      description = "A neovim plugin to run lines/blocs of code (independently of the rest of the file), supporting multiples languages";
      homepage = "https://github.com/michaelb/sniprun";
      license = with licenses; [ mit ];
    };
  };
  iswap-nvim = buildVimPluginFrom2Nix {
    pname = "iswap-nvim";
    version = "2021-11-20";
    src = fetchurl {
      url = "https://github.com/mizlan/iswap.nvim/archive/d584e1fab565301c209796b12ba6c958e824f0c6.tar.gz";
      sha256 = "110gxlib2mb67iwf8qvnjww5m79br592sxk70fk5lbbla71jlglr";
    };
    meta = with lib; {
      description = "Interactively select and swap function arguments, list elements, and more. Powered by tree-sitter";
      homepage = "https://github.com/mizlan/iswap.nvim";
      license = with licenses; [ asl20 ];
    };
  };
  babelfish-nvim = buildVimPluginFrom2Nix {
    pname = "babelfish-nvim";
    version = "2021-09-14";
    src = fetchurl {
      url = "https://github.com/mjlbach/babelfish.nvim/archive/a057957520b0d4b9236d4292443f3eb948bcc54e.tar.gz";
      sha256 = "035i10asvqxqksydjwx1ag0cnrv76241pmbysc2v8kdah5c4inlf";
    };
    meta = with lib; {
      description = "The answer to the ultimate question is :help 42";
      homepage = "https://github.com/mjlbach/babelfish.nvim";
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
    version = "2021-03-22";
    src = fetchurl {
      url = "https://github.com/monaqa/dial.nvim/archive/3390a2b304c7c8d22f15797aaca34b6bb3b39c73.tar.gz";
      sha256 = "0cznply9bj8pbg9r32rdx04vdrmrn2vn38l47z5yni9p3cri92ky";
    };
    meta = with lib; {
      description = "enhanced increment/decrement plugin for Neovim";
      homepage = "https://github.com/monaqa/dial.nvim";
      license = with licenses; [ mit ];
    };
  };
  matchparen-nvim = buildVimPluginFrom2Nix {
    pname = "matchparen-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/monkoose/matchparen.nvim/archive/e28d68fcbd8fdc2495ca8d24d5d7943cce0b064f.tar.gz";
      sha256 = "1ims26xrd48qri4xa895ibwv3nfl5kkm69cd1p1vz89lmpxbbsf1";
    };
    meta = with lib; {
      description = "alternative to matchparen neovim plugin ";
      homepage = "https://github.com/monkoose/matchparen.nvim";
      license = with licenses; [ mit ];
    };
  };
  coq-nvim = buildVimPluginFrom2Nix {
    pname = "coq-nvim";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/ms-jpq/coq_nvim/archive/71798732e05f5b720a067b1a66cddf1ec5d6b407.tar.gz";
      sha256 = "1rx4f8wrn84i4giipshlic1fy83mb04y2v4vmcxj3214n5jwgfqs";
    };
    meta = with lib; {
      description = "Fast as FUCK nvim completion. SQLite, concurrent scheduler, hundreds of hours of optimization";
      homepage = "https://github.com/ms-jpq/coq_nvim";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-lsp-basics = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-basics";
    version = "2021-05-16";
    src = fetchurl {
      url = "https://github.com/nanotee/nvim-lsp-basics/archive/123edb8e2337350955b712382a2875901a4f656f.tar.gz";
      sha256 = "18jac99wkn79j4ia2mg2jr3ycv3mhvw5x1xvswqbx0gk5wqvpqcq";
    };
    meta = with lib; {
      description = "Basic wrappers for LSP features";
      homepage = "https://github.com/nanotee/nvim-lsp-basics";
      license = with licenses; [ mit ];
    };
  };
  sqls-nvim = buildVimPluginFrom2Nix {
    pname = "sqls-nvim";
    version = "2021-11-01";
    src = fetchurl {
      url = "https://github.com/nanotee/sqls.nvim/archive/0228ec2ef909f7b11e8dcfea99f5b81c30e382ed.tar.gz";
      sha256 = "0ik1qd61dq4hbjqf5xh3fi3ikwiwngvw54mqq60zccjwvrzmri39";
    };
    meta = with lib; {
      description = "Neovim plugin for sqls that leverages the built-in LSP client";
      homepage = "https://github.com/nanotee/sqls.nvim";
      license = with licenses; [ mit ];
    };
  };
  onedark-nvim = buildVimPluginFrom2Nix {
    pname = "onedark-nvim";
    version = "2021-11-30";
    src = fetchurl {
      url = "https://github.com/navarasu/onedark.nvim/archive/ce49cf36dc839564e95290e2cdace396c148bca1.tar.gz";
      sha256 = "0vvn78bzfbams6qb71plwfy9pkhdkvrnc3717civj4m0hw31qyrv";
    };
    meta = with lib; {
      description = "One Dark Theme for Neovim >= 0.5.0 written in lua based on Atom's One Dark UI Theme. Additionally, it comes with 5 color variant styles";
      homepage = "https://github.com/navarasu/onedark.nvim";
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
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/noib3/nvim-cokeline/archive/95907fd85dc33ead63c6a94e48cb4208796d8ac4.tar.gz";
      sha256 = "125lcfnw55k5p0898kncivn4ha8zbn6q52mlppv3lnkzk64yvcb0";
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
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/notomo/cmdbuf.nvim/archive/8a3d521bf1df5953335a098b7be8fe0b3993e54b.tar.gz";
      sha256 = "0njk5by12n9h2j0q0yfyh9n5w3p47rmqyalsx3px163hmfp6lksh";
    };
    meta = with lib; {
      description = "Alternative command-line window plugin for neovim";
      homepage = "https://github.com/notomo/cmdbuf.nvim";
      license = with licenses; [ mit ];
    };
  };
  gesture-nvim = buildVimPluginFrom2Nix {
    pname = "gesture-nvim";
    version = "2021-08-15";
    src = fetchurl {
      url = "https://github.com/notomo/gesture.nvim/archive/e433adc41bd9bee44e65c029335eac384a1360ff.tar.gz";
      sha256 = "1vbl7q2hyx1sbq4r52rap535fm5zdwy9pfslmkb7s496xqjwcibz";
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
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/numToStr/Comment.nvim/archive/9e80d5146013275277238c89bbcaf4164f4e5140.tar.gz";
      sha256 = "08a74kinsm707pbs1pn0fyy2fyzyf0fmmfx7irxp0yya8ajw3w1a";
    };
    meta = with lib; {
      description = ":brain: :muscle: // Smart and powerful comment plugin for neovim. Supports treesitter, dot repeat, left-right/up-down motions, hooks, and more";
      homepage = "https://github.com/numToStr/Comment.nvim";
      license = with licenses; [ mit ];
    };
  };
  telescope-bibtex-nvim = buildVimPluginFrom2Nix {
    pname = "telescope-bibtex-nvim";
    version = "2021-11-29";
    src = fetchurl {
      url = "https://github.com/nvim-telescope/telescope-bibtex.nvim/archive/408468422dd00fa1786afbf673f9972e121e4415.tar.gz";
      sha256 = "1w6f7cq4gnmxv5mj9hvsr857qy5bf16v6xr7snmhzvmhcjp3bsqh";
    };
    meta = with lib; {
      description = "A telescope.nvim extension to search and paste bibtex entries into your TeX files";
      homepage = "https://github.com/nvim-telescope/telescope-bibtex.nvim";
      license = with licenses; [ mit ];
    };
  };
  vn-night-nvim = buildVimPluginFrom2Nix {
    pname = "vn-night-nvim";
    version = "2021-07-24";
    src = fetchurl {
      url = "https://github.com/nxvu699134/vn-night.nvim/archive/fecd761c79beda168475acfcc88780bb01a51b9c.tar.gz";
      sha256 = "13b9sbrnf70r6nfp6r4v44z1ycgxj2b9xi2z7mpxlffrg4hq76b9";
    };
    meta = with lib; {
      description = "No description";
      homepage = "https://github.com/nxvu699134/vn-night.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-hardline = buildVimPluginFrom2Nix {
    pname = "nvim-hardline";
    version = "2021-12-20";
    src = fetchurl {
      url = "https://github.com/ojroques/nvim-hardline/archive/618c4d373fdabf3bcf3ed86a7beab453f09390e1.tar.gz";
      sha256 = "0rf17j9kanwpvyp83syfmm4kyk9pas9jd57jiv0qhi9bmb4s5wwi";
    };
    meta = with lib; {
      description = "A simple Neovim statusline written in Lua";
      homepage = "https://github.com/ojroques/nvim-hardline";
      license = with licenses; [ bsd2 ];
    };
  };
  nvim-lspfuzzy = buildVimPluginFrom2Nix {
    pname = "nvim-lspfuzzy";
    version = "2021-11-08";
    src = fetchurl {
      url = "https://github.com/ojroques/nvim-lspfuzzy/archive/d589cd2061830a32bb57bb410f5278afa267d0c6.tar.gz";
      sha256 = "1vgbq5czzlv5dk098ph7psixhczfz1b5r1s44nzy5hrji4m44glr";
    };
    meta = with lib; {
      description = "A Neovim plugin to make the LSP client use FZF";
      homepage = "https://github.com/ojroques/nvim-lspfuzzy";
      license = with licenses; [ bsd2 ];
    };
  };
  cmp-git = buildVimPluginFrom2Nix {
    pname = "cmp-git";
    version = "2021-11-29";
    src = fetchurl {
      url = "https://github.com/petertriho/cmp-git/archive/2d78e6e66130af1a19f8fd15e9d123ed000d633c.tar.gz";
      sha256 = "18ppzxhgmcgzxyq7yp6m9j7j548mhcjiafcvlk196flsfaqj7x16";
    };
    meta = with lib; {
      description = "Git source for nvim-cmp";
      homepage = "https://github.com/petertriho/cmp-git";
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
    version = "2021-12-11";
    src = fetchurl {
      url = "https://github.com/pianocomposer321/yabs.nvim/archive/c2a8b6e606292f77e4117d6e3560f1cf3652c51d.tar.gz";
      sha256 = "01b0mxsa1b4khwryfarfxf45z2dvac7wjkq9qd1p2yiixb281403";
    };
    meta = with lib; {
      description = "Yet Another Build System/Code Runner for Neovim, written in lua";
      homepage = "https://github.com/pianocomposer321/yabs.nvim";
      license = with licenses; [ agpl3Only ];
    };
  };
  github-nvim-theme = buildVimPluginFrom2Nix {
    pname = "github-nvim-theme";
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/projekt0n/github-nvim-theme/archive/efd08c43d38dc1fb44e1dc78ce78d1dd1bb8ece9.tar.gz";
      sha256 = "078fxmxs4qdfhymcx9ia2cy7nzwmzs9y5gw97ja891ymi7hqp533";
    };
    meta = with lib; {
      description = "Github theme for Neovim, kitty, iTerm, Konsole, tmux and Alacritty written in Lua";
      homepage = "https://github.com/projekt0n/github-nvim-theme";
      license = with licenses; [ mit ];
    };
  };
  codeql-nvim = buildVimPluginFrom2Nix {
    pname = "codeql-nvim";
    version = "2021-12-08";
    src = fetchurl {
      url = "https://github.com/pwntester/codeql.nvim/archive/51213ad618c8cc63646e7242b522dc15b65578ba.tar.gz";
      sha256 = "1gmyaysvq7bxawa4gfy1njbcajyhki4dn4z9mcajk7n3niaa9vc9";
    };
    meta = with lib; {
      description = "CodeQL plugin for Neovim";
      homepage = "https://github.com/pwntester/codeql.nvim";
    };
  };
  octo-nvim = buildVimPluginFrom2Nix {
    pname = "octo-nvim";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/pwntester/octo.nvim/archive/4de7b07cb0788d69444d8b08d9936a4b3ffced87.tar.gz";
      sha256 = "1db141fsiryg7dxir5za9j5las1hgxx4qcx396dgsl13dm4ascjk";
    };
    meta = with lib; {
      description = "Edit and review GitHub issues and pull requests from the comfort of your favorite editor";
      homepage = "https://github.com/pwntester/octo.nvim";
      license = with licenses; [ mit ];
    };
  };
  cmp-nvim-ultisnips = buildVimPluginFrom2Nix {
    pname = "cmp-nvim-ultisnips";
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/quangnguyen30192/cmp-nvim-ultisnips/archive/79fd645096c406fb41b38ef4dd99525965b446b1.tar.gz";
      sha256 = "088dmnbj4rq1ir79rx6jlmcwa6glcz848p5z7s7ir8qc1w66k6ga";
    };
    meta = with lib; {
      description = "nvim-cmp source for ultisnips";
      homepage = "https://github.com/quangnguyen30192/cmp-nvim-ultisnips";
      license = with licenses; [ asl20 ];
    };
  };
  nvim-goc-lua = buildVimPluginFrom2Nix {
    pname = "nvim-goc-lua";
    version = "2021-11-23";
    src = fetchurl {
      url = "https://github.com/rafaelsq/nvim-goc.lua/archive/7c03112ce77b7df2b124d46c1188cc3c66d06f66.tar.gz";
      sha256 = "09hyaya8bk7yd1knbdj9gnjfxlh3rpaqi2rlyinq4aj4fcrh35f4";
    };
    meta = with lib; {
      description = "Go Coverage for Neovim";
      homepage = "https://github.com/rafaelsq/nvim-goc.lua";
      license = with licenses; [ mit ];
    };
  };
  nvim-luapad = buildVimPluginFrom2Nix {
    pname = "nvim-luapad";
    version = "2021-08-15";
    src = fetchurl {
      url = "https://github.com/rafcamlet/nvim-luapad/archive/33a7237d4ca42b6692042adc15cf77f5231940cf.tar.gz";
      sha256 = "0f82ngx1yy47w5xkkkw6jy3jw607rhf8l0ml0w26m5k0m3jfv6bv";
    };
    meta = with lib; {
      description = "Interactive real time neovim scratchpad for embedded lua engine - type and watch!";
      homepage = "https://github.com/rafcamlet/nvim-luapad";
    };
  };
  tabline-framework-nvim = buildVimPluginFrom2Nix {
    pname = "tabline-framework-nvim";
    version = "2021-11-28";
    src = fetchurl {
      url = "https://github.com/rafcamlet/tabline-framework.nvim/archive/2caec7cba9c8121d69003bde352ab19bed7b904e.tar.gz";
      sha256 = "0mqjjllbmqxm3hgz9qy59mxb5gjyhpf253pcysiq1p5q6drp77kp";
    };
    meta = with lib; {
      description = "User-friendly framework for building your dream tabline in a few lines of code";
      homepage = "https://github.com/rafcamlet/tabline-framework.nvim";
      license = with licenses; [ mit ];
    };
  };
  requirements-txt-vim = buildVimPluginFrom2Nix {
    pname = "requirements-txt-vim";
    version = "2021-12-04";
    src = fetchurl {
      url = "https://github.com/raimon49/requirements.txt.vim/archive/777f6225c547380655b8c043b64c2132a606e7d7.tar.gz";
      sha256 = "005lzzws1fgrpxrqd5kx98w235zjg15fc020rywhh1zw5zgqdr4h";
    };
    meta = with lib; {
      description = "the Requirements File Format syntax support for Vim";
      homepage = "https://github.com/raimon49/requirements.txt.vim";
      license = with licenses; [ mit ];
    };
  };
  go-nvim = buildVimPluginFrom2Nix {
    pname = "go-nvim";
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/ray-x/go.nvim/archive/437748a09fdbe1d590da8ec8b4cbf3cba84c4616.tar.gz";
      sha256 = "1n1f87gk6qcj5jnwi9nddvyjh0j12b2imgsv83nbi4cx682li2iv";
    };
    meta = with lib; {
      description = "Modern Go development plugin for Neovim, based on nvim-lsp, treesitter and Dap";
      homepage = "https://github.com/ray-x/go.nvim";
      license = with licenses; [ mit ];
    };
  };
  navigator-lua = buildVimPluginFrom2Nix {
    pname = "navigator-lua";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/ray-x/navigator.lua/archive/47bcf183b8ba28ef5a0c4cf23965e3b37c8c039e.tar.gz";
      sha256 = "118pwai4b85q2gwf5x8389yvlivx6aknkynkjyfwq9ha26q5s772";
    };
    meta = with lib; {
      description = "Navigate codes like a breeze🎐.  Exploring LSP and 🌲Treesitter symbols a piece of 🍰. Control codes like a boss 🦍";
      homepage = "https://github.com/ray-x/navigator.lua";
      license = with licenses; [ mit ];
    };
  };
  kanagawa-nvim = buildVimPluginFrom2Nix {
    pname = "kanagawa-nvim";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/rebelot/kanagawa.nvim/archive/1a3314e8744236ceae78eee88d5c372f0473b450.tar.gz";
      sha256 = "0qg5vwjgd80j022ql8fqci9fn75jlc07lhjvrj93x3y0cdr40jvn";
    };
    meta = with lib; {
      description = "NeoVim dark colorscheme inspired by the colors of the famous painting by Katsushika Hokusai";
      homepage = "https://github.com/rebelot/kanagawa.nvim";
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
    version = "2021-10-26";
    src = fetchurl {
      url = "https://github.com/rktjmp/highlight-current-n.nvim/archive/ba03076cc37f2b65dbbad15cbf685ef29c51617c.tar.gz";
      sha256 = "0h2jwiksia5y63ymzymya3pwz7ax1imj5saykca7j4s61wlwap0a";
    };
    meta = with lib; {
      description = "Highlights the current /, ? or * match under your cursor when pressing n or N and gets out of the way afterwards";
      homepage = "https://github.com/rktjmp/highlight-current-n.nvim";
      license = with licenses; [ mit ];
    };
  };
  hotpot-nvim = buildVimPluginFrom2Nix {
    pname = "hotpot-nvim";
    version = "2021-11-25";
    src = fetchurl {
      url = "https://github.com/rktjmp/hotpot.nvim/archive/7db3e2e2ed6227354f2950b94b895efb0da433fd.tar.gz";
      sha256 = "0hdl5p1ny0cmlpjrmkpnjmdsnmybk65ja04la099fkf5hnsbwvy9";
    };
    meta = with lib; {
      description = ":stew: Carl Weathers #1 Neovim Plugin";
      homepage = "https://github.com/rktjmp/hotpot.nvim";
      license = with licenses; [ mit ];
    };
  };
  paperplanes-nvim = buildVimPluginFrom2Nix {
    pname = "paperplanes-nvim";
    version = "2021-08-14";
    src = fetchurl {
      url = "https://github.com/rktjmp/paperplanes.nvim/archive/8fcddba137b630068693cc7d2ede1997c49f09fe.tar.gz";
      sha256 = "1cylwdc0sknba1scs7ivgyj3jfnw6ph25bl2slcnb6sxsgrzmxa2";
    };
    meta = with lib; {
      description = "Neovim :airplane: Pastebins";
      homepage = "https://github.com/rktjmp/paperplanes.nvim";
      license = with licenses; [ mit ];
    };
  };
  onenord-nvim = buildVimPluginFrom2Nix {
    pname = "onenord-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/rmehri01/onenord.nvim/archive/9d437b69afac269e0a24a94c9bf9ce5328730fed.tar.gz";
      sha256 = "0n5f6i5mlzxky9pw4g3hjrz6ygkljvbysj95fmr597px7qjbw2y8";
    };
    meta = with lib; {
      description = "🏔️ A Neovim theme that combines the Nord and Atom One Dark color palettes for a more vibrant programming experience";
      homepage = "https://github.com/rmehri01/onenord.nvim";
      license = with licenses; [ mit ];
    };
  };
  boo-colorscheme-nvim = buildVimPluginFrom2Nix {
    pname = "boo-colorscheme-nvim";
    version = "2021-12-08";
    src = fetchurl {
      url = "https://github.com/rockerBOO/boo-colorscheme-nvim/archive/3dd03242eda07f977e810e117b0d858e48940de9.tar.gz";
      sha256 = "0qk8sh8yfr52zkwhqjkqd38rxz3gjpgb814q6lxl30sll9pqfavk";
    };
    meta = with lib; {
      description = "Boo is a colorscheme for Neovim with handcrafted support for LSP, Treesitter";
      homepage = "https://github.com/rockerBOO/boo-colorscheme-nvim";
      license = with licenses; [ mit ];
    };
  };
  rose-pine = buildVimPluginFrom2Nix {
    pname = "rose-pine";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/rose-pine/neovim/archive/6f00511f83676ca2fd1543161da422c205abe525.tar.gz";
      sha256 = "11fw385zdyvg757y2x6ajkw5w4bcza7fsjaapar1lgc2aryip4dm";
    };
    meta = with lib; {
      description = "Soho vibes for Neovim";
      homepage = "https://github.com/rose-pine/neovim";
    };
  };
  nvim-comment-frame = buildVimPluginFrom2Nix {
    pname = "nvim-comment-frame";
    version = "2021-09-14";
    src = fetchurl {
      url = "https://github.com/s1n7ax/nvim-comment-frame/archive/05be8b4cf2138d341ed5135dc704d9fccf51a3cb.tar.gz";
      sha256 = "0daaz29wy5gy213hr4jg62l3lfq39vnv95ba0cwkl5cbn9qmclci";
    };
    meta = with lib; {
      description = "Detects the language using treesitter and adds a comment block";
      homepage = "https://github.com/s1n7ax/nvim-comment-frame";
      license = with licenses; [ mit ];
    };
  };
  nvim-terminal = buildVimPluginFrom2Nix {
    pname = "nvim-terminal";
    version = "2021-11-12";
    src = fetchurl {
      url = "https://github.com/s1n7ax/nvim-terminal/archive/e044b91f399cda1ef5da7316f84d46b4789c3fd5.tar.gz";
      sha256 = "0vjgvyn3glp7hym01nqwxayk2yjhs3k5yndjvlrs2x03rhrz1i0n";
    };
    meta = with lib; {
      description = "A Lua-Neovim plugin that toggles a terminal";
      homepage = "https://github.com/s1n7ax/nvim-terminal";
      license = with licenses; [ mit ];
    };
  };
  sort-nvim = buildVimPluginFrom2Nix {
    pname = "sort-nvim";
    version = "2021-12-14";
    src = fetchurl {
      url = "https://github.com/sQVe/sort.nvim/archive/5cd64cbe6f0dd28f95846eb7d5fc257333c78cad.tar.gz";
      sha256 = "0pr8qlgiaj49x9jf1cys7nkpif577c1jnaincccv02rdjg1c2zg4";
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
    version = "2021-12-17";
    src = fetchurl {
      url = "https://github.com/sainnhe/everforest/archive/fc958028d0cb6f32deda102fe18bb13affdd84ce.tar.gz";
      sha256 = "0mk9kv8cvdlkqq86rhhikx48avn299qcprk3hp49qv4gdlrq5vhp";
    };
    meta = with lib; {
      description = "🌲 Comfortable & Pleasant Color Scheme for Vim";
      homepage = "https://github.com/sainnhe/everforest";
      license = with licenses; [ mit ];
    };
  };
  melange = buildVimPluginFrom2Nix {
    pname = "melange";
    version = "2021-11-16";
    src = fetchurl {
      url = "https://github.com/savq/melange/archive/e3a3a2cd03c73b4fc0670e9ac09dacdb3c6609c1.tar.gz";
      sha256 = "1pmnrh1yfvkfy87yz00yzd816q4hz0sjzkm0n84jdvrfy0a3frb5";
    };
    meta = with lib; {
      description = "🗡️ Warm color scheme for Neovim and beyond";
      homepage = "https://github.com/savq/melange";
      license = with licenses; [ mit ];
    };
  };
  paq-nvim = buildVimPluginFrom2Nix {
    pname = "paq-nvim";
    version = "2021-12-18";
    src = fetchurl {
      url = "https://github.com/savq/paq-nvim/archive/17f278c47ad91a9fb8cae3689a6444ec0e830834.tar.gz";
      sha256 = "1z570sk3kf1kbdwr6drmvz1di3pk51nykgk8mimcjg4xcimmcxnn";
    };
    meta = with lib; {
      description = "🌚  Neovim package manager";
      homepage = "https://github.com/savq/paq-nvim";
      license = with licenses; [ mit ];
    };
  };
  nvimesweeper = buildVimPluginFrom2Nix {
    pname = "nvimesweeper";
    version = "2021-09-07";
    src = fetchurl {
      url = "https://github.com/seandewar/nvimesweeper/archive/8d3a0fb2fbe0f21da3579dcaf1e6fa1c37364311.tar.gz";
      sha256 = "18lbq2fizd07lxsbb4jdpimxpr62iraycpzrwh24acdy71rncasy";
    };
    meta = with lib; {
      description = "Play Minesweeper in your favourite text editor (Neovim 0.5+)";
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
  roshnivim-cs = buildVimPluginFrom2Nix {
    pname = "roshnivim-cs";
    version = "2021-12-21";
    src = fetchurl {
      url = "https://github.com/shaeinst/roshnivim-cs/archive/c29598c2da274aa8185dab154380ead41100889d.tar.gz";
      sha256 = "0nz5n4b8aah064hg3pyar924xd2522xv2im5skdj897nzp9cap1g";
    };
    meta = with lib; {
      description = "Colorscheme for (neo)vim written in lua, specially made for roshnivim with Tree-sitter support";
      homepage = "https://github.com/shaeinst/roshnivim-cs";
    };
  };
  startup-nvim = buildVimPluginFrom2Nix {
    pname = "startup-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/startup-nvim/startup.nvim/archive/b090aa1b85f917ca547477ce0b85210cb6e40375.tar.gz";
      sha256 = "01z7a7gygdm0pncy6ii0wx770wf472biw33392kslyv03xn9iq5n";
    };
    meta = with lib; {
      description = "A highly configurable neovim startup screen";
      homepage = "https://github.com/startup-nvim/startup.nvim";
      license = with licenses; [ gpl2Only ];
    };
  };
  dressing-nvim = buildVimPluginFrom2Nix {
    pname = "dressing-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/stevearc/dressing.nvim/archive/0ad4d1e6b90f9c74dd95100271f2ad52b8c5f12d.tar.gz";
      sha256 = "0y37ir56fw1yx2sd19v31jqg7bs5c67bmds84zjl2jx7zy8xcc3n";
    };
    meta = with lib; {
      description = "Neovim plugin to improve the default vim.ui interfaces";
      homepage = "https://github.com/stevearc/dressing.nvim";
      license = with licenses; [ mit ];
    };
  };
  gkeep-nvim = buildVimPluginFrom2Nix {
    pname = "gkeep-nvim";
    version = "2021-11-17";
    src = fetchurl {
      url = "https://github.com/stevearc/gkeep.nvim/archive/dc470713ecdc69dc1052e337be20267e151658a4.tar.gz";
      sha256 = "0y73haps6ag42jz4bz60kzv63kvazmakcjj9h3bsbdmxkksgz2fk";
    };
    meta = with lib; {
      description = "Google Keep integration for Neovim";
      homepage = "https://github.com/stevearc/gkeep.nvim";
      license = with licenses; [ mit ];
    };
  };
  qf-helper-nvim = buildVimPluginFrom2Nix {
    pname = "qf-helper-nvim";
    version = "2021-12-01";
    src = fetchurl {
      url = "https://github.com/stevearc/qf_helper.nvim/archive/9c6d2da63131641584e21c263d57695a6c0572a9.tar.gz";
      sha256 = "06gsr6x5mr7x7rzlzkv9vdx5afpb3dfv1x6rmixbfvli7nibpjn0";
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
    version = "2021-09-25";
    src = fetchurl {
      url = "https://github.com/svermeulen/vimpeccable/archive/a35973d52d946a4995f748aed783a35c8113ba57.tar.gz";
      sha256 = "06dpvxqs6l5la7lib0nq5h5xjqi9a0lf2vgag9x0rg44n69rnv4x";
    };
    meta = with lib; {
      description = "Neovim plugin that allows you to easily map keys directly to lua code inside your init.lua";
      homepage = "https://github.com/svermeulen/vimpeccable";
      license = with licenses; [ mit ];
    };
  };
  nlsp-settings-nvim = buildVimPluginFrom2Nix {
    pname = "nlsp-settings-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/tamago324/nlsp-settings.nvim/archive/fc32b281bcd6666f503dd6431a2dbc917b7f85fe.tar.gz";
      sha256 = "07mivrz6x4kfblah88maasfcydp2swphgd3m0ngfqwl8w029wny0";
    };
    meta = with lib; {
      description = "A plugin for setting Neovim LSP with JSON files";
      homepage = "https://github.com/tamago324/nlsp-settings.nvim";
      license = with licenses; [ mit ];
    };
  };
  lspsaga-nvim = buildVimPluginFrom2Nix {
    pname = "lspsaga-nvim";
    version = "2021-12-19";
    src = fetchurl {
      url = "https://github.com/tami5/lspsaga.nvim/archive/55979c8390037615c21ac109f538189316cfef18.tar.gz";
      sha256 = "0z2c5yh82ahq48krahdqz66npp251bk6cdr2lkb2qff4iml9142b";
    };
    meta = with lib; {
      description = "till  glepnir goes back online";
      homepage = "https://github.com/tami5/lspsaga.nvim";
      license = with licenses; [ mit ];
    };
  };
  staline-nvim = buildVimPluginFrom2Nix {
    pname = "staline-nvim";
    version = "2021-12-13";
    src = fetchurl {
      url = "https://github.com/tamton-aquib/staline.nvim/archive/256766cdca375a84e840460108954656ec785232.tar.gz";
      sha256 = "1mpalw9bf4yr64n6x1jqg96d0g8psabqzfkbiy24c0hgfrjc6khp";
    };
    meta = with lib; {
      description = "A modern lightweight statusline and bufferline for neovim in lua. Mainly uses unicode symbols for showing info";
      homepage = "https://github.com/tamton-aquib/staline.nvim";
      license = with licenses; [ mit ];
    };
  };
  monokai-nvim = buildVimPluginFrom2Nix {
    pname = "monokai-nvim";
    version = "2021-10-06";
    src = fetchurl {
      url = "https://github.com/tanvirtin/monokai.nvim/archive/eee34ab38e62315c1609484672c60e8a7338d4d2.tar.gz";
      sha256 = "134swfyhlchbi5k80lqxxd553aypa96mkc3fqw15sv5pdjzqmv17";
    };
    meta = with lib; {
      description = "Monokai theme for Neovim written in Lua";
      homepage = "https://github.com/tanvirtin/monokai.nvim";
      license = with licenses; [ mit ];
    };
  };
  vgit-nvim = buildVimPluginFrom2Nix {
    pname = "vgit-nvim";
    version = "2021-12-22";
    src = fetchurl {
      url = "https://github.com/tanvirtin/vgit.nvim/archive/5eee0e7dd819f05924b492e03d0ce95f06c80670.tar.gz";
      sha256 = "17vhv5ci08vsi3gwlg1l7mcbldhl6z3g85p76f8sdr5zsf8kg5yk";
    };
    meta = with lib; {
      description = "Visual Git Plugin for Neovim";
      homepage = "https://github.com/tanvirtin/vgit.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-comment = buildVimPluginFrom2Nix {
    pname = "nvim-comment";
    version = "2021-08-01";
    src = fetchurl {
      url = "https://github.com/terrortylor/nvim-comment/archive/6363118acf86824ed11c2238292b72dc5ef8bdde.tar.gz";
      sha256 = "1s8w6bbc9b59bpv7lxlb655400clxd87032yqpr0gjvwrji7j5rs";
    };
    meta = with lib; {
      description = "A comment toggler for Neovim, written in Lua";
      homepage = "https://github.com/terrortylor/nvim-comment";
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
    version = "2021-07-27";
    src = fetchurl {
      url = "https://github.com/tveskag/nvim-blame-line/archive/198d131a3ae8033a98759f43d024b80821974113.tar.gz";
      sha256 = "0pbbk8cwsral40bfad63an1p3l6qp33wv5bsz0gci47cv31bp7g2";
    };
    meta = with lib; {
      description = "A small plugin that uses neovims virtual text to print git blame info at the end of the current line";
      homepage = "https://github.com/tveskag/nvim-blame-line";
      license = with licenses; [ mit ];
    };
  };
  neorg = buildVimPluginFrom2Nix {
    pname = "neorg";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/nvim-neorg/neorg/archive/77cdd585a4a54ef3ef918e44fc31db2dde1e2058.tar.gz";
      sha256 = "1rzvnvw82blv32w443waqhbq98x2z26vff7rd5sv4w1gf0kllgya";
    };
    meta = with lib; {
      description = "Modernity meets insane extensibility. The future of organizing your life in Neovim";
      homepage = "https://github.com/nvim-neorg/neorg";
      license = with licenses; [ gpl3Only ];
    };
  };
  nvim-lsp-installer = buildVimPluginFrom2Nix {
    pname = "nvim-lsp-installer";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/williamboman/nvim-lsp-installer/archive/65d9e6467ecf5fdb962af484de40ef581c064e66.tar.gz";
      sha256 = "0c6251wl19fdfgg701j643nafki844ysc3jd0i93yq61v7v2pnk2";
    };
    meta = with lib; {
      description = "Companion plugin for nvim-lspconfig that allows you to seamlessly manage LSP servers locally with :LspInstall. With full Windows support!";
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
    version = "2021-12-11";
    src = fetchurl {
      url = "https://github.com/nvim-pack/nvim-spectre/archive/e2510d32dc80d6b5eea4df057762bbc6b2482e05.tar.gz";
      sha256 = "1y5wrjwwxv9m8v1wzcphbp5dksgczfx1n00052f0d5g1zacyw57l";
    };
    meta = with lib; {
      description = "Find the enemy and replace them with dark power";
      homepage = "https://github.com/nvim-pack/nvim-spectre";
      license = with licenses; [ mit ];
    };
  };
  nvim-ts-autotag = buildVimPluginFrom2Nix {
    pname = "nvim-ts-autotag";
    version = "2021-12-19";
    src = fetchurl {
      url = "https://github.com/windwp/nvim-ts-autotag/archive/0ceb4ef342bf1fdbb082ad4fa1fcfd0f864e1cba.tar.gz";
      sha256 = "0shzd55a27awa15vvf4zfcdrd5kkqqj0mjp7gf124v6csljpm38d";
    };
    meta = with lib; {
      description = "Use treesitter to auto close and auto rename html tag";
      homepage = "https://github.com/windwp/nvim-ts-autotag";
      license = with licenses; [ mit ];
    };
  };
  windline-nvim = buildVimPluginFrom2Nix {
    pname = "windline-nvim";
    version = "2021-12-23";
    src = fetchurl {
      url = "https://github.com/windwp/windline.nvim/archive/687302ffeeee41c6083d7cd269eeb221d6f8df8c.tar.gz";
      sha256 = "00f1j91kk7jvbgskgg95ipyspbdp9m0h0qc4552ma39wxa9i7m17";
    };
    meta = with lib; {
      description = "Animation statusline, floating window statusline. Use lua + luv make some wind";
      homepage = "https://github.com/windwp/windline.nvim";
      license = with licenses; [ mit ];
    };
  };
  commented-nvim = buildVimPluginFrom2Nix {
    pname = "commented-nvim";
    version = "2021-11-14";
    src = fetchurl {
      url = "https://github.com/winston0410/commented.nvim/archive/56c53723fc004b2def0dc4c0d187092bd565abc5.tar.gz";
      sha256 = "05iydijszjv40xkzc8m50c614q5wl7gqlx4kfbahbpsf6j37chv3";
    };
    meta = with lib; {
      description = "Neovim commenting plugin in Lua. Support operator, motions and more than 60 languages! :fire:";
      homepage = "https://github.com/winston0410/commented.nvim";
      license = with licenses; [ mit ];
    };
  };
  nvim-cursorword = buildVimPluginFrom2Nix {
    pname = "nvim-cursorword";
    version = "2021-12-24";
    src = fetchurl {
      url = "https://github.com/xiyaowong/nvim-cursorword/archive/bc72533c9581204313f8fa437c0bc24b2b29e447.tar.gz";
      sha256 = "0pj5xcv1w6jx5mvjwq8ikac9m07lx6s494i460p8v0qmv16faglg";
    };
    meta = with lib; {
      description = "highlight the word under the cursor";
      homepage = "https://github.com/xiyaowong/nvim-cursorword";
    };
  };
  nvim-transparent = buildVimPluginFrom2Nix {
    pname = "nvim-transparent";
    version = "2021-11-28";
    src = fetchurl {
      url = "https://github.com/xiyaowong/nvim-transparent/archive/d171ca7ab4215e0276899b19fd808afa84acc9ab.tar.gz";
      sha256 = "0gmpwc4dc68n5gq1vngz7dyskhwk40kims4gcrglgvx49ssb3rjr";
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
    version = "2021-02-20";
    src = fetchurl {
      url = "https://github.com/yonlu/omni.vim/archive/4dc83c4e800747c117883a8d1aadadc28658f527.tar.gz";
      sha256 = "1r35hgvzk92dvghi72j50lxazdzvp65dcp6xgsip5y0k0r9jizvw";
    };
    meta = with lib; {
      description = "🎨 Omni color scheme for Neovim";
      homepage = "https://github.com/yonlu/omni.vim";
    };
  };
  nvim-pqf = buildVimPluginFrom2Nix {
    pname = "nvim-pqf";
    version = "2021-10-29";
    src = fetchurl {
      url = "https://gitlab.com/api/v4/projects/yorickpeterse%2Fnvim-pqf/repository/archive.tar.gz?sha=d053a333c1eb8d7cabb023b6ba52e3f211211209";
      sha256 = "1p2y95a5r4wa75bzmfwhlwmn56z7br52jpxyshl7n1h1gf1ad908";
    };
    meta = with lib; {
      description = "Prettier quickfix/location list windows for NeoVim";
      homepage = "https://gitlab.com/yorickpeterse/nvim-pqf";
    };
  };
}
