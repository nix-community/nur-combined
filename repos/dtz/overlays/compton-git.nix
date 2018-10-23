self: super:
{
    compton-git = super.compton-git.overrideAttrs (o: rec {
      name = "compton-${version}";
      #name = "compton-git-${version}";
      version = "3-rc2"; # "2018-10-15";

      src = super.fetchFromGitHub {
        owner  = "yshui";
        repo   = "compton";
        rev    = "v${version}";
        sha256 = "0458jbf9xrgl599pc3klfavrcnywgyfyasih677qanl3z78imkxx";
      };

      postPatch = (o.postPatch or "") + ''
        substituteInPlace meson.build \
          --replace "version = run_command('git', 'describe').stdout().strip()" \
                    "version = 'v${version}'";
      '';
      #COMPTON_VERSION = version; # "git-${version}-${src.rev}";

      # Default:
      #buildInputs = [
      #  dbus libX11 libXcomposite libXdamage libXrender libXrandr libXext
      #  libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      #];

      nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ self.meson self.ninja ];

      buildInputs = with self; with xorg; [
        dbus libX11 libXext
        # support old or new unified proto packages
        (xorg.xproto or xorg.xorgproto)
        libXinerama libdrm pcre libxml2 libxslt libconfig libGL
        # Removed:
        # libXcomposite libXdamage libXrender libXrandr

        # New:
        libxcb xcbutilrenderutil xcbutilimage
        pixman libev
      ];

      #makeFlags = [ "BUILD_TYPE=Release" ];
      mesonFlags = (o.mesonFlags or []) ++ [
        "-Dvsync_drm=true"
      ];

    });
    compton = self.compton-git;
}
