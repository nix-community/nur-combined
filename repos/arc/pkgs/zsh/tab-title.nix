{ fetchFromGitHub, buildZshPlugin }: buildZshPlugin rec {
  pname = "zsh-tab-title";
  pluginName = "title";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "trystan2k";
    repo = pname;
    rev = "v${version}";
    sha256 = "0wpin0lv419zqijx5vjckk785gm2sqn36qyncwvsryi6n5qi7vij";
  };
}
