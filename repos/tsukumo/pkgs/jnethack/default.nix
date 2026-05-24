{
  nethack,
  fetchurl,
  nkf,
  lib,
  maintainers,
}:

nethack.overrideAttrs (oldAttrs: {
  pname = "jnethack";
  # NixpkgsのNetHackもなんか3.6.7なので耐えてる
  patches = [
    (fetchurl {
      url = "https://ftp.jaist.ac.jp/pub/sourceforge.jp/jnethack/78334/jnethack-3.6.7-0.1.diff.gz";
      hash = "sha256-0Uom1uBnpi6dQx1ZGiv83t7ttCzts2CQkX5wSbATZ50=";
    })
  ];

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ nkf ];

  # https://github.com/NixOS/nixpkgs/blob/3f879eca34191600e57e24e8cbd95cc2a25fa87e/pkgs/by-name/ne/nethack/function-parameters.patch
  postPatch = (oldAttrs.postPatch or "") + ''
    find ./ -type f -exec nkf --overwrite -e -Lu {} +

    substituteInPlace include/system.h \
      --replace "void (*)()" "void (*)(int)" \
      --replace "int (*)()" "int (*)(int)" \
      --replace "E void srand48();" "E void srand48(long);" \
      --replace "E void sleep();" "E void sleep(unsigned);" \
      --replace "E unsigned sleep();" "unsigned sleep(unsigned);" \

    substituteInPlace include/winX.h \
      --replace "E void (*input_func)();" "E void (*input_func)(Widget, XEvent *, String *, Cardinal *);"

    substituteInPlace include/xwindow.h \
      --replace "extern XFontStruct *WindowFontStruct;" "struct Widget;\nextern XFontStruct *WindowFontStruct(struct Widget *);" \
      --replace "extern Font WindowFont;" "extern Font WindowFont(struct Widget *);"
  '';
  postInstall = lib.replaceStrings [ "nethack" ] [ "jnethack" ] oldAttrs.postInstall;

  meta = with lib; {
    description = "Japanese localization on NetHack";
    homepage = "https://jnethack.github.io/";
    license = licenses.ngpl;
    maintainers = [ maintainers.thukumo ];
    platforms = platforms.unix;
  };
})
