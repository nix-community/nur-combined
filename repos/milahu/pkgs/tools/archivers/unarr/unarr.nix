{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "unarr";
  #version = "1.0.1"; # Broken paths found in a .pc file
  #version = "1.1.0.beta1"; # Broken paths found in a .pc file
  version = "1.1.0-unstable-2022-10-08";

  src = fetchFromGitHub {
    owner = "selmf";
    repo = "unarr";
    #rev = "v${version}";
    #hash = "sha256-H9Y6cgVZxU4EcY/6USqtUdlAyM9fvJfeKIkFYLjyJJk="; # 1.0.1
    #hash = "sha256-ic+K//sTSiAzUv1saTbJK2FQe65/GAw4w4QxW9OQ0lk="; # 1.1.0.beta1
    # https://github.com/selmf/unarr/issues/26 # add new release to fix includedir and libdir in libunarr.pc
    # fix: Broken paths found in a .pc file
    # /nix/store/1mphn2l0mb2bcrxn90mkmkg1kpl2nyb8-unarr-1.0.1/lib/pkgconfig/libunarr.pc
    # The following lines have issues (specifically '//' in paths).
    # 2:includedir=${prefix}//nix/store/1mphn2l0mb2bcrxn90mkmkg1kpl2nyb8-unarr-1.0.1/include
    # 3:libdir=${prefix}//nix/store/1mphn2l0mb2bcrxn90mkmkg1kpl2nyb8-unarr-1.0.1/lib
    rev = "569ffdb063ce8a76ab069444af175e5953d90c93";
    hash = "sha256-O6P+3NA2dFg8G5hCyQvk0FUP7boPP0P0I/ukRWmWfu8=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "A decompression library for rar, tar, zip and 7z archives";
    homepage = "https://github.com/selmf/unarr";
    changelog = "https://github.com/selmf/unarr/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}
