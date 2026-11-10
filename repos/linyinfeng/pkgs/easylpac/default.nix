{
  lib,
  buildGoModule,
  go_1_27,
  cmake,
  cjson,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  gtk3,
  libXxf86vm,
  libglvnd,
  glfw,
  wrapGAppsHook3,
  fontconfig,
  pcsclite,
}:

buildGoModule.override { go = go_1_27; } rec {
  pname = "easylpac";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-2bJzbr99qrhY8Czvl0BxrCToK27t5PDwxSlMpgEDqbE=";
  };

  proxyVendor = true;
  vendorHash = "sha256-terM1t0NfTNCEE8BssP2vR2r8hNJ9gSRWEI/BPVeMBU=";

  subPackages = [ "cmd/easylpac" ];

  env.FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    cmake
  ];
  buildInputs = [
    gtk3
    libglvnd
    libXxf86vm
    cjson
    pcsclite
  ]
  ++ glfw.buildInputs;

  preBuild = ''
    platform="$(go env GOOS)-$(go env GOARCH)"
    build="third_party/libeuicc/$platform/cmake"

    cmake -S third_party/lpac -B "$build" \
      -DLPAC_BUILD_LIBEUICC_ONLY=ON \
      -DLPAC_DYNAMIC_LIBEUICC=OFF \
      -DUSE_SYSTEM_DEPS=ON \
      -DcJSON_DIR="${cjson}/lib/cmake/cJSON" \
      -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
      -DBUILD_TESTING=OFF \
      -DCMAKE_BUILD_TYPE=Release
    cmake --build "$build" --parallel

    mkdir -p "third_party/libeuicc/$platform"
    cp "$build/euicc/libeuicc.a" "third_party/libeuicc/$platform/"
    ar rcs "third_party/libeuicc/$platform/libcjsonext.a" \
      $(find "$build/cjson-ext" -name 'cJSON_ex.c.o')
  '';

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = {
    description = "lpac GUI Frontend";
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    mainProgram = "easylpac";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yinfeng ];
  };
}
