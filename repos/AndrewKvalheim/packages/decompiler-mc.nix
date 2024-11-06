{ fetchFromGitHub
, lib
, makeWrapper
, stdenv
, unstableGitUpdater

  # Dependencies
, jre
, python3
}:

stdenv.mkDerivation rec {
  pname = "decompiler-mc";
  version = "0.9-unstable-2024-11-02";

  src = fetchFromGitHub {
    owner = "hube12";
    repo = "DecompilerMC";
    rev = "747d6728b6df8e7db8c60a71ad8fcdc02955475c";
    hash = "sha256-kCznR79QvozvPbfWsWnvWdZV3aEBGutnQErWF0tGRho=";
  };

  buildInputs = [ makeWrapper python3 ];

  installPhase = ''
    mkdir --parents $out
    cp --recursive $src/lib $out/lib

    install -D main.py $out/bin/${pname}
    substituteInPlace $out/bin/${pname} \
      --replace-fail 'PATH_TO_ROOT_DIR / "lib"' "Path(\"$out/lib\")" \
      --replace-fail 'PATH_TO_ROOT_DIR = Path(os.path.dirname(sys.argv[0]))' 'PATH_TO_ROOT_DIR = Path.cwd()'
    wrapProgram $out/bin/${pname} --prefix PATH : ${lib.makeBinPath [ jre ]}
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Automated decompilation of Minecraft";
    homepage = "https://github.com/hube12/DecompilerMC";
    license = with lib.licenses; [
      asl20 # Fernflower (vendored)
      bsd3 # SpecialSource (vendored)
      mit # DecompilerMC, CFR (vendored)
    ];
    mainProgram = pname;
  };
}
