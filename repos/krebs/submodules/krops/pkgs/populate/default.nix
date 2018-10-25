with import ../../lib;
with shell;

{ coreutils, dash, findutils, git, jq, openssh, pass, rsync, writeDash }:

let
  check = { force, target }: let
    sentinelFile = "${target.path}/.populate";
  in shell' target /* sh */ ''
    ${optionalString force /* sh */ ''
      mkdir -vp ${quote (dirOf sentinelFile)}
      touch ${quote sentinelFile}
    ''}
    if ! test -f ${quote sentinelFile}; then
      >&2 printf 'error: missing sentinel file: %s\n' ${quote (
        optionalString (!isLocalTarget target) "${target.host}:" +
        sentinelFile
      )}
      exit 1
    fi
  '';

  pop.file = target: source: rsync' target (quote source.path);

  pop.git = target: source: shell' target /* sh */ ''
    if ! test -e ${quote target.path}; then
      git clone --recurse-submodules ${quote source.url} ${quote target.path}
    fi
    cd ${quote target.path}
    if ! url=$(git config remote.origin.url); then
      git remote add origin ${quote source.url}
    elif test "$url" != ${quote source.url}; then
      git remote set-url origin ${quote source.url}
    fi

    # TODO resolve git_ref to commit hash
    hash=${quote source.ref}

    if ! test "$(git log --format=%H -1)" = "$hash"; then
      if ! git log -1 "$hash" >/dev/null 2>&1; then
        git fetch origin
      fi
      git checkout "$hash" -- ${quote target.path}
      git -c advice.detachedHead=false checkout -f "$hash"
      git submodule update --init --recursive
    fi

    git clean -dfx
  '';

  pop.pass = target: source: let
    passPrefix = "${source.dir}/${source.name}";
  in /* sh */ ''
    umask 0077

    tmp_dir=$(${coreutils}/bin/mktemp -dt populate-pass.XXXXXXXX)
    trap cleanup EXIT
    cleanup() {
      rm -fR "$tmp_dir"
    }

    ${findutils}/bin/find ${quote passPrefix} -type f |
    while read -r gpg_path; do

      rel_name=''${gpg_path#${quote passPrefix}}
      rel_name=''${rel_name%.gpg}

      pass_date=$(
        ${git}/bin/git -C ${quote source.dir} log -1 --format=%aI "$gpg_path"
      )
      pass_name=${quote source.name}/$rel_name
      tmp_path=$tmp_dir/$rel_name

      ${coreutils}/bin/mkdir -p "$(${coreutils}/bin/dirname "$tmp_path")"
      PASSWORD_STORE_DIR=${quote source.dir} ${pass}/bin/pass show "$pass_name" > "$tmp_path"
      ${coreutils}/bin/touch -d "$pass_date" "$tmp_path"
    done

    ${rsync' target /* sh */ "$tmp_dir"}
  '';

  pop.pipe = target: source: /* sh */ ''
    ${quote source.command} | {
      ${shell' target /* sh */ "cat > ${quote target.path}"}
    }
  '';

  # TODO rm -fR instead of ln -f?
  pop.symlink = target: source: shell' target /* sh */ ''
    ln -fns ${quote source.target} ${quote target.path}
  '';

  populate = target: name: source: let
    source' = source.${source.type};
    target' = target // { path = "${target.path}/${name}"; };
  in writeDash "populate.${target'.host}.${name}" ''
    set -efu
    ${pop.${source.type} target' source'}
  '';

  rsync' = target: sourcePath: /* sh */ ''
    source_path=${sourcePath}
    if test -d "$source_path"; then
      source_path=$source_path/
    fi
    ${rsync}/bin/rsync \
        -e ${quote (ssh' target)} \
        -vFrlptD \
        --delete-excluded \
        "$source_path" \
        ${quote (
          optionalString (!isLocalTarget target)
                         "${target.user}@${target.host}:" +
          target.path
        )} \
      >&2
  '';

  shell' = target: script:
    if isLocalTarget target
      then script
      else /* sh */ ''
        ${ssh' target} ${quote target.host} ${quote script}
      '';

  ssh' = target: concatMapStringsSep " " quote [
    "${openssh}/bin/ssh"
    "-l" target.user
    "-o" "ControlPersist=no"
    "-p" target.port
    "-T"
  ];

in

{ force ? false, source, target }: writeDash "populate.${target.host}" ''
  set -efu
  ${check { inherit force target; }}
  set -x
  ${concatStringsSep "\n" (mapAttrsToList (populate target) source)}
''
