{
  addressable = {
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fvchp2rhp2rmigx7qglf69xvjqvzq7x0g49naliw29r2bz656sy";
      type = "gem";
    };
    version = "2.7.0";
  };
  adsf = {
    dependencies = [ "rack" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1w56jzrx2z1dd74qj3x641b3ar6i4c170xqfq51gja3fq35flkas";
      type = "gem";
    };
    version = "1.4.5";
  };
  colored = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b0x5jmsyi0z69bm6sij1k89z7h0laag3cb4mdn7zkl9qmxb90lx";
      type = "gem";
    };
    version = "1.2";
  };
  concurrent-ruby = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vnxrbhi7cq3p4y2v9iwd10v1c7l15is4var14hwnb2jip4fyjzz";
      type = "gem";
    };
    version = "1.1.7";
  };
  cri = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1bhsgnjav94mz5vf3305gxz1g34gm9kxvnrn1dkz530r8bpj0hr5";
      type = "gem";
    };
    version = "2.15.11";
  };
  ddmemoize = {
    dependencies = [ "ddmetrics" "ref" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ylhhfhd35zlr0wzcc069h0sishrfn27m0q54lf7ih092mccb6l";
      type = "gem";
    };
    version = "1.0.0";
  };
  ddmetrics = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0in0hk546q3js6qghbifjqvab6clyx5fjrwd3lcb0mk1ihmadyn2";
      type = "gem";
    };
    version = "1.0.1";
  };
  ddplugin = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "14hbvr6qjcn1i6pin8rq9kr02f98imskhrl8k53117mlfxxhl9sv";
      type = "gem";
    };
    version = "1.0.3";
  };
  diff-lcs = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m925b8xc6kbpnif9dldna24q1szg4mk0fvszrki837pfn46afmz";
      type = "gem";
    };
    version = "1.4.4";
  };
  hamster = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n1lsh96vnyc1pnzyd30f9prcsclmvmkdb3nm5aahnyizyiy6lar";
      type = "gem";
    };
    version = "3.0.0";
  };
  json_schema = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07df7lm7nz84b7pwqcpfh3h1320hhbj7pzc9djsbknwwvxa91jrc";
      type = "gem";
    };
    version = "0.20.9";
  };
  kramdown = {
    dependencies = [ "rexml" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vmw752c26ny2jwl0npn0gbyqwgz4hdmlpxnsld9qi9xhk5b1qh7";
      type = "gem";
    };
    version = "2.3.0";
  };
  nanoc = {
    dependencies = [ "addressable" "colored" "nanoc-checking" "nanoc-cli" "nanoc-core" "nanoc-deploying" "parallel" "tty-command" "tty-which" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n494k135q7qsazvcxqqhg2slcfw15ji622vamnjdi8v6fryqr3v";
      type = "gem";
    };
    version = "4.11.22";
  };
  nanoc-checking = {
    dependencies = [ "nanoc-cli" "nanoc-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "09bdmvq90s2pbxlala8ami6w2zb1zlqjhm69wn7wwxzh3kp2r9js";
      type = "gem";
    };
    version = "1.0.1";
  };
  nanoc-cli = {
    dependencies = [ "cri" "diff-lcs" "nanoc-core" "zeitwerk" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1626rln9dqmmf74ikzns80k7lr2qmq0v48ka4m4si12rkfz4x0hh";
      type = "gem";
    };
    version = "4.11.22";
  };
  nanoc-core = {
    dependencies = [ "concurrent-ruby" "ddmemoize" "ddmetrics" "ddplugin" "hamster" "json_schema" "slow_enumerator_tools" "tomlrb" "tty-platform" "zeitwerk" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dkgkvqx8075fx6jlyzin1hkykc9jjdqj930h6qzk4xq5qc7l2gi";
      type = "gem";
    };
    version = "4.11.22";
  };
  nanoc-deploying = {
    dependencies = [ "nanoc-checking" "nanoc-cli" "nanoc-core" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02l19qjsaj9rn1iw8fkpc1dmccgniggd4r7xvpsvvdl4nlrl56sq";
      type = "gem";
    };
    version = "1.0.1";
  };
  parallel = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0055br0mibnqz0j8wvy20zry548dhkakws681bhj3ycb972awkzd";
      type = "gem";
    };
    version = "1.20.1";
  };
  pastel = {
    dependencies = [ "tty-color" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0xash2gj08dfjvq4hy6l1z22s5v30fhizwgs10d6nviggpxsj7a8";
      type = "gem";
    };
    version = "0.8.0";
  };
  public_suffix = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1xqcgkl7bwws1qrlnmxgh8g4g9m10vg60bhlw40fplninb3ng6d9";
      type = "gem";
    };
    version = "4.0.6";
  };
  rack = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0i5vs0dph9i5jn8dfc6aqd6njcafmb20rwqngrf759c9cvmyff16";
      type = "gem";
    };
    version = "2.2.3";
  };
  ref = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04p4pq4sikly7pvn30dc7v5x2m7fqbfwijci4z1y6a1ilwxzrjii";
      type = "gem";
    };
    version = "2.0.0";
  };
  rexml = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1mkvkcw9fhpaizrhca0pdgjcrbns48rlz4g6lavl5gjjq3rk2sq3";
      type = "gem";
    };
    version = "3.2.4";
  };
  slow_enumerator_tools = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0phfj4jxymxf344cgksqahsgy83wfrwrlr913mrsq2c33j7mj6p6";
      type = "gem";
    };
    version = "1.1.0";
  };
  tomlrb = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00x5y9h4fbvrv4xrjk4cqlkm4vq8gv73ax4alj3ac2x77zsnnrk8";
      type = "gem";
    };
    version = "1.3.0";
  };
  tty-color = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0aik4kmhwwrmkysha7qibi2nyzb4c8kp42bd5vxnf8sf7b53g73g";
      type = "gem";
    };
    version = "0.6.0";
  };
  tty-command = {
    dependencies = [ "pastel" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1a7ig1fymx1amn29hk9y0i3l1xykcmlaqvs879zzc42llb0lb4nh";
      type = "gem";
    };
    version = "0.10.0";
  };
  tty-platform = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02h58a8yg2kzybhqqrhh4lfdl9nm0i62nd9jrvwinjp802qkffg2";
      type = "gem";
    };
    version = "0.3.0";
  };
  tty-which = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ki331s870p7j8yi58q8ig0gwy9kfgmjlq1jqs11h12mcm0mzi0a";
      type = "gem";
    };
    version = "0.4.2";
  };
  zeitwerk = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1746czsjarixq0x05f7p3hpzi38ldg6wxnxxw74kbjzh1sdjgmpl";
      type = "gem";
    };
    version = "2.4.2";
  };
}
