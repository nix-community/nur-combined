self: super:
{
    compton-git = super.compton-git.overrideAttrs (o: rec {
      name = "compton-git-${version}";
      version = "2018-10-15";

      src = super.fetchFromGitHub {
        owner  = "yshui";
        repo   = "compton";
        rev    = "93dd2d92fd8bc0605119f3862f927b67ae75722e";
        sha256 = "0a06h4xi8a5753yhd86zx7zgrhxnm0hdmja6rgm80can70ka0v4w";
      };

      COMPTON_VERSION = "git-${version}-${src.rev}";

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

    });
    compton = self.compton-git;
}
