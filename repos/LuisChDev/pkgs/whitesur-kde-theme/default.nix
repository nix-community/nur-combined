{ lib
, stdenv
, fetchFromGitHub
}:

let
  LuisChDev = {
    name = "Luis Chavarriaga";
    email = "luischa123@gmail.com";
    github = "LuisChDev";
    githubId = 24978009;
  };

in stdenv.mkDerivation rec {
  pname = "whitesur-kde";
  version = "latest";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = "1a001bdd61f4d199ddf7c7338fbb8ae9bf28dc58";
    sha256 = "10kwqjyv5srgmdpjc7krxndlm44p7azm8lykyxg37fzsiv32siyq";
  };

  postPatch = ''
    find -name "*.sh" -print0 | while IFS= read -r -d ''' file; do
      patchShebangs "$file"
    done

    # run as if with admin privileges
    substituteInPlace install.sh --replace '[ "$UID" -eq "$ROOT_UID" ]' '[ true ]'
    substituteInPlace install.sh --replace '/usr' '$out'
    substituteInPlace sddm/install.sh --replace '[ "$UID" -eq "$ROOT_UID" ]' '[ true ]'
    substituteInPlace sddm/install.sh --replace '/usr' '$out'

    # for some reason, there are some absolute paths referring to the icons that need to be patched
    substituteInPlace sddm/WhiteSur/Main.qml --replace "/usr/" "$out/"

    # Provides a dummy home directory
    substituteInPlace install.sh --replace '$HOME' '/tmp'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    name=WhiteSur ./install.sh
    mkdir -p $out/share/sddm/themes
    ./sddm/install.sh
    runHook postInstall
  '';

  meta = with lib; {
    description = "MacOS Big Sur like theme for Plasma desktops";
    homepage = "https://github.com/vinceliuice/WhiteSur-kde";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ LuisChDev ];
  };
}
