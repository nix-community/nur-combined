{ lib, make-gog-package }:

make-gog-package {
  pname = "enter-the-gungeon";
  version = "2_1_9_33951";
  installername = "enter_the_gungeon";
  binname = "enter-the-gungeon";
  sha256 = "0z0693drj6aawzva021xaszgmvrhkd4p61zdn6myqgnsam5l3sr3";

  meta = with lib; {
    description = "";
    homepage    = https://gog.com;
    license     = licenses.unfree;
    maintainers = with maintainers; [ fgaz ];
    hydraPlatforms = [];
  };
}

