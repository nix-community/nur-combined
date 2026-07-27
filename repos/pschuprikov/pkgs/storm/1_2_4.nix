{ stdenv, lib, fetchurl, zip, unzip, gawk
, jdk, python
, confFile ? ""
, extraLibraryPaths ? []
, extraJars ? []
}:

stdenv.mkDerivation rec {
  pname = "apache-storm";
  version = "1.2.4";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://apache/storm/${name}/${name}.tar.gz";
    sha256 = "sha256-9XVkK/oCIvBHWbi8Otr4V9AwUAW/hdTsdUmI5THyxiI=";
  };

  nativeBuildInputs = [ zip unzip ];

  installPhase = ''
    mkdir -p $out/share/${name}
    mv public $out/public
    mv examples $out/share/${name}/.

    mv external extlib* lib $out/.
    mv conf bin $out/.
    mv log4j2 $out/conf/.
  '';

  fixupPhase = ''
    # Fix python reference
    sed -i \
      -e '19iPYTHON=${python}/bin/python' \
      -e 's|#!/usr/bin/.*python|#!${python}/bin/python|' \
      $out/bin/storm
    sed -i \
      -e 's|#!/usr/bin/.*python|#!${python}/bin/python|' \
      -e "s|STORM_CONF_DIR = .*|STORM_CONF_DIR = os.getenv('STORM_CONF_DIR','$out/conf')|" \
      -e 's|STORM_LOG4J2_CONF_DIR =.*|STORM_LOG4J2_CONF_DIR = os.path.join(STORM_CONF_DIR, "log4j2")|' \
        $out/bin/storm.py

    # Default jdk location
    sed -i -Ee 's|#?.*export JAVA_HOME=.*|export JAVA_HOME="${jdk.home}"|' \
           $out/conf/storm-env.sh

    # Link to extra jars
    cd $out/lib;
    ${lib.concatMapStrings (jar: "ln -s ${jar};\n") extraJars}

    # Fix scripts
    patchShebangs $out/bin
    substituteInPlace $out/bin/storm \
      --replace awk ${gawk}/bin/gawk
  '';

  dontStrip = true;

  meta = with lib; {
    homepage = "https://storm.apache.org/";
    description = "Distributed realtime computation system";
    license = licenses.asl20;
    maintainers = with maintainers; [ edwtjo vizanto ];
    platforms = with platforms; unix;
  };
}
