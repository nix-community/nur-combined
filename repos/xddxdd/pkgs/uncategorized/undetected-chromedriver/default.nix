{
  lib,
  sources,
  dos2unix,
  python3Packages,
  ...
}:
python3Packages.buildPythonPackage {
  inherit (sources.undetected-chromedriver) pname version src;

  patches = [ ./1766-use-packaging.patch ];

  prePatch = ''
    find . | xargs dos2unix
  '';

  nativeBuildInputs = [ dos2unix ];

  buildInputs = with python3Packages; [
    selenium
    requests
    websockets
    packaging
  ];

  preConfigure = ''
    sed -i "s#selenium>=4.9.0#selenium#g" setup.py
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Custom Selenium Chromedriver | Zero-Config | Passes ALL bot mitigation systems (like Distil / Imperva/ Datadadome / CloudFlare IUAM)";
    homepage = "https://github.com/ultrafunkamsterdam/undetected-chromedriver";
    license = with licenses; [ gpl3Only ];
  };
}
