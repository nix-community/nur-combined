{ stdenv, fetchFromGitHub
, glslang, meson, ninja, pkg-config
, libX11
}:

stdenv.mkDerivation rec {
  pname = "vkbasalt";
  version = "0.3.2.1";

  src = fetchFromGitHub {
    owner = "DadSchoorse";
    repo = pname;
    rev = "v${version}";
    sha256 = "0kpvgcfa5zkg1wbwhbgl16awfrh4x6za9b0rmlki8bn81f0ryvja";
  };

  # Currently doesn't support 32bit Vulkan games on 64bit systems
  # See https://github.com/KhronosGroup/Vulkan-Loader/issues/155
  postPatch = ''
    substituteInPlace config/vkBasalt.json \
      --replace libvkbasalt.so "$out/lib/libvkbasalt.so"
  '';

  nativeBuildInputs = [ glslang meson ninja pkg-config ];
  buildInputs = [ libX11 ];

  meta = with stdenv.lib; {
    description = "A Vulkan post processing layer for Linux";
    homepage = "https://github.com/DadSchoorse/vkBasalt";
    license = licenses.zlib;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
