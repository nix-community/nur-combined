{
  addressable = {
    dependencies = [ "public_suffix" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05r1fwy487klqkya7vzia8hnklcxy4vr92m9dmni3prfwk6zpw33";
      type = "gem";
    };
    version = "2.8.5";
  };
  awesome_print = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0vkq6c8y2jvaw03ynds5vjzl1v9wg608cimkd3bidzxc0jvk56z9";
      type = "gem";
    };
    version = "1.9.2";
  };
  aws-eventstream = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pyis1nvnbjxk12a43xvgj2gv0mvp4cnkc1gzw0v1018r61399gz";
      type = "gem";
    };
    version = "1.2.0";
  };
  aws-partitions = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nf88fxw2nfgrvm7bbrq918kymq1g45sw1d9zwyc5gf60gwmw4y7";
      type = "gem";
    };
    version = "1.848.0";
  };
  aws-sdk-core = {
    dependencies = [ "aws-eventstream" "aws-partitions" "aws-sigv4" "jmespath" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19zl449qzc2ir0yzwhdy82nkm0ycd1822pym6b2i0h1k7zw69may";
      type = "gem";
    };
    version = "3.186.0";
  };
  aws-sdk-kms = {
    dependencies = [ "aws-sdk-core" "aws-sigv4" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "01z32ryrl18al0hazyimww808ij144pgs5m8wmp0k49i7k33hnlw";
      type = "gem";
    };
    version = "1.72.0";
  };
  aws-sdk-s3 = {
    dependencies = [ "aws-sdk-core" "aws-sdk-kms" "aws-sigv4" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wm4k4i1rplddrm4pnr39biv1fikc5jg8l48z84knh05bxp8wvln";
      type = "gem";
    };
    version = "1.116.0";
  };
  aws-sigv4 = {
    dependencies = [ "aws-eventstream" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1wzi7mkyfcr23y8r3dx64zqil115rjy8d9nmkd2q5a6ssxs8y58w";
      type = "gem";
    };
    version = "1.6.1";
  };
  chef-cleanroom = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1zk538501nxrsrya8da01nzksnmyayhiw28n38fi3rd1b5vzvdxl";
      type = "gem";
    };
    version = "1.0.5";
  };
  chef-config = {
    dependencies = [ "addressable" "chef-utils" "fuzzyurl" "mixlib-config" "mixlib-shellout" "tomlrb" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1pvjf3qbb3apg9vdy4zykamm7801qz4m6256wjqn73fs87zs50y1";
      type = "gem";
    };
    version = "18.3.0";
  };
  chef-utils = {
    dependencies = [ "concurrent-ruby" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0087jwhqslfm3ygj507dmmdp3k0589j5jl54mkwgbabbwan7lzw2";
      type = "gem";
    };
    version = "18.3.0";
  };
  citrus = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0l7nhk3gkm1hdchkzzhg2f70m47pc0afxfpl6mkiibc9qcpl3hjf";
      type = "gem";
    };
    version = "3.0.2";
  };
  concurrent-ruby = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0krcwb6mn0iklajwngwsg850nk8k9b35dhmc2qkbdqvmifdi2y9q";
      type = "gem";
    };
    version = "1.2.2";
  };
  contracts = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rld0n4k9iimrgbi38yfwdjgql6wiaqvmddyggsvvvrw1bcdrz99";
      type = "gem";
    };
    version = "0.16.1";
  };
  ffi = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1yvii03hcgqj30maavddqamqy50h7y6xcn2wcyq72wn823zl4ckd";
      type = "gem";
    };
    version = "1.16.3";
  };
  ffi-yajl = {
    dependencies = [ "libyajl2" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0dj3y95260rvlclkkcxak6c1dsrzbyr4wik7jv3y949r4w9adfk9";
      type = "gem";
    };
    version = "2.6.0";
  };
  fuzzyurl = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03qchs33vfwbsv5awxg3acfmlcrf5xbhnbrc83fdpamwya0glbjl";
      type = "gem";
    };
    version = "0.9.0";
  };
  iostruct = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1z3vnb8mhzns3ybf78vlj5cy6lq4pyfm8n40kqba2s33xccs3kl0";
      type = "gem";
    };
    version = "0.0.5";
  };
  ipaddress = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x86s0s11w202j6ka40jbmywkrx8fhq8xiy8mwvnkhllj57hqr45";
      type = "gem";
    };
    version = "0.8.3";
  };
  jmespath = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1cdw9vw2qly7q7r41s7phnac264rbsdqgj4l0h4nqgbjb157g393";
      type = "gem";
    };
    version = "1.6.2";
  };
  json = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0nalhin1gda4v8ybk6lq8f407cgfrj6qzn234yra4ipkmlbfmal6";
      type = "gem";
    };
    version = "2.6.3";
  };
  libyajl2 = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1vx0mv0bbcy0qh3ik08b42vrq4kw1zg51121r18c0vvp4p3zcpda";
      type = "gem";
    };
    version = "2.1.0";
  };
  license_scout = {
    dependencies = [ "ffi-yajl" "mixlib-shellout" "toml-rb" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1qa3v5jizcmynsa6r1jyk403bfllpsxq9jwqdrdfjvvjk52fcq1l";
      type = "gem";
    };
    version = "1.3.6";
  };
  mixlib-cli = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1ydxlfgd7nnj3rp1y70k4yk96xz5cywldjii2zbnw3sq9pippwp6";
      type = "gem";
    };
    version = "2.1.8";
  };
  mixlib-config = {
    dependencies = [ "tomlrb" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j0122lv2qgccl61njqi0pj6sp6nb85y07gcmw16bwg4k0c8nx6p";
      type = "gem";
    };
    version = "3.0.27";
  };
  mixlib-log = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n5dm5iz90ijvjn59jfm8gb8hgsvbj0f1kpzbl38b02z0z4a4v7x";
      type = "gem";
    };
    version = "3.0.9";
  };
  mixlib-shellout = {
    dependencies = [ "chef-utils" ];
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0zkwg76y96nkh1mv0k92ybq46cr06v1wmic16129ls3yqzwx3xj6";
      type = "gem";
    };
    version = "3.2.7";
  };
  mixlib-versioning = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cqyrcgw2xwxmjhwa31ipmphkg5aa6x4fd5c5j9y7hifw32pb1vr";
      type = "gem";
    };
    version = "1.2.12";
  };
  multipart-post = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0lgyysrpl50wgcb9ahg29i4p01z0irb3p9lirygma0kkfr5dgk9x";
      type = "gem";
    };
    version = "2.3.0";
  };
  net-scp = {
    dependencies = [ "net-ssh" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1si2nq9l6jy5n2zw1q59a5gaji7v9vhy8qx08h4fg368906ysbdk";
      type = "gem";
    };
    version = "4.0.0";
  };
  net-ssh = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1jyj6j7w9zpj2zhp4dyhdjiwsn9rqwksj7s7fzpnn7rx2xvz2a1a";
      type = "gem";
    };
    version = "7.2.0";
  };
  ohai = {
    dependencies = [ "chef-config" "chef-utils" "ffi" "ffi-yajl" "ipaddress" "mixlib-cli" "mixlib-config" "mixlib-log" "mixlib-shellout" "plist" "train-core" "wmi-lite" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15fz0ws8q9635rl5y4jyiwxbibr9ilba4askazhrgy4pcmmgs34q";
      type = "gem";
    };
    version = "18.1.3";
  };
  omnibus = {
    dependencies = [ "aws-sdk-s3" "chef-cleanroom" "chef-utils" "contracts" "ffi-yajl" "license_scout" "mixlib-shellout" "mixlib-versioning" "ohai" "pedump" "rexml" "ruby-progressbar" "thor" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "16nl4cpwm0d9phd12fg4sqh0la4m8588464bplx5d31pnnl07y0c";
      type = "gem";
    };
    version = "9.0.23";
  };
  pedump = {
    dependencies = [ "awesome_print" "iostruct" "multipart-post" "rainbow" "zhexdump" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1c8vx2db2la1dga24zyi7dq42x8zwp80npr916v2gdpqdjk1b52g";
      type = "gem";
    };
    version = "0.6.6";
  };
  plist = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0wzhnbzraz60paxhm48c50fp9xi7cqka4gfhxmiq43mhgh5ajg3h";
      type = "gem";
    };
    version = "3.7.0";
  };
  public_suffix = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0n9j7mczl15r3kwqrah09cxj8hxdfawiqxa60kga2bmxl9flfz9k";
      type = "gem";
    };
    version = "5.0.3";
  };
  rainbow = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  rexml = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "05i8518ay14kjbma550mv0jm8a6di8yp5phzrd8rj44z9qnrlrp0";
      type = "gem";
    };
    version = "3.2.6";
  };
  ruby-progressbar = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
    version = "1.13.0";
  };
  thor = {
    groups = [ "default" "development" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1hx77jxkrwi66yvs10wfxqa8s25ds25ywgrrf66acm9nbfg7zp0s";
      type = "gem";
    };
    version = "1.3.0";
  };
  toml-rb = {
    dependencies = [ "citrus" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "19nr4wr5accc6l2y3avn7b02lqmk9035zxq42234k7fcqd5cbqm1";
      type = "gem";
    };
    version = "2.2.0";
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
  train-core = {
    dependencies = [ "addressable" "ffi" "json" "mixlib-shellout" "net-scp" "net-ssh" ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1j3pfsdrrqpcqp9qbqdh4j1557hww3q3gyjjpnzmgkw43vv685gb";
      type = "gem";
    };
    version = "3.11.0";
  };
  wmi-lite = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1nnx4xz8g40dpi3ccqk5blj1ck06ydx09f9diksn1ghd8yxzavhi";
      type = "gem";
    };
    version = "1.0.7";
  };
  zhexdump = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0sci7ys0lfgdhw8vaiwwag056nam173vd9129m37rybxvy5fkaxx";
      type = "gem";
    };
    version = "0.0.2";
  };
}
