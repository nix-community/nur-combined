{ lib }:
# To update run:
# nix-prefetch-url --name 'firefox-app-<version>.dmg' 'https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US'
let versions = builtins.mapAttrs (n: v: v // { "version" = n; }) {
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
    };
    latestVersion = lib.lists.foldr (v: lV:
                                      if builtins.compareVersions v lV == 1
                                      then v
                                      else lV
                                    )
                                    "86.0"
                                    (builtins.attrNames versions);
in versions // { "latest" = versions."${latestVersion}"; }
