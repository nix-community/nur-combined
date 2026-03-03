{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
}:

let
  pname = "wechat";
  version = "4.1.0.13";

  keyHook = stdenv.mkDerivation {
    pname = "wxdump-keyhook";
    version = "1.0";
    src = builtins.toFile "wxdump_keyhook.c" ''
      #define _GNU_SOURCE
      #include <dlfcn.h>
      #include <stdio.h>
      #include <stdlib.h>

      typedef struct sqlite3 sqlite3;

      static void dump_key(const void* pKey, int nKey) {
          if (!pKey || nKey <= 0) return;
          const unsigned char* p = (const unsigned char*)pKey;
          const char* out_path = getenv("WX_KEY_OUT");
          FILE* fp = NULL;
          if (out_path && *out_path) {
              fp = fopen(out_path, "a");
          }
          if (!fp) fp = stderr;
          fprintf(fp, "[wxdump-hook] key(%d)=", nKey);
          for (int i = 0; i < nKey; ++i) fprintf(fp, "%02x", p[i]);
          fputc('\n', fp);
          if (fp != stderr) fclose(fp);
      }

      int sqlite3_key(sqlite3* db, const void* pKey, int nKey) {
          dump_key(pKey, nKey);
          int (*real)(sqlite3*, const void*, int) = dlsym(RTLD_NEXT, "sqlite3_key");
          return real ? real(db, pKey, nKey) : 0;
      }

      int sqlite3_key_v2(sqlite3* db, const char* zDb, const void* pKey, int nKey) {
          dump_key(pKey, nKey);
          int (*real)(sqlite3*, const char*, const void*, int) = dlsym(RTLD_NEXT, "sqlite3_key_v2");
          return real ? real(db, zDb, pKey, nKey) : 0;
      }
    '';
    dontUnpack = true;
    dontConfigure = true;
    dontFixup = true;
    nativeBuildInputs = [ stdenv.cc ];
    buildPhase = ''
      $CC -shared -fPIC -o wxdump_keyhook.so $src -ldl
    '';
    installPhase = ''
      mkdir -p $out/lib
      cp wxdump_keyhook.so $out/lib/
    '';
  };

  src = fetchurl {
    urls = [
      "https://dldir1.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
      "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
    ];
    hash = "sha256-Pfl81lNVlMJWyPqFli1Af2q8pRLujcKCjYoILCKDx8U=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/wechat/wechat
    '';
  };
in
appimageTools.wrapAppImage {
  inherit pname version;

  src = appimageContents;

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${appimageContents}/wechat.desktop $out/share/applications/
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${appimageContents}/wechat.png $out/share/icons/hicolor/256x256/apps/

    substituteInPlace $out/share/applications/wechat.desktop \
      --replace-fail 'Exec=AppRun %U' 'Exec=env GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx wechat %U'

    # Always preload keyhook so running "wechat" dumps SQLCipher key automatically.
    mkdir -p $out/lib
    cp ${keyHook}/lib/wxdump_keyhook.so $out/lib/

    # Prepend env exports to the existing wrapper created by wrapAppImage.
    cat > $out/bin/wechat.new <<'EOF'
    #!/bin/sh
    export LD_PRELOAD='@LD_PRELOAD@'
    if [ -z "''${WX_KEY_OUT:-}" ]; then
      WX_KEY_OUT="''${XDG_CACHE_HOME:-$HOME/.cache}/wechat_key.log"
    fi
    export WX_KEY_OUT
    EOF
    substituteInPlace $out/bin/wechat.new \
      --replace '@LD_PRELOAD@' "$out/lib/wxdump_keyhook.so"
    tail -n +2 $out/bin/wechat >> $out/bin/wechat.new
    mv $out/bin/wechat.new $out/bin/wechat
    chmod +x $out/bin/wechat
  '';

  meta = {
    description = "WeChat - Messaging and calling app";
    homepage = "https://www.wechat.com/";
    downloadPage = "https://linux.weixin.qq.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "wechat";
    platforms = [ "x86_64-linux" ];
  };
}
