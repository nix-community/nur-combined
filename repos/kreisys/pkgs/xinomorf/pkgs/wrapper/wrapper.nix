{ callPackage, stdenv, lib, runCommand, cacert, terraform, git, terraformStubs, terraform-landscape, nix
, name
, src
, filter
, modules
, vars }:

with builtins;
with lib;

let
  stubs    = terraformStubs { inherit vars; };
  modules' = mapAttrs (name: path: callPackage path { inherit stubs; }) modules;

  files = let
    regular = attrNames (filterAttrs (_: v: v == "regular") (readDir src));
    tf    = builtins.filter (filename: hasSuffix ".tf"     filename) regular;
    tfNix = builtins.filter (filename: hasSuffix ".tf.nix" filename) regular;
  in if mutuallyExclusive tf (map (removeSuffix ".nix") tfNix) then {
    inherit tf tfNix;
  } else throw "Filenames must be unique (can't have both foo.tf.nix and foo.tf)";
in runCommand name {
  src = if isDerivation src then (src + "/etc/terraform") else path {
    path = src;
    filter = path: type: match "^.*\.tf\.nix$" path == null && match "^.*\.tfstate.*$" path == null && type != "symlink" && filter path type;
  };
  buildInputs = [ terraform git nix cacert ];

} ''
  set -e

  mkdir $out
  cd $_

  mkdir -p lib/terraform {bin,etc}
  cd $_

  cp -r $src terraform
  chmod ug+rwx terraform

  cd terraform

  ${concatStringsSep "\n" (map (fileName: ''
    cat <<'EOF' > ${removeSuffix ".nix" fileName}
    ${concatStringsSep "\n" (callPackage (src + "/${fileName}") (modules' // stubs))}
    EOF
    ''
  ) files.tfNix)}

  terraform fmt

  export TF_DATA_DIR=$out/lib/terraform
  GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt" terraform init

  cat <<EOF > $out/bin/xf-${name}
  #!${stdenv.shell}
  PATH=${terraform}/bin:$PATH

  # Write state files to the user's current directory
  tf_stat="\$PWD/terraform.tfstate"

  tf_conf="$out/etc/terraform"
  tf_data="$out/lib/terraform"

  export TF_DATA_DIR="\$tf_data"

  bin="\$(basename \$0)"
  if [[ \$bin == xf-${name} ]]; then
    cmd="\$1"
    shift
  else
    cmd="\$bin"
  fi

  case \$cmd in
    init)
      echo no
      ;;
    plan)
      terraform \$cmd -input=false -state=\$tf_stat "\$@" $out/etc/terraform | ${terraform-landscape}/bin/landscape
      ;;
    apply)
      exec terraform \$cmd -input=false -auto-approve -state=\$tf_stat "\$@" $out/etc/terraform
      ;;
    destroy)
      exec terraform \$cmd -input=false -force -state=\$tf_stat "\$@" $out/etc/terraform
      ;;
    terraform)
      case \$1 in
        fmt|state|import)
          exec terraform "\$@"
          ;;
        *)
          echo "Please don't run terraform directly"
          exit 1
        ;;
      esac
      ;;
  esac
  EOF
  chmod +x $out/bin/xf-${name}
''
