self: super:
{
    compton-git = super.compton-git.overrideAttrs (o: rec {
      name = "compton-git-${version}";
      version = "2018-10-09";

      src = super.fetchFromGitHub {
        owner  = "yshui";
        repo   = "compton";
        rev    = "6a8df0ada7eae688c96cdbea258a33cda07ae4e6";
        sha256 = "0f428y091w08iv41ar5dcn1lrs18nh67wskjgzq9c64vwqxpk7q7";
      };

      COMPTON_VERSION = "git-${version}-${src.rev}";

      # Default:
      #buildInputs = [
      #  dbus libX11 libXcomposite libXdamage libXrender libXrandr libXext
      #  libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      #];

      buildInputs = with self; with xorg; [
        dbus libX11 libXcomposite libXext
        libXinerama libdrm pcre libxml2 libxslt libconfig libGL
        # Removed:
        # libXdamage libXrender libXrandr

        # New:
        libxcb xcbutilrenderutil xcbutilimage
        pixman libev
      ];

    });
    compton = self.compton-git;
}
