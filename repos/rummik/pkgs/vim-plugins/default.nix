{
  fetchFromGitHub,
  buildVimPluginFrom2Nix,
}:

{
  grep-vim = (buildVimPluginFrom2Nix {
    pname = "grep.vim";
    version = "852ddb0";

    src = fetchFromGitHub {
      owner = "vim-scripts";
      repo = "grep.vim";
      rev = "852ddb0c6590bbc41c508d7f5d2fc17112492def";
      sha256 = "02pa4hlrq8ry4yqs72cc6957x736kim5ms237qjkrsd2zdma3nr3";
    };
  });

  vim-just = (buildVimPluginFrom2Nix {
    pname = "vim-just";
    version = "312615d";

    src = fetchFromGitHub {
      owner = "NoahTheDuke";
      repo = "vim-just";
      rev = "838c9096d4c5d64d1000a6442a358746324c2123";
      sha256 = "sha256-DSC47z2wOEXvo2kGO5JtmR3hyHPiYXrkX7MgtagV5h4=";
    };
  });

  requirements-txt-vim = (buildVimPluginFrom2Nix rec {
    pname = "requirements.txt.vim";
    version = "1.5.1";

    src = fetchFromGitHub {
      owner = "raimon49";
      repo = "requirements.txt.vim";
      rev = "v-${version}";
      sha256 = "0ikkzrcgf88d298aacr2rhzs5cjxkpadbfa5iwbjgivy3855yhwx";
    };
  });

  vader = (buildVimPluginFrom2Nix {
    pname = "vader";
    version = "ddb71424";

    src = fetchFromGitHub {
      owner = "junegunn";
      repo = "vader.vim";
      rev = "ddb714246535e814ddd7c62b86ca07ffbec8a0af";
      sha256 = "0jlxbp883y84nal5p55fxg7a3wqh3zny9dhsvfjajrzvazmiz44n";
    };
  });

  vim-coloresque = (buildVimPluginFrom2Nix {
    pname = "vim-coloresque";
    version = "2019-10-21";

    src = fetchFromGitHub {
      owner = "gko";
      repo = "vim-coloresque";
      rev = "870d1e0a034bcdf6d5e482440d7043458f23e45c";
      sha256 = "020pf6cv80w99f7v9yjg9ckjrfxxxpcwvca9wphcs3m7sigp05yc";
    };
  });

  vim-css3-syntax = (buildVimPluginFrom2Nix rec {
    pname = "vim-css3-syntax";
    version = "1.4.0";

    src = fetchFromGitHub {
      owner = "hail2u";
      repo = "vim-css3-syntax";
      rev = "v${version}";
      sha256 = "1rkzr9fglcv77ia9lhgcirrr57vw9jvafgjkwmh2l46m5xa3gafz";
    };
  });

  vim-haml = (buildVimPluginFrom2Nix {
    pname = "vim-haml";
    version = "2019-10-30";

    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-haml";
      rev = "b8c2473a85b5a9bd3c2f07f3686b67564d499ea2";
      sha256 = "0j8dvh6kwfjmqvwifl8x20l2d14mq5f4dwn68vib9r2j968l2vvv";
    };
  });

  vim-nix = (buildVimPluginFrom2Nix {
    pname = "vim-nix";
    version = "2019-09-02";

    src = fetchFromGitHub {
      owner = "rummik";
      repo = "vim-nix";
      rev = "6affa2b211b02a907ab3bc7064821be57ae93446";
      sha256 = "1b7zgwhsx5swg6g5k59jwkdpzdklwmnwlcdizycacvsikb8xclmk";
    };
  });

  vim-rails = (buildVimPluginFrom2Nix {
    pname = "vim-rails";
    version = "854cbfa";

    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-rails";
      rev = "854cbfa64574b1fb974ba1895dbb17a24ac51246";
      sha256 = "1myaqkxlb3ba1sa67aif8719xs0pnyqxxfldcx5sbr49kswbbp9f";
    };
  });

  vim-rake = (buildVimPluginFrom2Nix {
    pname = "vim-rake";
    version = "34ece18";

    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-rake";
      rev = "34ece18ac8f2d3641473c3f834275c2c1e072977";
      sha256 = "1ff0na01mqm2dbgncrycr965sbifh6gd2wj1vv42vfgncz8l331a";
    };
  });

  vim-rspec = (buildVimPluginFrom2Nix {
    pname = "vim-rspec";
    version = "52a7259";

    src = fetchFromGitHub {
      owner = "thoughtbot";
      repo = "vim-rspec";
      rev = "52a72592b6128f4ef1557bc6e2e3eb014d8b2d38";
      sha256 = "09prk06rrbs8pgfm4iz88sp151p6pi9bl76p6macvv5nxv72d9j8";
    };
  });

  vim-ruby-refactoring = (buildVimPluginFrom2Nix {
    pname = "vim-ruby-refactoring";
    version = "6447a4d";

    src = fetchFromGitHub {
      owner = "ecomba";
      repo = "vim-ruby-refactoring";
      rev = "6447a4debc3263a0fa99feeab5548edf27ecf045";
      sha256 = "1fgwpfmzy3mfcx4cyfhmxk42np9g0bgp1nrc0w7vr9wlmzwn7mch";
    };
  });

  vim-session = (buildVimPluginFrom2Nix {
    pname = "vim-session";
    version = "9e9a608";

    src = fetchFromGitHub {
      owner = "xolox";
      repo = "vim-session";
      rev = "9e9a6088f0554f6940c19889d0b2a8f39d13f2bb";
      sha256 = "0r6k3fh0qpg95a02hkks3z4lsjailkd5ddlnn83w7f51jj793v3b";
    };
  });

  vim-smali = (buildVimPluginFrom2Nix {
    pname = "vim-smali";
    version = "2017-03-07";

    src = fetchFromGitHub {
      owner = "rummik";
      repo = "vim-smali";
      rev = "46d2a7583234bf0819a18d9f73ab8c751d6a58ad";
      sha256 = "1br3jir8v2hzrhmj2fdsd74gi65ikrwipimjfkwscd6z9c32s50d";
    };
  });

  vim-vagrant = (buildVimPluginFrom2Nix {
    pname = "vim-vagrant";
    version = "2018-11-10";

    src = fetchFromGitHub {
      owner = "hashivim";
      repo = "vim-vagrant";
      rev = "7741242ed9617ed53ba7e47e801634b819047ac0";
      sha256 = "0inpgcrca955h0ic7pgl6bfzs7rssjgssvrvqq3y93j5addmh60m";
    };
  });

  vim-workspace = (buildVimPluginFrom2Nix {
    pname = "vim-workspace";
    version = "2020-01-19";

    src = fetchFromGitHub {
      owner = "thaerkh";
      repo = "vim-workspace";
      rev = "faa835406990171bbbeff9254303dad49bad17cb";
      sha256 = "0lzba39sb4yxla3vr4rmxg342f61sfvf4ygwf8ahb5r9q8arr863";
    };
  });

  yajs-vim = (buildVimPluginFrom2Nix {
    pname = "yajs.vim";
    version = "2019-02-01";

    src = fetchFromGitHub {
      owner = "othree";
      repo = "yajs.vim";
      rev = "437be4ccf0e78fe54cb482657091cff9e8479488";
      sha256 = "157q2w2bq1p6g1wc67zl53n6iw4l04qz2sqa5j6mgqg71rgqzk0p";
    };
  });

  vim-js = (buildVimPluginFrom2Nix {
    pname = "vim-js";
    version = "2021-03-28";

    src = fetchFromGitHub {
      owner = "yuezk";
      repo = "vim-js";
      rev = "90f340d31907590fad059cd9aab03a55ab49e352";
      sha256 = "sha256-SjBnT5Dh1FlcN89cf9NFTYMCCMNatje9EisYiAvPZ4A=";
    };
  });
}
