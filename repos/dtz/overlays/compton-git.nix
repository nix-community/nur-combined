self: super:
{
    compton-git = super.compton-git.overrideAttrs (o: rec {
      name = "compton-git-${version}";
      version = "2018-10-13";

      src = super.fetchFromGitHub {
        owner  = "yshui";
        repo   = "compton";
        rev    = "aa2098eefdb452593ef98a71fd7301ffdc9ff4d5";
        sha256 = "1q66z3bwacmn9vaciyqgi64rdazq2x14cb67fzyq23ci8m6ahf1r";
      };

      COMPTON_VERSION = "git-${version}-${src.rev}";

      # Default:
      #buildInputs = [
      #  dbus libX11 libXcomposite libXdamage libXrender libXrandr libXext
      #  libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      #];

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
