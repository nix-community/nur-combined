{ stdenv, make-gog-package }:

make-gog-package {
  pname = "enter-the-gungeon";
  version = "2_0_12_23095";
  installername = "enter_the_gungeon_en";
  binname = "enter-the-gungeon";
  sha256 = "0v0lba8d1dfb7rd1wxhzgw3wkvkl549pslfjkja8w140w13a4psc";

  meta = with stdenv.lib; {
    description = "";
    homepage    = https://gog.com;
    license     = licenses.unfree;
    maintainers = with maintainers; [ fgaz ];
    broken = true; # Temporary, TODO exclude unfree from travis
    hydraPlatforms = [];
  };
}

