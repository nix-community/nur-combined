{ lib, buildVimPluginFrom2Nix, fetchurl }:

{
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
    version = "2021-11-27";
    src = fetchurl {
      url = "https://github.com/famiu/feline.nvim/archive/24ba3bbf286f2c6ce49c0439b0bd2d216bc52601.tar.gz";
      sha256 = "0kq94gnvpx41nfxlasbj9q9j77m5qzzliiwzwflzglbs3nhqglgw";
    };
    meta = with lib; {
      description = "A minimal, stylish and customizable statusline for Neovim written in Lua";
      homepage = "https://github.com/famiu/feline.nvim";
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
  vim-fish = buildVimPluginFrom2Nix {
    pname = "vim-fish";
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
  null-ls-nvim = buildVimPluginFrom2Nix {
    pname = "null-ls-nvim";
    version = "2021-12-16";
    src = fetchurl {
      url = "https://github.com/jose-elias-alvarez/null-ls.nvim/archive/d5ad64919848c19e8d105e3620c7241747ee23cc.tar.gz";
      sha256 = "1a07v8m5qb1pfx296wv711fi3m1a06nm6fajnmhmakadmwn3q4x1";
    };
    meta = with lib; {
      description = "Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua";
      homepage = "https://github.com/jose-elias-alvarez/null-ls.nvim";
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
  iron-nvim = buildVimPluginFrom2Nix {
    pname = "iron-nvim";
    version = "2021-12-01";
    src = fetchurl {
      url = "https://github.com/mnacamura/iron.nvim/archive/a8ea45da4a00b3969151b660c2c4eac6d1ab1ebb.tar.gz";
      sha256 = "1xg6d1wdz8dhhxnkpxvgw2vfadiv37x6lys7gq5pxciy3f4sjrxh";
    };
    meta = with lib; {
      description = "A fork of IRON, Interactive Repl Over Neovim";
      homepage = "https://github.com/mnacamura/iron.nvim";
      license = with licenses; [ bsd3 ];
    };
  };
  nvim-srcerite = buildVimPluginFrom2Nix {
    pname = "nvim-srcerite";
    version = "2021-12-12";
    src = fetchurl {
      url = "https://github.com/mnacamura/nvim-srcerite/archive/1031529a3f16e0c144434f7340a73b8cf01c5ec6.tar.gz";
      sha256 = "0cfcx57rskxdg3yxcm1a1p39r6j3ghpji4xvjch4ryp65vz38iqz";
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
  paq-nvim = buildVimPluginFrom2Nix {
    pname = "paq-nvim";
    version = "2021-12-11";
    src = fetchurl {
      url = "https://github.com/savq/paq-nvim/archive/22640a6c7c54f14f593b2b77ffe4b577b4c5e15c.tar.gz";
      sha256 = "16g254zm0c3y1bh3zaf48mp9gjsi6ndjm21dhw3szb4n497c022f";
    };
    meta = with lib; {
      description = "🌚  Neovim package manager";
      homepage = "https://github.com/savq/paq-nvim";
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
