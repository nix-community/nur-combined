{
  lib,
  python3Packages,
  fetchFromGitHub,
  maintainers,
  ...
}:
let
  pname = "cc-decoder";
  version = "0-unstable-2026-05-22";

  rev = "6d52acb9164295d7fb776ffb490bdf873c59f788";
  hash = "sha256-tF27Dn+W5SiE6+Yz4v1bK9+AFuwsivqAo0rUAH5h35Q=";
in
python3Packages.buildPythonPackage {
  inherit pname version;

  pyproject = false;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "eshaz";
    repo = "cc_decoder";
  };

  propagatedBuildInputs = [
    python3Packages.setproctitle
    python3Packages.numpy
    python3Packages.matplotlib
  ];

  postPatch = ''
    substituteInPlace cc_decoder.py \
      --replace-fail "import lib.cc_decode" "import cc_decode"

    substituteInPlace cc_decoder.py \
      --replace-fail "from lib.cc_decode import" "from cc_decode import"
  '';

  installPhase = ''
    install -m755 -D "lib/cc_decode.py" "$out/${python3Packages.python.sitePackages}/cc_decode/__init__.py"
    install -m755 -D "cc_decoder.py" "$out/bin/cc_decoder.py"
  '';

  meta = {
    inherit maintainers;
    description = "Closed Caption Decoding for video files with visible closed caption data.";
    homepage = "https://github.com/eshaz/cc_decoder";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "cc_decoder.py";
  };
}
