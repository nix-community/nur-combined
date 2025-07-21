bold=$(tput bold)
normal=$(tput sgr0)
git_branch=$(git rev-parse --abbrev-ref HEAD)
git_root=$(git rev-parse --show-toplevel)
git_version=$(git describe --tags --abbrev=0)
version=${git_version#v}

major=$(echo "${version}" | cut -d . -f1)
minor=$(echo "${version}" | cut -d . -f2)
patch=$(echo "${version}" | cut -d . -f3)
case "${1-patch}" in
    major) major=$((major + 1)) ;;
    minor) minor=$((minor + 1)) ;;
    patch) patch=$((patch + 1)) ;;
    *) echo "usage: bumper (major | minor | patch)" && exit ;;
esac
next_version="${major}.${minor}.${patch}"

echo "${version} -> ${next_version}"

echo "stashing changes"
git stash push

if [ -f package.json ]; then
    echo "bumping package.json"
    cd "${git_root}"
    npm version "${next_version}" --no-git-tag-version
    git add package.json
    git add package-lock.json
fi

if [ -f flake.nix ]; then
    echo "bumping flake.nix"
    cd "${git_root}"
    nix-update --flake --version "${next_version}" default
    git add flake.nix
fi

if [ -f openapi.yaml ]; then
    echo "bumping openapi"
    cd "${git_root}"
    sed -i -e "s/${version}/${next_version}/g" openapi.yaml
    git add openapi.yaml
fi

echo "committing"
git commit -m "bump: v${version} -> v${next_version}"
git tag -a "v${next_version}" -m "bump: v${version} -> v${next_version}"

echo "unstashing changes"
git stash pop || true

echo
echo "bump successful, please push:"
echo "${bold}git push --atomic origin ${git_branch} v${next_version}${normal}"
wl-copy "git push --atomic origin ${git_branch} v${next_version}" || true
echo