{
  addressable = {
    dependencies = ["public_suffix"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0viqszpkggqi8hq87pqp0xykhvz60g99nwmkwsb0v45kc2liwxvk";
      type = "gem";
    };
    version = "2.5.2";
  };
  ansi = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14ims9zfal4gs2wpx2m5rd8zsrl2k794d359shkrsgg3fhr2a22l";
      type = "gem";
    };
    version = "1.5.0";
  };
  buftok = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rzsy1vy50v55x9z0nivf23y0r9jkmq6i130xa75pq9i8qrn1mxs";
      type = "gem";
    };
    version = "0.2.0";
  };
  chunky_png = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05g2xli9wbjylkmblln3bhvjalziwb92q452q8ibjagmb853424w";
      type = "gem";
    };
    version = "1.3.10";
  };
  daemons = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lxqq6dgb8xhliywar2lvkwqy2ssraf9dk4b501pb4ixc2mvxbp2";
      type = "gem";
    };
    version = "1.2.6";
  };
  data_objects = {
    dependencies = ["addressable"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19fw1ckqc5f1wc4r72qrymy2k6cmd8azbxpn61ksbsjqhzc2bgqd";
      type = "gem";
    };
    version = "0.10.17";
  };
  dm-core = {
    dependencies = ["addressable"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09x67ka6f1lxh4iwrg87iama0haq0d0z35gavvnvzpx9kn9pfbnw";
      type = "gem";
    };
    version = "1.2.1";
  };
  dm-do-adapter = {
    dependencies = ["data_objects" "dm-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1v84lsmsq8kawl8k4qz2h87xqc1sr10c08wwasrxbcgrkvp7qk4q";
      type = "gem";
    };
    version = "1.2.0";
  };
  dm-migrations = {
    dependencies = ["dm-core"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04hr8qgm4j1z5fg0cfpr8r6apvk5xykad0d0xqfg48rjv5rdwc0i";
      type = "gem";
    };
    version = "1.2.0";
  };
  dm-serializer = {
    dependencies = ["dm-core" "fastercsv" "json" "json_pure" "multi_json"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mvpb2d4cniysw45d3c9xidjpdb3wmfl7x5lgvnsfm69wq24v5y4";
      type = "gem";
    };
    version = "1.2.2";
  };
  dm-sqlite-adapter = {
    dependencies = ["dm-do-adapter" "do_sqlite3"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mq9xrw4jwb753sy8902rq9sfv62mzss2n3875g51i9acqy475hc";
      type = "gem";
    };
    version = "1.2.0";
  };
  do_sqlite3 = {
    dependencies = ["data_objects"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gxz54qjgwg6a2mkqpai28m0i5swbyxpr4qmh9x1nwf20lysrgcf";
      type = "gem";
    };
    version = "0.10.17";
  };
  domain_name = {
    dependencies = ["unf"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0abdlwb64ns7ssmiqhdwgl27ly40x2l27l8hs8hn0z4kb3zd2x3v";
      type = "gem";
    };
    version = "0.5.20180417";
  };
  em-websocket = {
    dependencies = ["eventmachine" "http_parser.rb"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bsw8vjz0z267j40nhbmrvfz7dvacq4p0pagvyp17jif6mj6v7n3";
      type = "gem";
    };
    version = "0.5.1";
  };
  equalizer = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kjmx3fygx8njxfrwcmn7clfhjhb6bvv3scy2lyyi0wqyi3brra4";
      type = "gem";
    };
    version = "0.0.11";
  };
  erubis = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
      type = "gem";
    };
    version = "2.7.0";
  };
  espeak-ruby = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0d658zr53jibyrs5qnic7bfl6h69k5987s8asncsbnxwbzzilj6y";
      type = "gem";
    };
    version = "1.0.4";
  };
  eventmachine = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17jr1caa3ggg696dd02g2zqzdjqj9x9q2nl7va82l36f7c5v6k4z";
      type = "gem";
    };
    version = "1.0.9.1";
  };
  execjs = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yz55sf2nd3l666ms6xr18sm2aggcvmb8qr3v53lr4rir32y1yp1";
      type = "gem";
    };
    version = "2.7.0";
  };
  fastercsv = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1df3vfgw5wg0s405z0pj0rfcvnl9q6wak7ka8gn0xqg4cag1k66h";
      type = "gem";
    };
    version = "1.5.5";
  };
  filesize = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "061qmg82mm9xnmnq3b7gbi24g28xk62w0b0nw86gybd07m1jn989";
      type = "gem";
    };
    version = "0.1.1";
  };
  geoip = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1if16n4pjl2kshc0cqg7i03m55fspmlca6p9f4r66rpzw0v4d6jc";
      type = "gem";
    };
    version = "1.6.4";
  };
  http = {
    dependencies = ["addressable" "http-cookie" "http-form_data" "http_parser.rb"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jlm5prw437wqpfxcigh88lfap3m7g8mnmj5as7qw6dzqnvrxwmc";
      type = "gem";
    };
    version = "3.3.0";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "004cgs4xg5n6byjs7qld0xhsjq3n6ydfh897myr2mibvh6fjc49g";
      type = "gem";
    };
    version = "1.0.3";
  };
  http-form_data = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15lpn604byf7cyxnw949xz4rvpcknqp7a48q73nm630gqxsa76f3";
      type = "gem";
    };
    version = "2.1.1";
  };
  "http_parser.rb" = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  jsobfu = {
    dependencies = ["rkelly-remix"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hchns89cfj0gggm2zbr7ghb630imxm2x2d21ffx2jlasn9xbkyk";
      type = "gem";
    };
    version = "0.4.2";
  };
  json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  json_pure = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vllrpm2hpsy5w1r7000mna2mhd7yfrmd8hi713lk0n9mv27bmam";
      type = "gem";
    };
    version = "1.8.6";
  };
  memoizable = {
    dependencies = ["thread_safe"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v42bvghsvfpzybfazl14qhkrjvx0xlmxz0wwqc960ga1wld5x5c";
      type = "gem";
    };
    version = "0.4.2";
  };
  metasm = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gss57q4lv6l0jkih77zffrpjjzgkdcsy7b9nvvawyzknis9w4s5";
      type = "gem";
    };
    version = "1.0.3";
  };
  mime-types = {
    dependencies = ["mime-types-data"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fjxy1jm52ixpnv3vg9ld9pr9f35gy0jp66i1njhqjvmnvq0iwwk";
      type = "gem";
    };
    version = "3.2.2";
  };
  mime-types-data = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07wvp0aw2gjm4njibb70as6rh5hi1zzri5vky1q6jx95h8l56idc";
      type = "gem";
    };
    version = "3.2018.0812";
  };
  mini_portile2 = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13d32jjadpjj6d2wdhkfpsmy68zjx90p49bgf8f7nkpz86r1fr11";
      type = "gem";
    };
    version = "2.3.0";
  };
  mojo_magick = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n4hzdyvaggzasxb55iqjd8sg6g84yc2dbaip0zzy7nwr5j5h8sm";
      type = "gem";
    };
    version = "0.5.6";
  };
  msfrpc-client = {
    dependencies = ["msgpack" "rex"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0q1x0xy857qm3sdxynp5p8kk7f6j25qjw1p28jh0y2qivc5ksik8";
      type = "gem";
    };
    version = "1.1.1";
  };
  msgpack = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09xy1wc4wfbd1jdrzgxwmqjzfdfxbz0cqdszq2gv6rmc3gv1c864";
      type = "gem";
    };
    version = "1.2.4";
  };
  multi_json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rl0qy4inf1mp8mybfk56dfga0mvx97zwpmq5xmiwl5r770171nv";
      type = "gem";
    };
    version = "1.13.1";
  };
  multipart-post = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09k0b3cybqilk1gwrwwain95rdypixb2q9w65gd44gfzsd84xi1x";
      type = "gem";
    };
    version = "2.0.0";
  };
  mustermann = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07sb7fckrraqh48fjnqf6yl7vxxabfx0qrsrhfdz67pd838g4k8g";
      type = "gem";
    };
    version = "1.0.2";
  };
  naught = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wwjx35zgbc0nplp8a866iafk4zsrbhwwz4pav5gydr2wm26nksg";
      type = "gem";
    };
    version = "1.1.0";
  };
  netrc = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  nokogiri = {
    dependencies = ["mini_portile2"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h9nml9h3m0mpvmh8jfnqvblnz5n5y3mmhgfc38avfmfzdrq9bgc";
      type = "gem";
    };
    version = "1.8.4";
  };
  parseconfig = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0br2g9k6zc4ygah52aa8cwvpnnkszia29bnvnr8bhpk3rdzi2vmq";
      type = "gem";
    };
    version = "1.0.8";
  };
  public_suffix = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08q64b5br692dd3v0a9wq9q5dvycc6kmiqmjbdxkxbfizggsvx6l";
      type = "gem";
    };
    version = "3.0.3";
  };
  qr4r = {
    dependencies = ["mojo_magick" "rqrcode"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ya71fxhmx2zfsmflmqh6xm9jwgjxamsj9d3h1kjp21w4vca0s30";
      type = "gem";
    };
    version = "0.4.1";
  };
  rack = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "158hbn7rlc3czp2vivvam44dv6vmzz16qrh5dbzhfxbfsgiyrqw1";
      type = "gem";
    };
    version = "2.0.5";
  };
  rack-protection = {
    dependencies = ["rack"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z5598qipilmnf45428jnxi63ykrgvnyywa5ckpr52zv2vpd8jdp";
      type = "gem";
    };
    version = "2.0.3";
  };
  rainbow = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bb2fpjspydr6x0s8pn1pqkzmxszvkfapv0p4627mywl7ky4zkhk";
      type = "gem";
    };
    version = "3.0.0";
  };
  rake = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1idi53jay34ba9j68c3mfr9wwkg3cd9qh0fn9cg42hv72c6q8dyg";
      type = "gem";
    };
    version = "12.3.1";
  };
  rb-readline = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14w79a121czmvk1s953qfzww30mqjb2zc0k9qhi0ivxxk3hxg6wy";
      type = "gem";
    };
    version = "0.5.5";
  };
  rest-client = {
    dependencies = ["http-cookie" "mime-types" "netrc"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hzcs2r7b5bjkf2x2z3n8z6082maz0j8vqjiciwgg3hzb63f958j";
      type = "gem";
    };
    version = "2.0.2";
  };
  rex = {
    dependencies = ["filesize" "jsobfu" "json" "metasm" "nokogiri" "rb-readline" "robots"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kxacxq4l1gcqbw1izg2qqvdhxl6b5779a2qa2jk24f6x96bpi68";
      type = "gem";
    };
    version = "2.0.11";
  };
  rexec = {
    dependencies = ["rainbow"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ihc0a6gj4i3287fjm86cn2ax4hlznyk5aqxrhjxkf4y9kabc3in";
      type = "gem";
    };
    version = "1.6.3";
  };
  rkelly-remix = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g7hjl9nx7f953y7lncmfgp0xgxfxvgfm367q6da9niik6rp1y3j";
      type = "gem";
    };
    version = "0.0.7";
  };
  robots = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "141gvihcr2c0dpzl3dqyh8kqc9121prfdql2iamaaw0mf9qs3njs";
      type = "gem";
    };
    version = "0.10.1";
  };
  rqrcode = {
    dependencies = ["chunky_png"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h1pnnydgs032psakvg3l779w3ghbn08ajhhhw19hpmnfhrs8k0a";
      type = "gem";
    };
    version = "0.10.1";
  };
  rubydns = {
    dependencies = ["eventmachine" "rexec"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mav6589kpqh37wlipkh1nww6ipbw4kzja2crz216v25wwjrbpx2";
      type = "gem";
    };
    version = "0.7.3";
  };
  rubyzip = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06js4gznzgh8ac2ldvmjcmg9v1vg9llm357yckkpylaj6z456zqz";
      type = "gem";
    };
    version = "1.2.1";
  };
  rushover = {
    dependencies = ["json" "rest-client"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j6x61drcdfnbvgmkmrc92zw67acpfcz5h1a29sdf884zkwd1444";
      type = "gem";
    };
    version = "0.3.0";
  };
  simple_oauth = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dw9ii6m7wckml100xhjc6vxpjcry174lbi9jz5v7ibjr3i94y8l";
      type = "gem";
    };
    version = "0.3.1";
  };
  sinatra = {
    dependencies = ["mustermann" "rack" "rack-protection" "tilt"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kyi55q4k4idv31h7l53hw0mnh50dwwrrsfm35j52jy7fc993m9r";
      type = "gem";
    };
    version = "2.0.3";
  };
  slack-notifier = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pkfn99dhy5s526r6k8d87fwwb6j287ga9s7lxqmh60z28xqh3bv";
      type = "gem";
    };
    version = "2.3.2";
  };
  term-ansicolor = {
    dependencies = ["tins"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b1wq9ljh7v3qyxkk8vik2fqx2qzwh5lval5f92llmldkw7r7k7b";
      type = "gem";
    };
    version = "1.6.0";
  };
  thin = {
    dependencies = ["daemons" "eventmachine" "rack"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nagbf9pwy1vg09k6j4xqhbjjzrg5dwzvkn4ffvlj76fsn6vv61f";
      type = "gem";
    };
    version = "1.7.2";
  };
  thread_safe = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  tilt = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0020mrgdf11q23hm1ddd6fv691l51vi10af00f137ilcdb2ycfra";
      type = "gem";
    };
    version = "2.0.8";
  };
  tins = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g95xs4nvx5n62hb4fkbkd870l9q3y9adfc4h8j21phj9mxybkb8";
      type = "gem";
    };
    version = "1.16.3";
  };
  twitter = {
    dependencies = ["addressable" "buftok" "equalizer" "http" "http-form_data" "http_parser.rb" "memoizable" "multipart-post" "naught" "simple_oauth"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fjyz3viabz3xs5d9aad18zgdbhfwm51jsnzigc8kxk77p1x58n5";
      type = "gem";
    };
    version = "6.2.0";
  };
  uglifier = {
    dependencies = ["execjs"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14r283lkhisq2sdccv8ngf10f2f18ly4nc3chz3kliw5nylbgznw";
      type = "gem";
    };
    version = "4.1.18";
  };
  unf = {
    dependencies = ["unf_ext"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06p1i6qhy34bpb8q8ms88y6f2kz86azwm098yvcc0nyqk9y729j1";
      type = "gem";
    };
    version = "0.0.7.5";
  };
  xmlrpc = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s744iwblw262gj357pky3d9fcx9hisvla7rnw29ysn5zsb6i683";
      type = "gem";
    };
    version = "0.3.0";
  };
}