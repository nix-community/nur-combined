{ stdenv, mkDerivation, fetchFromGitHub
, cmake, pkgconfig, SDL2, qtbase, python2, alsaLib, libpulseaudio, libjack2, sndio
, boost171, fmt, lz4, zstd, libopus, openssl, libzip, rapidjson, unicorn-emu
, catch2, nlohmann_json
, useVulkan ? true, vulkan-loader, vulkan-headers
}:

let
  # They use this fork and commit of unicorn as an submodule, upstream does not work as it's missing some instructions.
  unicorn = (unicorn-emu.overrideAttrs (attrs: {
    src = fetchFromGitHub {
      owner = "yuzu-emu";
      repo = "unicorn";
      rev = "73f45735354396766a4bfb26d0b96b06e5cf31b2";
      sha256 = "06gjv9civg5pqar246v3yak20i3kyzsjcznq5l3z6kngljx1fqh4";
    };
  }));
  # Have to do this till https://github.com/NixOS/nixpkgs/pull/88723 is merged.
  patchedFmt = (fmt.overrideAttrs (attrs: {
    postInstall = ''
      substituteInPlace $out/lib/cmake/fmt/fmt-targets.cmake \
        --replace "\''${_IMPORT_PREFIX}/include" "$dev/include"
    '';
  }));
in
mkDerivation rec {
  pname = "yuzu";
  version = "266";

  src = fetchFromGitHub {
    owner = "yuzu-emu";
    repo = "yuzu-mainline"; # They use a separate repo for mainline “branch”
    fetchSubmodules = true;
    rev = "mainline-0-${version}";
    sha256 = "1c43ggxh38wib0l7m4fi71jx18nw6b9hamfsmj92b5n3gd6i8lgv";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ catch2 nlohmann_json unicorn SDL2 qtbase python2 alsaLib libpulseaudio libjack2 sndio boost171 patchedFmt lz4 zstd libopus openssl libzip rapidjson ]
  ++ stdenv.lib.optionals useVulkan [ vulkan-loader vulkan-headers ];
  cmakeFlags = [ "-DYUZU_USE_BUNDLED_UNICORN=OFF" "-DUSE_DISCORD_PRESENCE=ON" ]
  ++ stdenv.lib.optionals (!useVulkan) [ "-DENABLE_VULKAN=No" ];

  # Trick the configure system
  preConfigure = ''
    sed -n 's,^ *path = \(.*\),\1,p' .gitmodules | while read path; do
      mkdir "$path/.git"
    done
  '';

  # Fix vulkan detection
  postFixup = stdenv.lib.optionals useVulkan ''
    wrapProgram $out/bin/yuzu --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
    wrapProgram $out/bin/yuzu-cmd --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
  '';

  meta = with stdenv.lib; {
    homepage = "https://yuzu-emu.org";
    description = "An experimental Nintendo Switch emulator";
    license = with licenses; [ 
      gpl2Plus
      # Icons
      cc-by-nd-30 cc0 
    ];
    maintainers = with maintainers; [ ivar joshuafern ];
    platforms = platforms.linux;
  };
}
