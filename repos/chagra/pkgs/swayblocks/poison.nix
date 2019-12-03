{ stdenv, beamPackages, fetchHex }:
  beamPackages.buildMix {
    name = "poison";
    version = "3.1.0";
    src = fetchHex {
      pkg = "poison";
      version = "3.1.0";
      sha256 = "1kng8xadrs03i77irxvdk9vfncrqzncmgxc5gc8y8gkknw76dj7y";
    };

  }
