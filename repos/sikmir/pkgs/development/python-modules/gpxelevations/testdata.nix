{ fetchurl }:
let
  fetchSrtm = { file, sha256 }: fetchurl {
    inherit sha256;
    url = "https://dds.cr.usgs.gov/srtm/version2_1/SRTM3/${file}";
  };
in
[
  (fetchSrtm {
    file = "Eurasia/N47E013.hgt.zip";
    sha256 = "0b8r9z6ni6dzqjzrk848nwywk73079lzh39h676z23nf4f5303jl";
  })
  (fetchSrtm {
    file = "Eurasia/N46E013.hgt.zip";
    sha256 = "14ipvzki7n6bgls0kg33id1587pzjhfm05ddqpgcniy8sq8lkdgg";
  })
  (fetchSrtm {
    file = "Eurasia/N47E012.hgt.zip";
    sha256 = "0wk5sa9mxcjj9nkk29myxz4qayjrhp1xb1wkn7ij42kl0zz4568n";
  })
  (fetchSrtm {
    file = "Africa/N00E015.hgt.zip";
    sha256 = "1v29x62fw4rxl32rbgmc19fczagvv8dld31razq3rimdh8x6jgja";
  })
  (fetchSrtm {
    file = "Africa/S01E015.hgt.zip";
    sha256 = "0s54vmgd7dpy71cza2193m2615a3m4qh5rffza3g7myh5gz3kd4n";
  })
  (fetchSrtm {
    file = "Eurasia/N51E000.hgt.zip";
    sha256 = "09frqq1qlgchbz08r0lpx4fxd04s848c8v7bpmvwl43hyrjml347";
  })
  (fetchSrtm {
    file = "Eurasia/N51W001.hgt.zip";
    sha256 = "0p0kc9bghgik388ii86mabc8jdlmj567lpfbbjxpc6wqs1hmxjwp";
  })
  (fetchSrtm {
    file = "Eurasia/N42E071.hgt.zip";
    sha256 = "0qxpg4vb77wk056jp6qj03cmrwp0bbzf1nxihdwwxbmyhrxn2zrq";
  })
  (fetchSrtm {
    file = "Eurasia/N43E087.hgt.zip";
    sha256 = "0hbqjskgi4is4wa5frndlgaxi6cbmxrh0kfddwbcml18nyyfw4xh";
  })
  (fetchSrtm {
    file = "Africa/N31E035.hgt.zip";
    sha256 = "0g20fzrlwmxzas3mdxlk0kf4nygxq5xl616ana9n4dg35m4ivva8";
  })
  (fetchSrtm {
    file = "Eurasia/N55E055.hgt.zip";
    sha256 = "0nm4yhrjx4m396bp5nyj4nzv8gdgbj4cpddls2fx24bp880vv8r2";
  })
  (fetchSrtm {
    file = "Eurasia/N45E013.hgt.zip";
    sha256 = "1f802rw7z8s29jjbk0j4gkbyg9jgknrzbg2lalcbvq55hj1j95nb";
  })
  (fetchSrtm {
    file = "Africa/N24E035.hgt.zip";
    sha256 = "1fyrybdm67r17fj5hj2i3nwcpyf2m8v5y9jwlfys7f3qicw692qv";
  })
]
