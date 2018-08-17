self: super:

let

  newVersion = "18.2.0.183.1748";

in

  {
    sqldeveloper = super.sqldeveloper.overrideAttrs (old: rec {
      name = "sqldeveloper-${newVersion}";

      src = self.requireFile {
        name = "sqldeveloper-${newVersion}-no-jre.zip";
        sha256 = "0clz2w4ghqczy9sz6j4qqygk20whdwkca192pd3v0dw09875as0k";
        url = "http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/";
      };

      buildCommand = ''
        mkdir -p $out/bin
        echo  >$out/bin/sqldeveloper '#! ${self.stdenv.shell}'
        echo >>$out/bin/sqldeveloper 'export JAVA_HOME=${super.oraclejdk}'
        echo >>$out/bin/sqldeveloper 'export JDK_HOME=$JAVA_HOME'
        echo >>$out/bin/sqldeveloper "cd $out/lib/${name}/sqldeveloper/bin"
        echo >>$out/bin/sqldeveloper '${self.stdenv.shell} sqldeveloper "$@"'
        chmod +x $out/bin/sqldeveloper

        mkdir -p $out/lib/
        cd $out
        unzip ${src}
        mv sqldeveloper $out/lib/${name}
      '';
    });
  }
