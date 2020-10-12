{ stdenv, fetchgit, fetchurl, appimageTools, lang ? "en-US" }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "librewolf";
  version = if stdenv.isDarwin then "81.0.1" else "81.0";
  name = "${pname}-${version}";

  firefox = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/${lang}/Firefox%20${version}.dmg";
    sha256 = {
      en-US = "0a54913nsclfzswsxmwglwrwzsv3zpn0g646wpp6vr3wfwg1j8xb";
      eo = "14pl1hxr51cc5cnrqk2y3qyw6k1yn3s1fp60kpz9x82hx32qfipz";
      fi = "053apj2j77l8fabxdmf20xcqh3qw6bb3p5sxcyk5zpy0n7b6bqmq";
      ru = "0qg0smnazir70y68ynicybd0z6gbz6fb8fk12hk9r1d81nlhk9nn";
    }.${lang};
    name = "Firefox.dmg";
  };

  librewolf = fetchurl {
    url = {
      x86_64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/67555130893f500860494fa70a0bd17e/LibreWolf-${version}-2.x86_64.AppImage";
      aarch64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/525ff30464370d3adc8bf468f9066c83/LibreWolf-${version}-2.aarch64.AppImage";
    }.${system} or throwSystem;
    sha256 = {
      x86_64-linux = "0iykwzshia6nhw9ksxqd7d2x2p6bn8l8wvg8mr9zppia1vilp7pn";
      aarch64-linux = "19v93qx7r0kk8dx29g1n2c68bbdr32bxqczx9bbmcbm7m52n8w6w";
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

  appimageContents = appimageTools.extractType2 {
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
    inherit name meta;

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
      /usr/bin/hdiutil mount -nobrowse -mountpoint librewolf-mnt LibreWolf.dmg
      mkdir -p $out/Applications
      cp -r ./librewolf-mnt/LibreWolf.app $out/Applications
      /usr/bin/hdiutil unmount librewolf-mnt
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
