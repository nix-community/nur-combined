{
  lib,
  sources,
  python3Packages,
  ...
}:
with python3Packages;
buildPythonPackage {
  inherit (sources.undetected-chromedriver) pname version src;

  buildInputs = [
    selenium
    requests
    websockets
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
