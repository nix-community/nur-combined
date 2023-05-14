{ lib
, stdenv
, fetchFromGitea
, cmake
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "libkysdk-base";
  version = "2.0.2.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "wine";
    repo = pname;
    rev = "ef084e549c1f2be0ce244c7ae707065360eb55eb";
    sha256 = "sha256-SRcZJ+ogR58joSQURztcL+HD8Krhlczv/4KeHTksEuk=";
  };

  postPatch = ''
    substituteInPlace src/log/CMakeLists.txt \
      --replace "/etc" "$out/etc"

    for file in $(grep -rl "/usr")
    do
      substituteInPlace $file \
        --replace "/usr" "$out"
    done
  '';

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
  ];

  meta = with lib; {
    description = "libkysdk-base";
    homepage = "https://gitee.com/openkylin/libkysdk-base";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}

