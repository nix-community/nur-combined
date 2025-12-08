# earlier attempt to upstream: <https://github.com/NixOS/nixpkgs/pull/211874>
{
  bash,
  fetchFromGitHub,
  fpm,
  jq,
  lib,
  pandoc,
  shunit2,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "splatmoji";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "cspeterson";
    repo = "splatmoji";
    rev = "v${version}";
    hash = "sha256-fsZ8FhLP3vAalRJWUEi/0fe0DlwAz5zZeRZqAuwgv/U=";
  };

  nativeBuildInputs = [
    bash
    fpm
    jq
    pandoc
    shunit2
  ];

  postPatch = ''
    patchShebangs ./build.sh
    patchShebangs ./test/unit_tests
  '';

  buildPhase = ''
    runHook preBuild
    ./build.sh ${version} dir
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R build/usr/* $out

    patchShebangs $out/bin/splatmoji
    # splatmoji refers to its lib and data by absolute path
    sed -i "s:/usr/lib/splatmoji:$out/lib/splatmoji:g" $out/bin/splatmoji
    sed -i -r "s:/usr/share/+splatmoji:$out/share/splatmoji:g" $out/lib/splatmoji/functions
    runHook postInstall
  '';

  meta = with lib; {
    description = "Quickly look up and input emoji and/or emoticons/kaomoji on your GNU/Linux desktop via pop-up menu";
    homepage = "https://github.com/cspeterson/splatmoji";
    license = licenses.mit;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}
