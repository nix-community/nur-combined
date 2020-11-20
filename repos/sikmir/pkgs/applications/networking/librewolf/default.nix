{ stdenv, fetchgit, fetchurl, appimageTools, undmg, lang ? "en-US" }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "librewolf";
  version = "82.0.3";
  name = "${pname}-${version}";

  firefox = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/${lang}/Firefox%20${version}.dmg";
    sha256 = {
      en-US = "10srb6pjy729zl71gsammp294kg531m3fgghd8lrw05pbm9lxxy1";
      eo = "0fqvqkv6sa7gz42c9gddv3axy61acdjzwrmdn8xbpzidr18lg66x";
      fi = "06500lkijcsfhvqji64705mii621hva676zvhln9hyq51dys4hyl";
      ru = "1ibv4kdjqhl0a056dgnr470dl7n4wfpq9m06caapyx59vfq182zh";
    }.${lang};
    name = "Firefox.dmg";
  };

  librewolf = fetchurl {
    url = {
      x86_64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/40d177f7132a991fd7249219f3f442d0/LibreWolf-${version}-1.x86_64.AppImage";
      aarch64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/c3fdaa5529f412d8f867e5b1393e26ba/LibreWolf-${version}-1.aarch64.AppImage";
    }.${system} or throwSystem;
    sha256 = {
      x86_64-linux = "1nwc90bs0v5wkkviaw056nm8zyiryi2f41zvwhp5b2c50a8zvsk4";
      aarch64-linux = "0jrdwplw4r0mqr6ddr9lzgxlfk8m7krl9fimzv184wjhjkgbxxnk";
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
      cp -R LibreWolf.app $out/Applications
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
