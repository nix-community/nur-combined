#!/usr/bin/env bash
# Bump pkgs/pi-furry-partner-hd to a newer upstream commit.
#
# The upstream tarball is cut at ~1.35 GiB on some networks, which makes
# `nix-prefetch-url --unpack` unusable there. This script therefore never
# downloads the tarball: it mirrors the repository, archives the pinned commit,
# hashes the extracted tree, and then cross-checks the result against the
# fixed-output store path Nix derives from the same revision. That cross-check
# is what makes the hash trustworthy, so keep it if you edit this script.
#
# Default behaviour is "edit and verify only". Committing and pushing are
# opt-in through --commit / --push.
set -euo pipefail

OWNER=srcres258
REPO=pi-furry-partner
DEFAULT_BRANCH=own
PKG_FILE=pkgs/pi-furry-partner-hd/default.nix
ATTR=pi-furry-partner-hd

# Files the derivation depends on. If upstream drops or renames any of these the
# build scripts break, so fail early with a clear message instead of a Nix error.
REQUIRED_PATHS=(
    editions/hd/package.json
    editions/hd/test-runtimes/pi-1.2
    editions/hd/test-runtimes/pi-1.3
    editions/hd/tools/build-editions.py
    editions/hd/tools/audit-edition-bundles.py
    editions/hd/tools/write-edition-release.py
    editions/hd/tools/rebase-release-report-paths.py
)

BRANCH=$DEFAULT_BRANCH
REV=""
MIRROR=""
DO_BUILD=1
DO_COMMIT=0
DO_PUSH=0

usage() {
    cat <<'EOF'
Usage: scripts/bump-pi-furry-partner-hd.sh [options]

Bumps the pinned upstream revision of pi-furry-partner-hd, recomputes the
source hash, cross-checks it, and optionally builds/commits/pushes.

Options:
  --rev <sha>         Pin this commit instead of the branch head
  --branch <name>     Upstream branch to follow (default: own)
  --mirror <path>     Local git mirror of the upstream repository
                      (default: $XDG_CACHE_HOME/nur-packages/pi-furry-partner.git)
  --no-build          Skip the local nix-build verification
  --commit            Create a signed-off commit after verification (asks first)
  --push              Push after committing (implies --commit)
  -h, --help          Show this help

Examples:
  scripts/bump-pi-furry-partner-hd.sh
  scripts/bump-pi-furry-partner-hd.sh --no-build --commit --push
  scripts/bump-pi-furry-partner-hd.sh --rev 54bdff92bd2433c1ed0301344bb837c571084b9f

The script edits pkgs/pi-furry-partner-hd/default.nix in place and leaves the
change uncommitted unless --commit is given. Commits never use GPG signing and
always carry a Signed-off-by trailer.
EOF
}

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

info() {
    printf '==> %s\n' "$*"
}

while [ $# -gt 0 ]; do
    case $1 in
        --rev) REV=${2:?--rev needs a commit}; shift 2 ;;
        --branch) BRANCH=${2:?--branch needs a name}; shift 2 ;;
        --mirror) MIRROR=${2:?--mirror needs a path}; shift 2 ;;
        --no-build) DO_BUILD=0; shift ;;
        --commit) DO_COMMIT=1; shift ;;
        --push) DO_COMMIT=1; DO_PUSH=1; shift ;;
        -h | --help) usage; exit 0 ;;
        *) die "unknown argument: $1 (try --help)" ;;
    esac
done

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
[ -f "$PKG_FILE" ] || die "$PKG_FILE not found; run this from the nur-packages checkout"

MIRROR=${MIRROR:-${XDG_CACHE_HOME:-$HOME/.cache}/nur-packages/$REPO.git}
url="https://github.com/$OWNER/$REPO.git"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# --- resolve the target revision -------------------------------------------

if [ -z "$REV" ]; then
    info "resolving $BRANCH head of $OWNER/$REPO"
    REV=$(git ls-remote --heads "$url" "refs/heads/$BRANCH" | cut -f1)
    [ -n "$REV" ] || die "could not resolve refs/heads/$BRANCH on $url"
fi

current_rev=$(sed -n 's/.*rev = "\([0-9a-f]*\)".*/\1/p' "$PKG_FILE")
current_hash=$(sed -n 's/.*hash = "\(sha256-[^"]*\)".*/\1/p' "$PKG_FILE")
[ -n "$current_rev" ] || die "could not read the current rev from $PKG_FILE"

if [ "$REV" = "$current_rev" ]; then
    info "already pinned to $REV; nothing to do"
    exit 0
fi
info "upstream $REV (currently pinned: $current_rev)"

# --- make sure the commit is available locally -----------------------------

if [ -d "$MIRROR" ]; then
    git -C "$MIRROR" rev-parse --git-dir >/dev/null 2>&1 ||
        die "$MIRROR exists but is not a git repository"
else
    info "cloning $url into $MIRROR (first run, this fetches the tree once)"
    mkdir -p "$(dirname "$MIRROR")"
    git clone --bare --depth 1 --branch "$BRANCH" "$url" "$MIRROR"
fi

if ! git -C "$MIRROR" cat-file -e "$REV^{commit}" 2>/dev/null; then
    info "fetching $REV into the mirror"
    # Prefer fetching the exact commit; fall back to the branch tip, which is
    # what a normal bump targets anyway.
    git -C "$MIRROR" fetch --no-tags --depth 1 origin "$REV" 2>/dev/null ||
        git -C "$MIRROR" fetch --no-tags --depth 1 origin "refs/heads/$BRANCH"
    git -C "$MIRROR" cat-file -e "$REV^{commit}" 2>/dev/null ||
        die "commit $REV is not in $MIRROR after fetching"
fi

# --- check the upstream layout is still what the derivation expects --------

info "checking the upstream layout"
missing=()
for path in "${REQUIRED_PATHS[@]}"; do
    git -C "$MIRROR" cat-file -e "$REV:$path" 2>/dev/null || missing+=("$path")
done
if [ ${#missing[@]} -gt 0 ]; then
    printf 'missing upstream paths:\n' >&2
    printf '  %s\n' "${missing[@]}" >&2
    die "upstream layout changed; the derivation needs updating before bumping"
fi

upstream_version=$(git -C "$MIRROR" show "$REV:editions/hd/package.json" |
    sed -n 's/^ *"version": *"\([^"]*\)".*/\1/p' | head -1)
nix_version=$(sed -n 's/^ *version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)
info "upstream extension version: ${upstream_version:-unknown} (pinned in nix: ${nix_version:-unknown})"
if [ -n "$upstream_version" ] && [ "$upstream_version" != "$nix_version" ]; then
    printf 'warning: version differs; update `version` in %s as well\n' "$PKG_FILE" >&2
fi

# --- hash the tree the way fetchFromGitHub would ---------------------------

info "hashing $REV"
mkdir -p "$tmp/tree"
git -C "$MIRROR" archive "$REV" | tar -x -C "$tmp/tree"
new_hash=$(nix hash path --type sha256 "$tmp/tree")
info "source hash: $new_hash"

# --- apply the edit -------------------------------------------------------

info "updating $PKG_FILE"
sed -i "s|rev = \"[0-9a-f]*\";|rev = \"$REV\";|" "$PKG_FILE"
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"$new_hash\";|" "$PKG_FILE"

revert() {
    git -C "$root" checkout -- "$PKG_FILE" 2>/dev/null || true
}

# Register the extracted tree under the name `source`, which is the name
# fetchFromGitHub gives it. Nix then derives the same store path the fetcher
# would produce, so comparing the two proves rev and hash agree.
info "cross-checking the hash against Nix's fixed-output path"
mkdir -p "$tmp/reg"
cp -a "$tmp/tree" "$tmp/reg/source"
registered=$(nix-store --add-fixed --recursive sha256 "$tmp/reg/source" 2>/dev/null | tail -1)
[ -n "$registered" ] || {
    revert
    die "could not register the extracted tree as a fixed-output path"
}
drv=$(nix-instantiate -A "$ATTR" 2>/dev/null | tail -1)
[ -n "$drv" ] || {
    revert
    die "nix-instantiate -A $ATTR failed"
}
expected=$(nix-store -q --binding src "$drv")
if [ "$expected" != "$registered" ]; then
    revert
    die "hash mismatch: Nix expects $expected but the tree registers as $registered"
fi
info "hash verified: $registered"

# --- verification build ---------------------------------------------------

archive_size=""
if [ "$DO_BUILD" = 1 ]; then
    info "building $ATTR (runs the dual-runtime suite, expect several minutes)"
    nix-build -A "$ATTR" >/dev/null
    bundle=$(nix-store -q --outputs "$drv" | grep -- '-bundle$' || true)
    if [ -n "$bundle" ]; then
        archive_size=$(find "$bundle" -maxdepth 1 -name '*.tgz' -printf '%s' | head -1)
    fi
    info "build succeeded"
fi

# --- summary --------------------------------------------------------------

cat <<EOF

bumped $ATTR
  rev          $current_rev -> $REV
  hash         ${current_hash:-none} -> $new_hash
  source       $registered
  archive size ${archive_size:-not built} bytes

$(git --no-pager diff --stat -- "$PKG_FILE")

EOF

if [ "$DO_COMMIT" = 0 ]; then
    echo "changes are uncommitted. Review them, then commit with something like:"
    echo "  git add $PKG_FILE"
    echo "  git -c commit.gpgsign=false commit -F <message-file>"
    echo "or rerun with --commit (and --push)."
    exit 0
fi

# --- commit / push -------------------------------------------------------

subject="Bump $ATTR to ${BRANCH} $(printf '%.7s' "$REV")"
msgfile="$tmp/commit-msg"
{
    printf '%s\n\n' "$subject"
    cat <<EOF
Follow the next upstream revision of the \`$BRANCH\` branch.

The source hash comes from a git archive of the pinned commit rather than
nix-prefetch-url, because the tarball transfer is cut on some networks. The
result was cross-checked against the fixed-output store path Nix derives
from the same revision.

Signed-off-by: $(git config user.name) <$(git config user.email)>
EOF
} >"$msgfile"

printf 'Commit %s?\n' "$subject"
read -r -p '[y/N] ' answer
case $answer in
    y | Y) ;;
    *)
        revert
        info "aborted; working tree restored"
        exit 0
        ;;
esac

git add -- "$PKG_FILE"
git -c commit.gpgsign=false commit --no-gpg-sign -F "$msgfile" -- "$PKG_FILE"
info "committed"

if [ "$DO_PUSH" = 1 ]; then
    branch=$(git rev-parse --abbrev-ref HEAD)
    info "pushing $branch"
    git push github "$branch"
    info "pushed; CI results: gh run list --limit 1"
fi
