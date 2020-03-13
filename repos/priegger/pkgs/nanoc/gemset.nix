{
  addressable = {
    dependencies = [ "public_suffix" ];
    groups = [ "default" ];
    platforms = [];
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
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vzy12c941xfhwc29zdl1hq3mqnbvh5l1i13ky0d658a79009f63";
      type = "gem";
    };
    version = "1.4.3";
  };
  colored = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0b0x5jmsyi0z69bm6sij1k89z7h0laag3cb4mdn7zkl9qmxb90lx";
      type = "gem";
    };
    version = "1.2";
  };
  concurrent-ruby = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "094387x4yasb797mv07cs3g6f08y56virc2rjcpb1k79rzaj3nhl";
      type = "gem";
    };
    version = "1.1.6";
  };
  cri = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1h45kw2s4bjwgbfsrncs30av0j4zjync3wmcc6lpdnzbcxs7yms2";
      type = "gem";
    };
    version = "2.15.10";
  };
  ddmemoize = {
    dependencies = [ "ddmetrics" "ref" ];
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15ylhhfhd35zlr0wzcc069h0sishrfn27m0q54lf7ih092mccb6l";
      type = "gem";
    };
    version = "1.0.0";
  };
  ddmetrics = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0in0hk546q3js6qghbifjqvab6clyx5fjrwd3lcb0mk1ihmadyn2";
      type = "gem";
    };
    version = "1.0.1";
  };
  ddplugin = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "07vsrs2m4wcyqf6jba9prymchvbn1xis52g68953yk6dbv67s7f1";
      type = "gem";
    };
    version = "1.0.2";
  };
  diff-lcs = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "18w22bjz424gzafv6nzv98h0aqkwz3d9xhm7cbr1wfbyas8zayza";
      type = "gem";
    };
    version = "1.3";
  };
  equatable = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0fzx2ishipnp6c124ka6fiw5wk42s7c7gxid2c4c1mb55b30dglf";
      type = "gem";
    };
    version = "0.6.1";
  };
  hamster = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1n1lsh96vnyc1pnzyd30f9prcsclmvmkdb3nm5aahnyizyiy6lar";
      type = "gem";
    };
    version = "3.0.0";
  };
  json_schema = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1d88bjxrqrpjn58rjvpz9kjpnnsrqi4zpjsrvx25sk1bd8shqy3k";
      type = "gem";
    };
    version = "0.20.8";
  };
  kramdown = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1dl840bvx8d9nq6lg3mxqyvbiqnr6lk3jfsm6r8zhz7p5srmd688";
      type = "gem";
    };
    version = "2.1.0";
  };
  nanoc = {
    dependencies = [ "addressable" "colored" "nanoc-cli" "nanoc-core" "parallel" "tty-command" "tty-which" ];
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01gyjh5cav7py91lpmis3n25pfhbh6inx0cl3zssd0j8h5a1b68l";
      type = "gem";
    };
    version = "4.11.14";
  };
  nanoc-cli = {
    dependencies = [ "cri" "diff-lcs" "nanoc-core" "zeitwerk" ];
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05px70zxinlbz01hv4hci1lizmcxzfq3xzirwhkdj8mqr46lp518";
      type = "gem";
    };
    version = "4.11.14";
  };
  nanoc-core = {
    dependencies = [ "ddmemoize" "ddmetrics" "ddplugin" "hamster" "json_schema" "slow_enumerator_tools" "tomlrb" "tty-platform" "zeitwerk" ];
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0abpfc3klm07v8d5hnrg6znswxyj0qjbfjaqj7nr6iaxqvakmrxg";
      type = "gem";
    };
    version = "4.11.14";
  };
  parallel = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "12jijkap4akzdv11lm08dglsc8jmc87xcgq6947i1s3qb69f4zn2";
      type = "gem";
    };
    version = "1.19.1";
  };
  pastel = {
    dependencies = [ "equatable" "tty-color" ];
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0m43wk7gswwkl6lfxwlliqc9v1qp8arfygihyz91jc9icf270xzm";
      type = "gem";
    };
    version = "0.7.3";
  };
  public_suffix = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c6kq6s13idl2036b5lch8r7390f8w82cal8hcp4ml76fm2vdac7";
      type = "gem";
    };
    version = "4.0.3";
  };
  rack = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "10mp9s48ssnw004aksq90gvhdvwczh8j6q82q2kqiqq92jd1zxbp";
      type = "gem";
    };
    version = "2.2.2";
  };
  ref = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "04p4pq4sikly7pvn30dc7v5x2m7fqbfwijci4z1y6a1ilwxzrjii";
      type = "gem";
    };
    version = "2.0.0";
  };
  slow_enumerator_tools = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0phfj4jxymxf344cgksqahsgy83wfrwrlr913mrsq2c33j7mj6p6";
      type = "gem";
    };
    version = "1.1.0";
  };
  tomlrb = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0njkyq5csj4km8spmw33b5902v254wvyvqq1b0f0kky5hs7bvrgg";
      type = "gem";
    };
    version = "1.2.9";
  };
  tty-color = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0czbnp19cfnf5zwdd22payhqjv57mgi3gj5n726s20vyq3br6bsp";
      type = "gem";
    };
    version = "0.5.1";
  };
  tty-command = {
    dependencies = [ "pastel" ];
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cqqy9pn1b9j1mbkxwxwk7hlk2jh0lzsi9qr19p4hc0r1axcndjk";
      type = "gem";
    };
    version = "0.9.0";
  };
  tty-platform = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "02h58a8yg2kzybhqqrhh4lfdl9nm0i62nd9jrvwinjp802qkffg2";
      type = "gem";
    };
    version = "0.3.0";
  };
  tty-which = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ki331s870p7j8yi58q8ig0gwy9kfgmjlq1jqs11h12mcm0mzi0a";
      type = "gem";
    };
    version = "0.4.2";
  };
  zeitwerk = {
    groups = [ "default" ];
    platforms = [];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0jywi63w1m2b2w9fj9rjb9n3imf6p5bfijfmml1xzdnsrdrjz0x1";
      type = "gem";
    };
    version = "2.2.2";
  };
}
