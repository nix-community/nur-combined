{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "antidot";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "doron-cohen";
    repo = pname;
    rev = "v${version}";
    sha256 = "02dsc8l7iqkss1fx3sawmzggqk0k04664hfhrc6f0cv0jajkzknf";
  };

  vendorSha256 = "sha256-JHSp0vkqP9tCrV6jviJR9G7t0a/RGtLNK3O7z5RBFFk=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/doron-cohen/antidot";
    description = "Cleans up your $HOME from those pesky dotfiles";
    license = licenses.mit;
    platforms = platforms.all;
    # maintainers = with maintainers; [  ];
  };
}
