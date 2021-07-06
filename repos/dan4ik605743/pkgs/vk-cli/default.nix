{ stdenv
, lib
, fetchurl
, curlFull
, zulip
, p7zip
, glibc
, ncurses
, openssl
}:

stdenv.mkDerivation rec
{
  pname = "vk-cli";
  version = "0.7.6";
  src = fetchurl {
    url = "https://github.com/vk-cli/vk/releases/download/${version}/vk-0.7.6-64-bin.7z";
    sha256 = "0z4x91f03qfqxgmfckn5r2gq4d42kjq2axcixpfpmfjx6wp2i3b3";
  };
  nativeBuildInputs = 
  [
    p7zip
  ];
  buildInputs = 
  [
    curlFull
    ncurses
    openssl
  ];
  unpackPhase = 
  ''
    mkdir -p $TMP/
    7z x $src -o$TMP/
  '';
  installPhase =
  ''
    mkdir -p $out/bin/
    mv $TMP/vk-0.7.6-64-bin vk
    install -D vk --target-directory=$out/bin/
  '';
  postFixup = let
    libPath = lib.makeLibraryPath
    [
      curlFull
      zulip
      glibc
    ];
  in ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/vk
     '';
  meta = with lib; {
    description = "A console (ncurses) client for vk.com written in D";
    homepage = "https://github.com/vk-cli/vk";
    license = licenses.mit;
    maintainers = with maintainers; [ dan4ik605743 ];
    platforms = platforms.linux;
  };
}
