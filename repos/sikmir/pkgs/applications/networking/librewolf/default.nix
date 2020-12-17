{ stdenv, fetchgit, fetchurl, appimageTools, undmg, lang ? "en-US" }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "librewolf";
  version = "83.0";
  name = "${pname}-${version}";

  firefox = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/${lang}/Firefox%20${version}.dmg";
    sha256 = {
      en-US = "1ikfcdsz0pgaiwal47fnbybam513p5a1fn99g74wcf80wj27hlky";
      eo = "0vj93igq98rdib5fv6l362mn8mqknq2nsacaki4wxg4r7z0yji0r";
      fi = "0gi96mylj3wh3kyhw8mhdlzai64cr8g9g36jxi6ydca9aj134vwm";
      ru = "0qjhdxwiwn9hqz5fsw2x6yw2qbh0054fkbsk915gwqamlfi1x31j";
    }.${lang};
    name = "Firefox.dmg";
  };

  librewolf = fetchurl {
    url = {
      x86_64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/91420360aa0b7a059bd855e20d1b8a8a/LibreWolf-${version}-1.x86_64.AppImage";
      aarch64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/c24cfeea0298499fa755536fadb27ab5/LibreWolf-${version}-1.aarch64.AppImage";
    }.${system} or throwSystem;
    sha256 = {
      x86_64-linux = "1alrplhj4yx4svl8rnkyw844aybicx1zyp5aap32rvmmg0blga1n";
      aarch64-linux = "0s7x4xm7iv9d2k018m0azk2s2gk5w2n7xg6bqba4qg2pdnx39hyp";
    }.${system} or throwSystem;
  };

  meta = with stdenv.lib; {
    description = "A fork of Firefox, focused on privacy, security and freedom";
    homepage = "https://librewolf-community.gitlab.io/";
    license = licenses.mpl20;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
    skip.ci = true;
  };

  appimageContents = appimageTools.extract {
    inherit name;
    src = librewolf;
  };

  linux = appimageTools.wrapType2 rec {
    inherit name meta;
    src = librewolf;

    extraInstallCommands = ''
      mv $out/bin/{${name},${pname}}
      install -Dm644 ${appimageContents}/io.gitlab.LibreWolf.desktop -t $out/share/applications
      install -Dm644 ${appimageContents}/librewolf.png -t $out/share/icons/hicolor/256x256/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version meta;

    src = fetchgit {
      url = "https://gitlab.com/librewolf-community/browser/macos";
      rev = "3fcf44663ff1fb4e180fb3cdb26620abe7284b53";
      sha256 = "0p517ixkgp3sl7b26mdjr9mwv6155xx8ah85fgpwqnpryr64xs3d";
    };

    postPatch = ''
      substituteInPlace package.sh \
        --replace "codesign" "/usr/bin/codesign" \
        --replace "cp" "/bin/cp" \
        --replace "hdiutil" "/usr/bin/hdiutil" \
        --replace "out_dir=" "out_dir=. #"
    '';

    buildPhase = ''
      # Use fresh FF dmgs for each build.
      cp ${firefox} Firefox.dmg
      ./package.sh Firefox.dmg
    '';

    installPhase = ''
      ${undmg}/bin/undmg LibreWolf.dmg
      mkdir -p $out/Applications
      cp -r LibreWolf.app $out/Applications
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
