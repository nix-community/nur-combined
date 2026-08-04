{ fetchFromGitHub
, lib
, makeWrapper
, stdenv
, unstableGitUpdater

  # Dependencies
, jre
, python3
}:

let
  inherit (lib) licenses;
in
stdenv.mkDerivation {
  pname = "decompiler-mc";
  version = "0.9-unstable-2026-01-17";
  meta = {
    description = "Automated decompilation of Minecraft";
    homepage = "https://github.com/hube12/DecompilerMC";
    license = with licenses; [
      asl20 # Fernflower (vendored)
      bsd3 # SpecialSource (vendored)
      mit # DecompilerMC, CFR (vendored)
    ];
    mainProgram = "decompiler-mc";
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "hube12";
    repo = "DecompilerMC";
    rev = "edbea9e62df4f1358624a8906d7279e61719bdc7";
    hash = "sha256-HuUujoDD57JC2CHDBwlkOPoxCUnyJpguW3edGy/t5cg=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  postInstall = ''
    mkdir --parents "$out"
    cp --recursive "$src/lib" "$out/lib"

    install -D 'main.py' "$out/bin/decompiler-mc"
    substituteInPlace "$out/bin/decompiler-mc" \
      --replace-fail 'PATH_TO_ROOT_DIR / "lib"' "Path(\"$out/lib\")" \
      --replace-fail 'PATH_TO_ROOT_DIR = Path(os.path.dirname(sys.argv[0]))' 'PATH_TO_ROOT_DIR = Path.cwd()'
    wrapProgram "$out/bin/decompiler-mc" \
      --prefix PATH : ${lib.makeBinPath [ jre ]}
  '';
}
