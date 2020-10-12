{ lib
, stdenv
, fetchurl
, unshield
, unzip
}:

let
  pname = "genius-sf-600-firmware";
  version = "5.3.1";
  sha256 = "1ypgzhngwd2rg1wasbl9h89d04j7way0x7d2c52ilwwdh5rwkgvb";
  firmwareSHA256SUM = "9730a258dc7152184a9c4fb7c8d12abb3b4de537276f4686525beb6a72f98c15";
in

stdenv.mkDerivation {
  inherit pname;
  inherit version;

  src = fetchurl {
    url = "http://download.geniusnet.com/2012/Scanner/CP-SF600_Win8_V${version}.zip";
    inherit sha256;
  };

  buildInputs = [ unshield unzip];

  unpackPhase = ''
  unzip $src
  unshield -d . -g DRV_U_GT6816 x data1.cab
  '';

  checkPhase = ''
    sha256sum -c <<EOF
    ${firmwareSHA256SUM}  DRV_U_GT6816/cism216.fw
EOF'';

  doCheck = true;

  preferLocalBuild = true;

  installPhase = ''
    mkdir -p $out
    cp DRV_U_GT6816/cism216.fw $out/cism216.fw
  '';

  meta = with lib; {
    homepage = "http://download.geniusnet.com";
    description = "firmware blob for Genius SF-600 scanner";
    license = [ licenses.unfree ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux;
  };
}
