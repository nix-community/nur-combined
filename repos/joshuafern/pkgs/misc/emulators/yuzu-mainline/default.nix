{ stdenv, mkDerivation, lib, fetchgit
, cmake, libressl, SDL2, qtbase, python2
, useVulkan ? true, vulkan-loader, vulkan-headers 
}:

mkDerivation rec {
  pname = "yuzu-mainline";
  version = "unstable-2020-04-13";

  # Submodules
  src = fetchgit {
    url = "https://github.com/yuzu-emu/${pname}";
    rev = "20c42dc9ea8bdc208d9d274350af2ff347876c76";
    sha256 = "0s9p5di9kcr8sh6iipv21b74c4dhn37an4khy4y7b9s9y8p1haim";
  };

  nativeBuildInputs = [ cmake libressl ];
  buildInputs = [ SDL2 qtbase python2 ]
  ++ stdenv.lib.optionals useVulkan [ vulkan-loader vulkan-headers ];

  preConfigure = ''
    # Trick configure system
    sed -n 's,^ *path = \(.*\),\1,p' .gitmodules | while read path; do
      mkdir "$path/.git"
    done
  '';

  postFixup = stdenv.lib.optionals useVulkan ''
    # Fix vulkan detection
    wrapProgram $out/bin/yuzu --prefix LD_LIBRARY_PATH : ${vulkan-loader}/lib
  '';

  meta = with stdenv.lib; {
    homepage = "https://yuzu-emu.org";
    description = "An experimental Nintendo Switch emulator";
    license = with licenses; [ gpl2 cc-by-nd-30 cc0 ];
    maintainers = with maintainers; [ joshuafern ];
    platforms = platforms.linux;
  };
}
