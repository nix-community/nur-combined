{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
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
stdenv.mkDerivation (finalAttrs: {
  pname = "sam-toki-mouse-cursors";
  version = "10.00";
  src = fetchFromGitHub {
    owner = "SamToki";
    repo = "Sam-Toki-Mouse-Cursors";
    tag = "v10.00";
    hash = "sha256-juRUv7/9dd+bIDjbwzfznPyPUZpPyL9sYKcNgZXngro=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/SamToki/Sam-Toki-Mouse-Cursors/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Original mouse cursors (pointers) for Windows, with minimalistic design";
    homepage = "https://github.com/SamToki/Sam-Toki-Mouse-Cursors";
    license = lib.licenses.cc-by-nc-sa-30;
  };
})
