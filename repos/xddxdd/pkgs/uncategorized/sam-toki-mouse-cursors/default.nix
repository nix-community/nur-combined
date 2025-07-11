{
  stdenvNoCC,
  sources,
  lib,
  python3,
  win2xcur,
}:
let
  py = python3.withPackages (p: [
    p.requests
    win2xcur
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.sam-toki-mouse-cursors) pname version src;

  nativeBuildInputs = [ py ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons

    for INF in PROJECT/STMC/*.inf; do
      echo "$INF"
      mkdir tmp
      ${py}/bin/python3 ${../../../tools/windows_cursor_to_linux.py} \
        "$INF" tmp/
      CURSOR_NAME=$(grep -E "^Name=" tmp/cursor.theme | cut -d"=" -f2)
      mv tmp $out/share/icons/$CURSOR_NAME
    done

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/SamToki/Sam-Toki-Mouse-Cursors/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Original mouse cursors (pointers) for Windows, with minimalistic design";
    homepage = "https://github.com/SamToki/Sam-Toki-Mouse-Cursors";
    license = lib.licenses.cc-by-nc-sa-30;
  };
})
