{ fetchurl
, stdenv

, unzip

, name
, plugin
}:

stdenv.mkDerivation {
  pname = "qgis-plugin-${name}";
  version = plugin.version;

  src = fetchurl {
    url = plugin.url;
    hash = plugin.hash;
  };

  dontUnpack = true;

  nativeBuildInputs = [ unzip ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    unzip -d $out $src

    find . -name '*.pyc' -type f -delete

    runHook postInstall
  '';

  meta = {
    description = "QGIS plugin";
    homepage = "https://plugins.qgis.org/plugins";
  };
}

