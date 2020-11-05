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
  version = "0.3.2.3";

  src = fetchFromGitHub {
    owner = "DadSchoorse";
    repo = pname;
    rev = "v${version}";
    sha256 = "1jm7z3dm5m7i50yifyx418l8g50hmczdy43zc68kig41vnrxlqgn";
  };

  nativeBuildInputs = [ glslang meson ninja pkg-config ];
  buildInputs = [ libX11 ];
  mesonFlags = [ "-Dappend_libdir_vkbasalt=true" ];

  # TODO: Link 32bit library to 64bit package to support 32bit Vulkan applications
  # Depends on https://github.com/NixOS/nixpkgs/issues/101597
  # postInstall = lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux") ''
  #   mkdir -p "$out/lib32/vkbasalt"
  #   ln -s ${vkBasalt32}/lib/vkbasalt/libvkbasalt.so "$out/lib32/vkbasalt"
  # '';

  meta = with lib; {
    description = "A Vulkan post processing layer for Linux";
    homepage = "https://github.com/DadSchoorse/vkBasalt";
    license = licenses.zlib;
    maintainers = with maintainers; [ metadark ];
    platforms = platforms.linux;
  };
}
