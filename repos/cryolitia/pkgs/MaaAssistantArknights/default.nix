# imitate https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=maa-assistant-arknights

{ maintainers
, stdenv
, lib
, fetchFromGitHub
, cmake
, opencv
, onnxruntime
, eigen
, zlib
, asio
, libcpr
, python3
, android-tools
, rustPlatform
, makeWrapper
, }:

let

  maaVersion = "4.23.3";

  fastdeploy = stdenv.mkDerivation rec {

    pname = "fastdeploy";
    version = "1.0.0";

    src = fetchFromGitHub ({
      owner = "MaaAssistantArknights";
      repo = "FastDeploy";
      rev = "070424e06436524d817131d68c411066fa6069a6";
      sha256 = "sha256-+W9StKABaX/3rHGD8jBCTLFw1kPoHFXjcn96wxXCuDY=";
    });

    nativeBuildInputs = [
      cmake
      eigen
    ];

    buildInputs = [
      opencv
      onnxruntime
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=None"
      "-DBUILD_SHARED_LIBS=ON"
    ];
  
  };

  maa-cli = rustPlatform.buildRustPackage rec {

    pname = "maa-cli";
    version = "0.3.9";

    src = fetchFromGitHub {
      owner = "MaaAssistantArknights";
      repo = "maa-cli";
      rev = "v${version}";
      sha256 = "sha256-2LsMGvGsJJmZ3EuiHAhr0NU2VKoNqGB6PhXCOHTWsqM=";
    };

    cargoSha256 = "sha256-hnFyUdSREqr0Qvzug1V59frVlxsWxrymh899jqCknew=";

  };

in stdenv.mkDerivation rec {

  pname = "MaaAssistantArknights";
  version = maaVersion;

  src = fetchFromGitHub ({
      owner = "MaaAssistantArknights";
      repo = "MaaAssistantArknights";
      rev = "v${version}";
      sha256 = "sha256-A41kk1Xg9c/QZHOhyakcBULzsNTrsfnGYZ0df+MKWfc=";
    });

  postPatch = ''
    sed -i 's/RUNTIME\sDESTINATION\s\./ /g; s/LIBRARY\sDESTINATION\s\./ /g; s/PUBLIC_HEADER\sDESTINATION\s\./ /g' CMakeLists.txt
    sed -i 's/find_package(asio /# find_package(asio /g' CMakeLists.txt
    sed -i 's/asio::asio/ /g' CMakeLists.txt

    find "src/MaaCore" \
        \( -name '*.h' -or -name '*.cpp' -or -name '*.hpp' -or -name '*.cc' \) \
        -exec sed -i 's/onnxruntime\/core\/session\///g' {} \;
  '';

  nativeBuildInputs = [
      cmake
      maa-cli
      makeWrapper
    ];

    buildInputs = [
      opencv
      onnxruntime
      fastdeploy
      zlib
      asio
      libcpr
      python3
      android-tools
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=None"
      "-DUSE_MAADEPS=OFF"
      "-DINSTALL_THIRD_LIBS=ON"
      "-DINSTALL_RESOURCE=ON"
      "-DINSTALL_PYTHON=ON"
      "-DMAA_VERSION=v${version}"
    ];

    postInstall = ''
      cd $out
      mkdir -p share/${pname}
      mv Python share/${pname}
      mv resource share/${pname}

      cd share/${pname}
      ln -s ../../lib/* .

      cd $out
      mkdir -p bin
      cp -v ${maa-cli}/bin/* ./share/${pname}
      makeWrapper $out/share/${pname}/maa $out/bin/maa
    '';

    meta = with lib; {
        description = "An Arknights assistant";
        homepage = "https://github.com/MaaAssistantArknights/MaaAssistantArknights";
        license = licenses.agpl3;
        platforms = platforms.linux;
        maintainers = with maintainers; [ Cryolitia ];
      };
  
}