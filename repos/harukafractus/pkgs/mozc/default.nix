{ lib
, buildBazelPackage
, fetchFromGitHub
, qt6
, pkg-config
, bazel
, ibus
, unzip
, xdg-utils
}:

buildBazelPackage rec {
  pname = "ibus-mozc";
  version = "2.29.5268.102";

  src = fetchFromGitHub {
    owner = "google";
    repo = "mozc";
    rev = version;
    hash = "sha256-B7hG8OUaQ1jmmcOPApJlPVcB8h1Rw06W5LAzlTzI9rU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ qt6.wrapQtAppsHook pkg-config unzip ];

  buildInputs = [ ibus qt6.qtbase ];

  dontAddBazelOpts = true;
  removeRulesCC = false;

  inherit bazel;

  fetchAttrs = {
    sha256 = "sha256-17QHh1MJUu8OK/T+WSpLXEx83DmRORLN7yLzILqP7vw=";

    # remove references of buildInputs
    preInstall = ''
      rm -rv $bazelOut/external/{ibus,qt_linux}
    '';
  };

  bazelFlags = [ "--config" "oss_linux" "--compilation_mode" "opt" ];

  bazelTargets = [ "package" ];

  postPatch = ''
    substituteInPlace src/config.bzl \
      --replace "/usr/bin/xdg-open" "${xdg-utils}/bin/xdg-open" \
      --replace "/usr" "$out"
  '';

  preConfigure = ''
    cd src
  '';

  buildAttrs.installPhase = ''
    runHook preInstall

    unzip bazel-bin/unix/mozc.zip -x "tmp/*" -d /

    runHook postInstall
  '';


  meta = with lib; {
    isIbusEngine = true;
    description = "Japanese input method from Google";
    homepage = "https://github.com/google/mozc";
    license = licenses.free;
    platforms = platforms.linux;
    #maintainers = with maintainers; [ gebner ericsagnes pineapplehunter ];
  };
}