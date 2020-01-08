{ stdenv
, fetchFromGitHub
, perl
, writeText
}:

stdenv.mkDerivation {
  pname = "pass-extension-b2";
  version = "1";

  src = writeText "b2.bash" ''
    path=$1
    [[ -z $path ]] && die
    check_sneaky_paths "$path"
    passfile="$PREFIX/$path.gpg"
    [[ -f $passfile ]] || die "Error: $path is not in the password store."

    field() {
      out=$(printf %s "$1" | cut -d: -f2-)
      printf %s "''${out# }"
    }

    first=""
    B2_KEY_ID="" # optional
    while read line; do
      case "$line" in
        keyId:*)
          export B2_KEY_ID=$(field "$line")
          ;;
        accountId:*)
          export B2_ACCOUNT_ID=$(field "$line")
          ;;
        *)
          if [[ -z $first ]]; then
            export B2_APP_KEY="$line"
          fi
          first=y
          ;;
      esac
    done <<< "$($GPG -d "''${GPG_OPTS[@]}" "$passfile")"

    declare -p B2_KEY_ID B2_ACCOUNT_ID B2_APP_KEY
  '';

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    install -Dm0755 $src $out/lib/password-store/extensions/b2.bash
  '';

  meta = with stdenv.lib; {
    description = "A pass extension to retrieve meta-data properties";
    homepage = https://github.com/rjekker/pass-extension-meta;
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
