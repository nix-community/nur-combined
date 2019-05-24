{
  activesupport = {
    dependencies = ["i18n" "multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0fyxqkkws4px4lzkbcqzp0bwai7nn7jk4p0bgfy0dny9cwm0qc9r";
      type = "gem";
    };
    version = "3.2.22.5";
  };
  blockenspiel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1h701s45n5qprvcpc7fnr45n88p56x07pznkxqnhz1dbdbhb7xx8";
      type = "gem";
    };
    version = "0.5.0";
  };
  coderay = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "15vav4bhcc2x3jmi3izb11l4d9f3xv8hp2fszb7iqmpsccv1pz4y";
      type = "gem";
    };
    version = "1.1.2";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1ixcx9pfissxrga53jbdpza85qd5f6b5nq1sfqa9rnfq82qnlbp1";
      type = "gem";
    };
    version = "1.1.4";
  };
  daemons = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0l5gai3vd4g7aqff0k1mp41j9zcsvm2rbwmqn115a325k9r7pf4w";
      type = "gem";
    };
    version = "1.3.1";
  };
  diff-lcs = {
    groups = ["default" "development" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "18w22bjz424gzafv6nzv98h0aqkwz3d9xhm7cbr1wfbyas8zayza";
      type = "gem";
    };
    version = "1.3";
  };
  docile = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "04d2izkna3ahfn6fwq4xrcafa715d3bbqczxm16fq40fqy87xn17";
      type = "gem";
    };
    version = "1.3.1";
  };
  eventmachine = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0wh9aqb0skz80fhfn66lbpr4f86ya2z5rx6gm5xlfhd05bj1ch4r";
      type = "gem";
    };
    version = "1.2.7";
  };
  ffi = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0j8pzj8raxbir5w5k6s7a042sb5k02pg0f8s4na1r5lan901j00p";
      type = "gem";
    };
    version = "1.10.0";
  };
  formatador = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1gc26phrwlmlqrmz4bagq1wd5b7g64avpx0ghxr9xdxcvmlii0l0";
      type = "gem";
    };
    version = "0.2.5";
  };
  growl = {
    groups = ["local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0s0y7maljnalpbv2q1j5j5hvb4wcc31y9af0n7x1q2l0fzxgc9n9";
      type = "gem";
    };
    version = "1.0.3";
  };
  guard = {
    dependencies = ["formatador" "listen" "lumberjack" "nenv" "notiffany" "pry" "shellany" "thor"];
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0h84ja6qvii3hx86w9l4vjpbgl4m8ma8fbawwp7s8l791cgkdcmk";
      type = "gem";
    };
    version = "2.15.0";
  };
  guard-bundler = {
    dependencies = ["guard" "guard-compat"];
    groups = ["local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0lji8f8w7y4prmpr2lqmlljvkqgkgnlsiwqgwvq7b1y3sxlsvy62";
      type = "gem";
    };
    version = "2.2.1";
  };
  guard-compat = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1zj6sr1k8w59mmi27rsii0v8xyy2rnsi09nqvwpgj1q10yq1mlis";
      type = "gem";
    };
    version = "1.2.1";
  };
  guard-rspec = {
    dependencies = ["guard" "guard-compat" "rspec"];
    groups = ["local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1jkm5xp90gm4c5s51pmf92i9hc10gslwwic6mvk72g0yplya0yx4";
      type = "gem";
    };
    version = "4.7.3";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "038qvz7kd3cfxk8bvagqhakx68pfbnmghpdkx7573wbf0maqp9a3";
      type = "gem";
    };
    version = "0.9.5";
  };
  json = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  listen = {
    dependencies = ["rb-fsevent" "rb-inotify" "ruby_dep"];
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "01v5mrnfqm6sgm8xn2v5swxsn1wlmq7rzh2i48d4jzjsc7qvb6mx";
      type = "gem";
    };
    version = "3.1.5";
  };
  lumberjack = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "06im7gcg42x77yhz2w5da2ly9xz0n0c36y5ks7xs53v0l9g0vf5n";
      type = "gem";
    };
    version = "1.0.13";
  };
  method_source = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1pviwzvdqd90gn6y7illcdd9adapw8fczml933p5vl739dkvl3lq";
      type = "gem";
    };
    version = "0.9.2";
  };
  mini_portile2 = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "15zplpfw3knqifj9bpf604rb3wc1vhq6363pd6lvhayng8wql5vy";
      type = "gem";
    };
    version = "2.4.0";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1rl0qy4inf1mp8mybfk56dfga0mvx97zwpmq5xmiwl5r770171nv";
      type = "gem";
    };
    version = "1.13.1";
  };
  mustermann = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0lycgkmnyy0bf29nnd2zql5a6pcf8sp69g9v4xw0gcfcxgpwp7i1";
      type = "gem";
    };
    version = "1.0.3";
  };
  nenv = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0r97jzknll9bhd8yyg2bngnnkj8rjhal667n7d32h8h7ny7nvpnr";
      type = "gem";
    };
    version = "0.3.0";
  };
  nokogiri = {
    dependencies = ["mini_portile2"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "09zll7c6j7xr6wyvh5mm5ncj6pkryp70ybcsxdbw1nyphx5dh184";
      type = "gem";
    };
    version = "1.10.1";
  };
  notiffany = {
    dependencies = ["nenv" "shellany"];
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0x838fa5il0dd9zbm3lxkpbfxcf5fxv9556mayc2mxsdl5ghv8nx";
      type = "gem";
    };
    version = "0.1.1";
  };
  parseconfig = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0br2g9k6zc4ygah52aa8cwvpnnkszia29bnvnr8bhpk3rdzi2vmq";
      type = "gem";
    };
    version = "1.0.8";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "00rm71x0r1jdycwbs83lf9l6p494m99asakbvqxh8rz7zwnlzg69";
      type = "gem";
    };
    version = "0.12.2";
  };
  rack = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1pcgv8dv4vkaczzlix8q3j68capwhk420cddzijwqgi2qb4lm1zm";
      type = "gem";
    };
    version = "2.0.6";
  };
  rack-flash3 = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0rim9afrns6s8zc4apiymncysyvijpdg18k57kdpz66p55jf4mqz";
      type = "gem";
    };
    version = "1.0.5";
  };
  rack-protection = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "15167q25rmxipqwi6hjqj3i1byi9iwl3xq9b7mdar7qiz39pmjsk";
      type = "gem";
    };
    version = "2.0.5";
  };
  rack-test = {
    dependencies = ["rack"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0rh8h376mx71ci5yklnpqqn118z3bl67nnv5k801qaqn1zs62h8m";
      type = "gem";
    };
    version = "1.1.0";
  };
  rake = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0jcabbgnjc788chx31sihc5pgbqnlc1c75wakmqlbjdm8jns2m9b";
      type = "gem";
    };
    version = "10.5.0";
  };
  rb-fsevent = {
    groups = ["local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1lm1k7wpz69jx7jrc92w3ggczkjyjbfziq5mg62vjnxmzs383xx8";
      type = "gem";
    };
    version = "0.10.3";
  };
  rb-inotify = {
    dependencies = ["ffi"];
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1fs7hxm9g6ywv2yih83b879klhc4fs8i0p9166z795qmd77dk0a4";
      type = "gem";
    };
    version = "0.10.0";
  };
  rinku = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1smkk299v18brk98gqbdnqrfwm3143kikl30scidqb5j3pzlbz91";
      type = "gem";
    };
    version = "2.0.5";
  };
  rspec = {
    dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
    groups = ["development" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "14q3hxvngk4ks8h41yw50d5fqbf2dhzwi9rz5ccxvh5a53ak2as3";
      type = "gem";
    };
    version = "2.99.0";
  };
  rspec-core = {
    groups = ["default" "development" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1wwz21lcz2lwd2jcp2pvq7n1677v23acf7wxsyszp8msb47mw38i";
      type = "gem";
    };
    version = "2.99.2";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs"];
    groups = ["default" "development" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "11a5pph3anp4xr591dnlcy8xfkdf54qi2lvg4ykpqhxk37si1py3";
      type = "gem";
    };
    version = "2.99.2";
  };
  rspec-html-matchers = {
    dependencies = ["nokogiri" "rspec"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "148grzvk0cvh24avhl0shjzz7ldhj138svf48pc5h1fdsb0pnqcv";
      type = "gem";
    };
    version = "0.5.0";
  };
  rspec-mocks = {
    groups = ["default" "development" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0bzhqahbiswq41nqi6y2dka1k42n0hl14jb6bldb206zp4hikz8r";
      type = "gem";
    };
    version = "2.99.4";
  };
  ruby_dep = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1c1bkl97i9mkcvkn1jks346ksnvnnp84cs22gwl0vd7radybrgy5";
      type = "gem";
    };
    version = "1.5.0";
  };
  shellany = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1ryyzrj1kxmnpdzhlv4ys3dnl2r5r3d2rs2jwzbnd1v96a8pl4hf";
      type = "gem";
    };
    version = "0.0.1";
  };
  simple-navigation = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "08a2s18an3br3xj5j86r33q0hrkai0y157xg67h1khdskb08yylk";
      type = "gem";
    };
    version = "4.0.5";
  };
  simplecov = {
    dependencies = ["docile" "json" "simplecov-html"];
    groups = ["local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1sfyfgf7zrp2n42v7rswkqgk3bbwk1bnsphm24y7laxv3f8z0947";
      type = "gem";
    };
    version = "0.16.1";
  };
  simplecov-html = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1lihraa4rgxk8wbfl77fy9sf0ypk31iivly8vl3w04srd7i0clzn";
      type = "gem";
    };
    version = "0.10.2";
  };
  sinatra = {
    dependencies = ["mustermann" "rack" "rack-protection" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1gasgn5f15myv08k10i16p326pchxjsy37pgqfw0xm66kcc5d7ry";
      type = "gem";
    };
    version = "2.0.5";
  };
  sinatra-simple-navigation = {
    dependencies = ["simple-navigation" "sinatra"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1gishxd23qw6bwsk7fkagkfc7ihqyvvvb98j9bmwc6wwpsfs4prs";
      type = "gem";
    };
    version = "4.1.0";
  };
  taskwarrior-web = {
    dependencies = ["activesupport" "json" "parseconfig" "rack-flash3" "rinku" "sinatra" "sinatra-simple-navigation" "vegas" "versionomy"];
    groups = ["default"];
    platforms = [];
    bundledByPath = true;
    path = ./.;
    source = {
      path = ./.;
      type = "path";
    };
    version = "1.1.12";
  };
  thin = {
    dependencies = ["daemons" "eventmachine" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0nagbf9pwy1vg09k6j4xqhbjjzrg5dwzvkn4ffvlj76fsn6vv61f";
      type = "gem";
    };
    version = "1.7.2";
  };
  thor = {
    groups = ["default" "local"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1yhrnp9x8qcy5vc7g438amd5j9sw83ih7c30dr6g6slgw9zj3g29";
      type = "gem";
    };
    version = "0.20.3";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0ca4k0clwf0rkvy7726x4nxpjxkpv67w043i39saxgldxd97zmwz";
      type = "gem";
    };
    version = "2.0.9";
  };
  vegas = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0kzv0v1zb8vvm188q4pqwahb6468bmiamn6wpsbiq6r5i69s1bs5";
      type = "gem";
    };
    version = "0.1.11";
  };
  versionomy = {
    dependencies = ["blockenspiel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0i0l4pzrl1vyp4lpg2cxhgkk56spki3lld943d6h7168fj8qyv33";
      type = "gem";
    };
    version = "0.5.0";
  };
}
