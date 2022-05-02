{ stdenv
, unity3d
, fetchFromGitHub
, xvfb-run
, lib
}:
# broken because of unity licensing workflow issue
stdenv.mkDerivation {
  name = "Geographical-Adventures";
  version = "unstable-2022-5-2";
  src = fetchFromGitHub {
    owner = "SebLague";
    repo = "Geographical-Adventures";
    sha256 = "sha256-DXziwS9KuJoSao/IQ70kGCFtjaWgtHPCwrcPdrMY5AE=";
    rev = "c611e3455a012b8838faa81e47351a7fcfa2e449";
  };
  buildInputs = [
    unity3d
    xvfb-run
  ];
  installPhase = ''
    # echo "576562626572264761624c65526f7578" > /etc/machine-id
    xvfb-run unity-editor -quit -batchmode -projectPath "$(pwd)" -executeMethod UnityBuilderAction.Builder.BuildProject -customBuildPath $out -buildTarget LinuxStandalone -logfile /dev/stdout
  '';
}
