#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash git jq

cd "$(dirname "$0")"/..

keep_tempdir=false

nix_args=()
for arg in "$@"
do
  case "$arg" in
    --keep-tempdir)
      keep_tempdir=true
      ;;
    *)
      # passthru arg to nix-env
      nix_args+=("$arg")
      ;;
  esac
done

# parse repo_name from email of the most-common commit author
# at least this works for me :D
# the actual repo_name is stored in NUR's repos.json
# https://github.com/nix-community/NUR/blob/master/repos.json
# but this should work offline
repo_name=$(git log --format=%ae | grep -v '^$' | cut -d@ -f1 | sort | uniq -c | sort -n --reverse | head -n1 | cut -c9-)
if [ -z "$repo_name" ]; then
  repo_name='your-name'
fi

echo "repo_name: $repo_name"

source_repo_path=$(readlink -f .)
source_repo_url="file://$source_repo_path"

tempdir=$(mktemp -d --suffix=-nur-eval-test)

# create a local clone, so we use only committed files
repo_path=$tempdir/repo
mkdir -p $repo_path
repo_url=file://$repo_path
repo_commit=$(git -C . rev-parse HEAD)
git -C $repo_path init --quiet
git -C $repo_path remote add repo "$source_repo_url"
git -C $repo_path fetch --quiet --update-shallow repo $repo_commit
git -C $repo_path checkout --quiet $repo_commit
# by default, NUR update does not fetch git submodules
# NUR/ci/nur/prefetch.py:
#   if self.repo.submodules:
#     cmd += ["--fetch-submodules"]
# TODO get repo.submodules from repos.json
# when submodules are missing, eval fails with:
# error: getting status of '/nix/store/...': No such file or directory
#git -C $repo_path submodule update --init --depth=1 --recursive --recommend-shallow

# the actual value of repo.file is stored in
# https://github.com/nix-community/NUR/blob/master/repos.json
repo_file=default.nix
# evalRepo.nix only works with default.nix
if false; then
if [ -e $repo_path/flake.nix ]; then
  echo entrypoint is flake.nix
  repo_file=flake.nix
else
  echo entrypoint is default.nix
fi
fi

repo_src=$repo_path/$repo_file
echo "repo_src: $repo_src"

EVALREPO_PATH=$tempdir/lib/evalRepo.nix
mkdir -p $(dirname $EVALREPO_PATH)
# https://github.com/nix-community/NUR/blob/master/lib/evalRepo.nix
cat >$EVALREPO_PATH <<'EOF'
{ name
, url
, src
, pkgs # Do not use this for anything other than passing it along as an argument to the repository
, lib
}:
let

  prettyName = "[32;1m${name}[0m";

  # Arguments passed to each repositories default.nix
  passedArgs = {
    pkgs = if pkgs != null then pkgs else throw ''
      NUR import call didn't receive a pkgs argument, but the evaluation of NUR's ${prettyName} repository requires it.

      This is either because
        - You're trying to use a [1mpackage[0m from that repository, but didn't pass a `pkgs` argument to the NUR import.
          In that case, refer to the installation instructions at https://github.com/nix-community/nur#installation on how to properly import NUR

        - You're trying to use a [1mmodule[0m/[1moverlay[0m from that repository, but it didn't properly declare their module.
          In that case, inform the maintainer of the repository: ${url}
    '';
  };

  expr = import src;
  args = builtins.functionArgs expr;
  # True if not all arguments are either passed by default (e.g. pkgs) or defaulted (e.g. foo ? 10)
  usesCallPackage = ! lib.all (arg: lib.elem arg (lib.attrNames passedArgs) || args.${arg}) (lib.attrNames args);

in if usesCallPackage then throw ''
    NUR repository ${prettyName} is using the deprecated callPackage syntax which
    might result in infinite recursion when used with NixOS modules.
  '' else expr (builtins.intersectAttrs args passedArgs)
EOF

eval_path=$tempdir/default.nix
cat >$eval_path <<EOF
with import <nixpkgs> {};
import $EVALREPO_PATH {
  name = "$repo_name";
  url = "$repo_url";
  src = $repo_src;
  inherit pkgs lib;
}
EOF



# evaluate the repo
# based on https://github.com/nix-community/NUR/blob/master/ci/nur/update.py

nixpkgs_path=$(nix-instantiate --find-file nixpkgs)

# nix-env --help
# nix-env --help --query

a=()
a+=(nix-env)
a+=(--file "$eval_path") # Specifies  the Nix expression
a+=(--query) # display information about packages
a+=('.*') # names
a+=(--available) # The query operates on the derivations that are available in the active Nix expression.
a+=(--attr-path) # Print the attribute path of the derivation
a+=(--meta) # Print all of the meta-attributes of the derivation.
a+=(--json)
a+=(--allowed-uris https://static.rust-lang.org)
a+=(--option restrict-eval true)
a+=(--option allow-import-from-derivation true)
a+=(--drv-path) # Print the path of the store derivation.
a+=(--show-trace)
#a+=(--verbose)
a+=(-I nixpkgs=$nixpkgs_path) # Add a path to the Nix expression search path.
a+=(-I "$repo_path")
a+=(-I "$eval_path")
a+=(-I "$EVALREPO_PATH")

# passthru args to nix-env, for example "--verbose"
a+=("${nix_args[@]}")

export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1

# capture stdout with package list
# show stderr with eval errors
result=0

echo "evaluating packages..."

# get eval time
# NUR has eval timeout after 15 seconds
time \
packages_json=$("${a[@]}")

rc=$?

if [[ "$rc" == "0" ]]; then
  echo
  echo eval ok
  echo
  echo your packages:
  echo "$packages_json" | jq -r 'to_entries[] | "\(.key)\n  \(.value.name)\n  \(.value.meta.position)\n  \(.value.meta.description)\n  \(.value.meta.homepage)"'

  echo writing $tempdir/packages.html
  (
    echo '<!DOCTYPE html>'
    echo '<html lang="en">'
    echo '<head>'
    echo '<meta charset="utf-8">'
    # no. github markdown renderer shows this as plain text
    #echo '<title>NUR packages</title>'
    echo '</head>'
    echo '<body>'
    echo '<h1>nur-packages</h1>'
    #echo '<h2>nur.repos.'$repo_name'</h2>'

    # no. this is too wide for github blob api
    # same layout as
    if false; then
    echo '<table>'

    echo '<thead>'
    echo '<tr>'
    echo '<td>name</td>'
    echo '<td>attribute</td>'
    echo '<td>description</td>'
    echo '</tr>'
    echo '</thead>'

    echo '<tbody>'

    echo "$packages_json" | jq -r '
      to_entries[] |
      "<tr>\n<td>\(
        if .value.meta.homepage == null then ""
        else "<a href=\"\(.value.meta.homepage)\">"
        end
      )\(.value.name)\(
        if .value.meta.homepage == null then ""
        else "</a>"
        end
      )</td>\n<td><a href=\"\(
        .value.meta.position | sub(":(?<x>[0-9]+)$"; "#L\(.x)") | .[('${#repo_path}'+1):]
      )\">nur.repos.'"$repo_name"'.\(.key)</a></td>\n<td>\(
        if .value.meta.description == null then "" else
        .value.meta.description |
        gsub("&"; "&amp;") |
        gsub("<"; "&lt;") |
        gsub(">"; "&gt;") |
        gsub("\n"; "&#10;") |
        .
        end
      )</td>\n</tr>"
    '

    echo '</tbody>'

    echo '</table>'

    elif false; then

    # vertical layout: h3 div div div
    echo "$packages_json" | jq -r '
      to_entries[] |
      "<h3>" + .key + "</h3>\n" +
      "<div><a href=\"" + (
        .value.meta.position | sub(":(?<x>[0-9]+)$"; "#L\(.x)") | .[('${#repo_path}'+1):]
      ) + "\">nur.repos.'"$repo_name"'." + .key + "</a></div>\n" +
      "<div>" + (
        if .value.meta.homepage == null then ""
        else "<a href=\"" + .value.meta.homepage + "\">"
        end
      ) + .value.name + (
        if .value.meta.homepage == null then ""
        else "</a>"
        end
      ) + "</div>\n" +
      "<div>" + (
        if .value.meta.description == null then "" else
        .value.meta.description |
        gsub("&"; "&amp;") |
        gsub("<"; "&lt;") |
        gsub(">"; "&gt;") |
        gsub("\n"; "<br>") |
        .
        end
      ) + "</div>"
    '

    else

    # inline layout: li
    echo '<ul>'
    echo "$packages_json" | jq -r '
      to_entries[] |
      "<li id=\"nur.repos.'"$repo_name"'." + .key + "\"><a href=\"" + (
        .value.meta.position | sub(":(?<x>[0-9]+)$"; "#L\(.x)") | .[('${#repo_path}'+1):]
      ) + "\">nur.repos.'"$repo_name"'." + .key + "</a> -\n" +
      (
        if .value.meta.homepage == null then ""
        else "<a href=\"" + .value.meta.homepage + "\">"
        end
      ) + .value.name + (
        if .value.meta.homepage == null then ""
        else "</a>"
        end
      ) + " -\n" +
      (
        if .value.meta.description == null then "" else
        .value.meta.description |
        gsub("&"; "&amp;") |
        gsub("<"; "&lt;") |
        gsub(">"; "&gt;") |
        gsub("\n"; "<br>") |
        .
        end
      ) + "</li>"
    '
    echo '</ul>'
    echo '<h2>see also</h2>'
    echo '<ul>'
    echo '<li><a href="https://github.com/nix-community/NUR">github.com/nix-community/NUR</a></li>'
    echo '<li><a href="https://nur.nix-community.org/">nur.nix-community.org</a></li>'
    echo '<li><a href="https://nur.nix-community.org/repos/'$repo_name'/">nur.nix-community.org/repos/'$repo_name'</a></li>'
    echo '</ul>'

    fi

    echo '</body>'
    echo '</html>'
  ) >$tempdir/packages.html

  echo "writing $source_repo_path/readme.md"
  cp $tempdir/packages.html "$source_repo_path/readme.md"

  echo writing $tempdir/packages.json
  echo "$packages_json" >$tempdir/packages.json

  echo hit enter to remove tempdir $tempdir
  read

  echo removing tempdir
  rm -rf $tempdir
else
  result=$?
  echo eval fail
  if $keep_tempdir; then
    echo keeping tempdir: $tempdir
  else
    echo "removing tempdir. add '--keep-tempdir' to keep temporary files"
    rm -rf $tempdir
  fi
fi

exit $result
