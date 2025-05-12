{
  stdenv,
  lib,
  fetchFromGitLab,
  fetchurl,
  fixDarwinDylibNames,
  kdePackages,
}:

stdenv.mkDerivation (finalAttr: {
  pname = "qcustomplot";
  version = "2.1.1";

  srcs = [
    (fetchFromGitLab {
      owner = "ecme2";
      repo = "QCustomPlot";
      tag = "v${finalAttr.version}";
      hash = "sha256-BW8H/vDbhK3b8t8oB92icEBemzcdRdrIz2aKqlUi6UU=";
    })
    (fetchurl {
      url = "https://www.qcustomplot.com/release/${finalAttr.version}/QCustomPlot-source.tar.gz";
      hash = "sha256-Xi0i3sd5248B81fL2yXlT7z5ca2u516ujXrSRESHGC8=";
    })
  ];

  sourceRoot = ".";

  buildInputs = [ kdePackages.qtbase ];

  nativeBuildInputs =
    [
      kdePackages.qmake
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      fixDarwinDylibNames
    ];

  env.LANG = "C.UTF-8";

  qmakeFlags = [ "sharedlib/sharedlib-compilation/sharedlib-compilation.pro" ];

  dontWrapQtApps = true;

  postUnpack = ''
    cp -rv source/* .
    cp -rv qcustomplot-source/* .
  '';

  installPhase = ''
    runHook preInstall

    install -vDm 644 "qcustomplot.h" -t "$out/include/"
    install -vdm 755 "$out/lib/"
    cp -av libqcustomplot*${stdenv.hostPlatform.extensions.sharedLibrary}* "$out/lib/"

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://qtcustomplot.com/";
    description = "A Qt C++ widget for plotting and data visualization";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ Cryolitia ];
  };
})
