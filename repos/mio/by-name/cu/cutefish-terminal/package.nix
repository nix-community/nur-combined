{
  lib,
  mkCutefishDerivation,
  cutefish-toolkit,
  icu,
  pcre2,
  libxkbcommon,
}:

mkCutefishDerivation {
  pname = "cutefish-terminal";

  postPatch = ''
    substituteInPlace cutefish-terminal.desktop \
      --replace-fail 'Exec=/usr/bin/cutefish-terminal' 'Exec=cutefish-terminal'
  '';

  extraBuildInputs = [
    cutefish-toolkit
    icu
    pcre2
    libxkbcommon
  ];

  meta = {
    description = "Terminal emulator for the Cutefish desktop";
    license = with lib.licenses; [
      gpl3Plus
      gpl2Plus
      bsd3
    ];
    mainProgram = "cutefish-terminal";
  };
}
