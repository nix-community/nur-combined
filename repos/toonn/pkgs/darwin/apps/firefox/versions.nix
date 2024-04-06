{ lib }:
# To update run:
# nix-prefetch-url --name 'firefox-app-<version>.dmg' 'https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US'
let inherit (builtins) attrNames compareVersions mapAttrs;
    inherit (lib) recursiveUpdate;
    inherit (lib.lists) foldr;
    addVersion = mapAttrs (n: v: v // { "version" = n; });
    versions = addVersion {
      "86.0" = {
        sha256 = "04jslsfg073xb965hvbm7vdrdymkaiyyrgclv9qdpcyplis82rxc";
      };
      "86.0.1" = {
        sha256 = "1cd55z11wpkgi1lnidwg8kdxy8b6p00arz07sizrbyiiqxzrmvx3";
      };
      "87.0" = {
        sha256 = "1cih6i2p53mchqqrw2wlqhfka59p5qm4a7d0zc9ism0gvq5zpiz2";
      };
      "88.0" = {
        sha256 = "0cqgizwfhh9vh49swpi2vbdrqr5ri6jlir29bsf397ijvgss24lf";
      };
      "88.0.1" = {
        sha256 = "0z9p6jng7is8pq21dffjr6mfk81q08v99fwmhj22g9b1miqxrvcz";
      };
      "89.0" = {
        sha256 = "0z86q1hlwmhfwrddhapwiy8qrn3v03d7nbsnzhnkr3fc9vz58ga3";
      };
      "89.0.1" = {
        sha256 = "02pvwsjaz60graha7hz25z3kx24ycvcfgwpzzdv5xpb3cfmlvis9";
      };
      "89.0.2" = {
        sha256 = "0hwhnmd88ymy0binw10azq81f09qmdz6gmd2jlvh7q234cy168nc";
      };
      "90.0" = {
        sha256 = "0qw8biv5p7j1gqz0ziadj7hd0kh86nlndwxvc39ifq52w8w81h6v";
      };
      "90.0.1" = {
        sha256 = "018zfpgc16k7g6hpixv72f21haknsfvrhahi9jzfbisj5g2bkhbn";
      };
      "90.0.2" = {
        sha256 = "00yxk43pa2f7s565b4g6cs0nv5wr023xmw1ajq45ksacp2kzp93k";
      };
      "91.0" = {
        sha256 = "1yx647d1aibw3ydjpl8ysgz2smim48x6bykq2lq3y2rjj3s46v6j";
      };
      "91.0.1" = {
        sha256 = "0a7snz0qxbzhwbqkwmbivfx9zn4b009qy8xz74wk47an60dschz7";
      };
      "91.0.2" = {
        sha256 = "0c5b7k4q7k3q9lk0k22h6csk3bwqxkkfya6rskb5k9knn7qzyis1";
      };
      "92.0" = {
        sha256 = "0kln28330jhmpdvsdsnrqnl0fkpb18i9vi1n98v99aq61ncqr5v8";
      };
      "92.0.1" = {
        sha256 = "1sy856rbfavzbyhrb7kii0k32v674nv67vqr7a6211db2nii297q";
      };
      "93.0" = {
        sha256 = "1ihb85kxnwxsgbr4iy0nm6zqs5mn7ww9in8m3r1yws5zq8l8dixl";
      };
      "94.0" = {
        sha256 = "0s7fwcfyr9xkfxn7awbhjin9v5v775rmb897x8l2kc1vpaia1kz0";
      };
      "94.0.1" = {
        sha256 = "1rsfm8m66rvyabsd4jk5rxkqq4d2n8nc2m93j4xwmh2z57rgr7p4";
      };
      "94.0.2" = {
        sha256 = "0n8rmfir41rrkfr7w7d93qgg3dah3dbjkwbh3d70c7pkg3q69pji";
      };
      "95.0" = {
        sha256 = "0107dk73r8wgd7v8aq6vzw7jb0aibfvizmrq1fkh9bb2maxr53yz";
      };
      "95.0.1" = {
        sha256 = "07v2vfgi29b47phhrymc7py5dqw7ry4792ma3nxmsaazlzvynff4";
      };
      "95.0.2" = {
        sha256 = "0mwcql2dqq455qzqmy88v1s0jd3a4mcx2w2jrnpj1ny1fwfr08z8";
      };
      "96.0" = {
        sha256 = "069hs653gia47zn63ifzwzdg74yv1vz8yjxqrnxj6pr4biv326wc";
      };
      "96.0.1" = {
        sha256 = "04whbik90cjl3kgxzsggm29kyn2q8fb3aqw83ia86x2g5gnq6rqc";
      };
      "96.0.2" = {
        sha256 = "0b848lc1viwz41chp8m146vmyrypnpq82wn540l8mlihqmyjz67w";
      };
      "96.0.3" = {
        sha256 = "1vr8x87vndmlv3vybq0z9xqi8fglmlwri2rvqsjdywwjwqy6fg44";
      };
      "97.0" = {
        sha256 = "0x7gl8d154bxalwjlckm3a0qzmndsk843gn30mfzbjls2xc4wv60";
      };
      "97.0.1" = {
        sha256 = "1yksizx80m18gipnsb2migc98gyxg3szvmg5x2z7lp8nlb890bqp";
      };
      "97.0.2" = {
        sha256 = "0zxph8lnzxg3q6gplld7g3qvhkny45qw4xqyph3vzrvrdqa6chs0";
      };
      "98.0" = {
        sha256 = "1rlk3gmvx9csqn1r7vv007qfjah8gspkyzmgfwi7pgk9qa7i0kyh";
      };
      "98.0.1" = {
        sha256 = "1jxm6hm8ll0agdvkfd432g71azkmv10yhf8zd7m20igpcih3wzcc";
      };
      "98.0.2" = {
        sha256 = "0lcqm5flyv8ncdvpxr7jgapyhvfm42spc5db7lqs1k8dgj8zsk9h";
      };
      "99.0" = {
        sha256 = "08znrjx3by053ia2xyxqfi35h9wa2qa10xdm3vsbfirx7zbnfhy5";
      };
      "99.0.1" = {
        sha256 = "1bqkd30m0kiyb7lfh26jjf0ilwn1f27r3nc957xsjxxgx7pqjvdy";
      };
      "100.0" = {
        sha256 = "0414dsw0pgyik6lfd151al5nsrsh7dvp3bkqygxxn4cpj2b3pyi5";
      };
      "100.0.1" = {
        sha256 = "17d1ikm56wpnr24bhqwg6apm9s18asmmv04wzn38bj34gvazsy3l";
      };
      "100.0.2" = {
        sha256 = "0gs849967ypny9rn1sd83g0njif6rl9njh5i9cfwm2pkpr5qjzqj";
      };
      "101.0" = {
        sha256 = "1w35ph0kmv7mvm2cg693h56cfpc89gba226acjcblbr94ji7m03y";
      };
      "101.0.1" = {
        sha256 = "197ji61psbgbh1gydj33qw3ms4ikwrlj512cf2mg1p0470jnlqzk";
      };
      "102.0" = {
        sha256 = "0pvjcsmkim8gq7nbrq8apd2gxg5fbnysma9k5m70m5krx71dmilk";
      };
      "102.0.1" = {
        sha256 = "03dsjbdbfcb9cb5553f4zmjyxp7ma9hcrp8l142bf3hc8jpilfmn";
      };
      "103.0" = {
        sha256 = "0l3pnrpgxx5r9l52il0lh99nm6982mwr86z3hkdllj70cibm33i2";
      };
      "103.0.1" = {
        sha256 = "0f7b2jn18h1mxxfkafa6nyn8jhjbj48y5rgyyxyjdjcsf7rmw6d2";
      };
      "103.0.2" = {
        sha256 = "191ylzf31r2qjg6dz39xqb32mmh3zkc1vzndx7k1w8qd63nf5sf3";
      };
      "104.0.1" = {
        sha256 = "0zjzvph1svdkpwang6rjpdv96k5xmcyhvvh52jv8s8b8as0v1xy6";
      };
      "104.0.2" = {
        sha256 = "0dlls8vkzr644ikjx0cp1syqi244yyjz7grpspfs9akzr9gc37g4";
      };
      "105.0.1" = {
        sha256 = "1vlqn10lqkpjy7rmmq8i2wsp4x8wpii9bihf1naa9pz6v39gaxzn";
      };
      "105.0.2" = {
        sha256 = "0v8cv4bssykhgslvg85nwsdckglav2w6a7qc6lzlll3ygxp03h81";
      };
      "105.0.3" = {
        sha256 = "16h5n7gn0hbxn1q6970v8yijf437w3v06rsw78bii9g44rrqmsd0";
      };
      "106.0.1" = {
        sha256 = "0y4430rr6897znq2c01zl8djywqw3w93vlm6qkd6yaznririfp6f";
      };
      "106.0.2" = {
        sha256 = "1p931wm85lfj00g155qiyjr5bh6nvfm6g0mj8iqf970z9vb7zdcs";
      };
      "106.0.3" = {
        sha256 = "1kx23m5iqxg74vy5zb0137fgda7l8xwpb4nhj92kdx5ip64zvgwz";
      };
      "106.0.4" = {
        sha256 = "1h5pwvdyj5g8n24sc1sw0drvw7amqqxn5d7k177g2zxlmy62wg6c";
      };
      "106.0.5" = {
        sha256 = "1i3ps0wrdagpgi8bfyyr4gmax25mgdi4z6x0gd7kjm7rz5d5dixp";
      };
      "107.0" = {
        sha256 = "05fmw7lb30nwkz4clpyzwj2mrsd1rqwwplbjb0pw77hkpyz4590z";
      };
      "107.0.1" = {
        sha256 = "1w7si9a4fp9ag3v3vzh5fqjcf4sd70j3h5l9bi20h4c1zrsmyid1";
      };
      "108.0.1" = {
        sha256 = "0dphd3ny1vfbhnha8l9yl1j8hahw4a99jcphvkcv6djwm4hqd58q";
      };
      "108.0.2" = {
        sha256 = "0lihwn2920pcvf45393yzd3q9k1nz6kb670p92hclwjxqadb3gqc";
      };
      "109.0" = {
        sha256 = "1kqmnaqf64fvglgrjlk828rzqqhgdxf8h3wpsz0cda2c21rwf4np";
      };
      "109.0.1" = {
        sha256 = "1fjr279s9irvwacg6ir2d4lkqmvmm26dpsnl21vk3zr4b1kz2sad";
      };
      "110.0" = {
        sha256 = "191spg9hrnn7l2nfrv6dmz4376hkgy02wvxa49pq2njnckfn2l9h";
      };
      "110.0.1" = {
        sha256 = "0326d571pzmlb0kx0rkj56cm04bdw8ab1278w8d4nnjdhm4wbk0j";
      };
      "111.0" = {
        sha256 = "04dzzray3ishr7cdg5x8s0kiv6bf64rfql8r6kn14fxjwc7ksvqn";
      };
      "111.0.1" = {
        sha256 = "0fx6pl1jf5n3p7x2q5wccdjf2afr3pm3lfm4q7jqnvpbpmcdxq11";
      };
      "112.0" = {
        sha256 = "1023m4mlzhafkjzwkaz8ygwm41gvra4q7l6xmhf9vdj37kdv6v0f";
      };
      "112.0.1" = {
        sha256 = "07rvhbvjpib54qk6m5imh9dysb4zvxjr9lzg620n75w4c14jlm9j";
      };
      "112.0.2" = {
        sha256 = "0za4dpaidzzai52rgqadnqr772s00ibvxn640ywscbdmns2jc3ck";
      };
      "113.0" = {
        sha256 = "1mvf38zf8c3j5i4qq7y45fc8c54d3i7dy6wk8lqw2h83p1a6cm3c";
      };
      "113.0.1" = {
        sha256 = "1fa0h95pqq5myaj5b4d8z687d7vigyi6rpz98s13g1sq8drsamlm";
      };
      "113.0.2" = {
        sha256 = "0958ixrdr2fy26x2z3rcj18pb035vxp1lh1xch7yj538gds9sx28";
      };
      "114.0" = {
        sha256 = "16lpfqdh5b8pnkdsz7nsld6c7spnqdmdhx68h62vx0v2jv08xigh";
      };
      "114.0.1" = {
        sha256 = "1gdbaybjmff0wa4cphfdnknqxwajhncrxivxzc1c6ppc6v386ryx";
      };
      "114.0.2" = {
        sha256 = "0qrh52hx5zqxx55f9m5xd0hwzvv8wi5604mwqd8an1bqmvvzqx1i";
      };
      "115.0" = {
        sha256 = "12lhqib5cxqknkz8m9yliyn6cpr0rgqv97ar1hypk6lzdl0acsyj";
      };
      "115.0.1" = {
        sha256 = "0yli03i1c1gpfzfy1p13brc06g6iz3bd1c6pxsqzj76h9jpgh7va";
      };
      "115.0.2" = {
        sha256 = "0nirfvd5ljycd44k9pdzkl5l45fk9xa8ax0wbf6ycky2gcpqxwmj";
      };
      "115.0.3" = {
        sha256 = "18rzwzb7xcdssggjzl711cqfw81xn7h018jnsym2qdcm1xnn3cln";
      };
      # No longer supported on macOS 10.14 and below
      "116.0" = {
        sha256 = "1gs0adfb3lqmx4vy3388r1fck0lnb1pkzd452w9dqz3378mb3g59";
      };
    } // { esr = addVersion {
             # Security updates until September 2024
             "115.1.0esr" = {
               sha256 = "1v4wlg5cind0kqkxzakqa6d1gian2yjaxmk1vrw6nwl7zcc1aj7h";
             };
             "115.2.0esr" = {
               sha256 = "0qcbjqqppgw547xcawdcddbg1jl7si327av6xlniqf4dhmq48yq2";
             };
           };
         };
    latestVersion = versions: default: foldr (v: lV:
                                               if compareVersions v lV == 1
                                               then v
                                               else lV
                                             )
                                             default
                                             (attrNames versions);
in recursiveUpdate
     versions
     { "latest" = versions."${latestVersion versions "86.0"}";
       esr."latest" = versions.esr."${latestVersion versions.esr "115.1.0esr"}";
     }
