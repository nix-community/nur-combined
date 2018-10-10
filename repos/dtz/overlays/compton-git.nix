self: super:
{
    compton-git = super.compton-git.overrideAttrs (o: rec {
      name = "compton-git-${version}";
      version = "2018-10-10";

      src = super.fetchFromGitHub {
        owner  = "yshui";
        repo   = "compton";
        rev    = "de6e2f5792aad6d18547b7a3a555cb9a3de0f516";
        sha256 = "0yiy49hjp11mh2rhkm4rdj55r83fk6rj4gkiwrfz9i85ba3dx0cx";
      };

      COMPTON_VERSION = "git-${version}-${src.rev}";

      # Default:
      #buildInputs = [
      #  dbus libX11 libXcomposite libXdamage libXrender libXrandr libXext
      #  libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      #];

      buildInputs = with self; with xorg; [
        dbus libX11 libXext xproto
        libXinerama libdrm pcre libxml2 libxslt libconfig libGL
        # Removed:
        # libXcomposite libXdamage libXrender libXrandr

        # New:
        libxcb xcbutilrenderutil xcbutilimage
        pixman libev
      ];

      makeFlags = [ "BUILD_TYPE=Release" ];

    });
    compton = self.compton-git;
}
