{
  stdenv,
  lib,
  python3,
  chromedriver,
  undetected-chromedriver,
  ...
}:
let
  py = python3.withPackages (
    p: with p; [
      requests
      selenium
      websockets
      packaging
      undetected-chromedriver
    ]
  );
in
stdenv.mkDerivation {
  pname = "undetected-chromedriver-bin";
  inherit (chromedriver) version;

  dontUnpack = true;

  postPatch = ''
    export HOME=$(pwd)

    if [ -f "${chromedriver}/bin/.chromedriver-wrapped" ]; then
      cp "${chromedriver}/bin/.chromedriver-wrapped" chromedriver
    else
      cp "${chromedriver}/bin/chromedriver" chromedriver
    fi
    chmod 755 chromedriver

    ${py}/bin/python <<EOF
    import logging
    from undetected_chromedriver.patcher import Patcher
    logging.basicConfig(level=logging.DEBUG)
    exit(not Patcher(executable_path="chromedriver").patch())
    EOF

    # Make sure chromedriver is properly patched
    grep "undetected chromedriver" "chromedriver"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp chromedriver $out/bin/undetected_chromedriver
  '';

  meta = chromedriver.meta // {
    mainProgram = "undetected_chromedriver";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Chromedriver with undetected-chromedriver patch";
  };
}
