{ lib
, stdenv
, fetchFromGitHub
, glslang
, meson
, ninja
, pkg-config
, libX11
, vkBasalt32 ? null
}:

stdenv.mkDerivation rec {
  pname = "vkBasalt";
  version = "0.3.2.2";

  src = fetchFromGitHub {
    owner = "DadSchoorse";
    repo = pname;
    rev = "v${version}";
    sha256 = "0xh6y831lf2rfwbpq82nh8ra9a745xrqrp7qd7hczw2pgwaqh44v";
  };

  # Patch library_path to use absolute paths to libvkbasalt.so
  # and patch name to be unique per platform for multilib support
  postPatch = ''
    substituteInPlace config/vkBasalt.json \
      --replace libvkbasalt.so "$out/lib/libvkbasalt.so" \
      --replace VK_LAYER_VKBASALT_post_processing \
                VK_LAYER_VKBASALT_post_processing_${stdenv.hostPlatform.system}
  '';

  nativeBuildInputs = [ glslang meson ninja pkg-config ];
  buildInputs = [ libX11 ];

  # Link 32bit manifest to 64bit package to support both 32bit & 64bit Vulkan applications
  postInstall = lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux") ''
    ln -s ${vkBasalt32}/share/vulkan/implicit_layer.d/vkBasalt.json \
      "$out/share/vulkan/implicit_layer.d/vkBasalt32.json"
  '';

  meta = with lib; {
    description = "A Vulkan post processing layer for Linux";
    homepage = "https://github.com/DadSchoorse/vkBasalt";
    license = licenses.zlib;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
