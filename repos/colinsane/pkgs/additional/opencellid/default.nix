{ stdenv
, lib
, fetchurl
# database downloads are limited per API key, so please consider supplying your own API key if using this package
, apiKey ? "pk.758ba60a9bf5fc060451153c3e2542dc"
}:

stdenv.mkDerivation {
  pname = "opencellid";
  version = "0-unstable-2024-06-20";

  src = fetchurl {
    # this is a live url. updated daily? TODO: add an update script for this.
    # the API key should allow for at least 2 downloads per day
    url = "https://opencellid.org/ocid/downloads?token=${apiKey}&type=full&file=cell_towers.csv.gz";
    hash = "sha256-nXWdHp6kYSJP6jOq056Po9YrNj8vDNY+uxQaKA7iA2A=";
  };

  unpackPhase = ''
    gunzip "$src" --stdout > cell_towers.csv
  '';

  installPhase = ''
    cp cell_towers.csv $out
  '';

  meta = with lib; {
    description = "100M-ish csv database of known celltower positions";
    homepage = "https://opencellid.org";
    maintainers = with maintainers; [ colinsane ];
  };
}
