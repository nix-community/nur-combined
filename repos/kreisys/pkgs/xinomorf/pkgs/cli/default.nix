# We have to use bashInteractive
# because otherwise `compgen`
# won't be available...    ↴
{ runCommand, bashInteractive, writeText, nix, nix-prefetch-git, modules }:

let
  usage = writeText "xinomorf-usage.txt" ''
    Usage: xinomorf [--version] [--help] <command> [args]

    The available commands for execution are listed below.

    Commands:
        list|ls             List deployments installed on this system
        plan                Create a Terraform deployment plan
        apply               Apply a Terraform plan
        destroy             Destroy a Terraform deployment
        init                Initialize a new project

  '';

in runCommand "xinomorf" {
  buildInputs = [ nix nix-prefetch-git ];
} ''
  mkdir -p $out/bin

  cat <<'EOF' > $out/bin/xinomorf
  #!${bashInteractive}/bin/bash
  prefix="xf"

  set -e

  stderr() {
    1>&2 echo -e "$@"
  }

  err() {
    stderr "\e[31merror\e[0m:" "$@"
  }

  indent() {
    sed 's/^/  /'
  }

  deployments() {
    compgen -c $prefix- | cut -d- -f2-
  }

  have_deployments() {
    [[ $(deployments | wc -l) > 0 ]]
  }

  has_deployment() {
    local deployment=$1
    deployments | grep "^$deployment$" &>/dev/null
  }

  cmd=$1

  if [[ -n $cmd ]]; then shift; fi

  case $cmd in
    list|ls)
      deployments
      ;;
    init)
      echo Initializing new project $PWD
      cp -r ${./skel}/. .
      chmod -R +w .
      mkdir -p pins
      cd $_
      nix-prefetch-git https://github.com/kreisys/xinomorf > xinomorf.json
      nix-prefetch-git https://github.com/kreisys/anxt     > anxt.json
      ;;
    plan|apply|destroy)
      nix_build_opts=()
      terraform_opts=()
      positional=()
      while [[ $# -gt 0 ]]; do
        case $1 in
          --*)
            nix_build_opts+=("$1")
            shift
            ;;
          -*)
            terraform_opts+=("$1")
            shift
            ;;
          *)
            positional+=("$1")
            shift
            ;;
        esac
      done

      set -- "''${positional[@]}"

      if [[ -n $1 && ''${1::1}  != "-" ]]; then
        deployment=''${1:-$XMF_DEPLOY}
        shift
      fi

      if [[ -z $deployment ]]; then
        deployment=$(basename $PWD)

        if [[ -f $PWD/xinomorf.nix ]]; then
          xinomorf=$PWD/xinomorf.nix
        else
          xinomorf=${../../.}
        fi

        PATH=$(nix-build "''${nix_build_opts[@]}" --no-out-link --argstr xinomorf $xinomorf ${./ad-hoc-wrapper.nix})/bin:$PATH
      fi

      if ! has_deployment $deployment; then
        err "deployment '$deployment' does not exist on this system."
        if have_deployments; then
          stderr "Available deployments:"
          deployments | indent
        fi
        exit 1
      fi

      echo $prefix-$deployment $cmd "''${terraform_opts[@]}"
      exec $prefix-$deployment $cmd "''${terraform_opts[@]}"
      ;;
    *)
      cat ${usage}
      ;;

  esac
  EOF
  chmod +x $out/bin/xinomorf
  ln -s $out/bin/xinomorf $out/bin/xm
''
