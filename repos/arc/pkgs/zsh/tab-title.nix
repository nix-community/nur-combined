{ fetchFromGitHub, buildZshPlugin, fetchpatch }: buildZshPlugin rec {
  pname = "zsh-tab-title";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "trystan2k";
    repo = pname;
    rev = "v${version}";
    sha256 = "137mfwx52cg97qy3xvvnp8j5jns6hi20r39agms54rrwqyr1918f";
  };

  patches = [ (fetchpatch {
    url = "https://github.com/trystan2k/zsh-tab-title/commit/8680956adc73bec7439db693c0a54b40630c3989.patch";
    sha256 = "035wiljxych4nydxkvffcb1czrxrvbw1g13qvwfafycqgdfv8zww";
  }) (fetchpatch {
    url = "https://github.com/trystan2k/zsh-tab-title/commit/6e532a48e46ae56daec18255512dd8d0597f4aa6.patch";
    sha256 = "132pmdhxnlalici6gv5sh6yrd8gxhwfrk8cbsxh768p58nainf05";
  }) ];
}
