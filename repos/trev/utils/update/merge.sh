#!/usr/bin/env bash

readarray -t branches < <(git for-each-ref --format='%(refname:strip=4)' "refs/remotes/origin/update")
declare -A updates

for branch in "${branches[@]}"; do
    if [[ "${branch}" != *"/"* ]]; then
        continue
    fi

    system=$(echo "${branch}" | cut -d "/" -f 1)
    package=$(echo "${branch}" | cut -d "/" -f 2)

    if [[ -v updates["${package}"] ]]; then
        updates["${package}"]="${updates["${package}"]},${system}"
    else
        updates["${package}"]="${system}"
    fi
done

for package in "${!updates[@]}"; do
    echo "::group::Updating ${package}"
    git checkout -B "update/${package}"

    IFS="," read -r -a systems <<< "${updates["${package}"]}"

    echo "Getting pr"
    pr="$(gh pr list --head "update/${package}" --state open --json number --jq '.[].number')"
    if [[ -n "${pr}" ]]; then
        gh pr merge "${pr}" --disable-auto
    fi

    echo "Getting commit message"
    subject=$(git show -s --format=%s "origin/update/${systems[0]}/${package}")
    body=$(git show -s --format=%b "origin/update/${systems[0]}/${package}")
    version=${subject##* }

    echo "Merging changes"
    for system in "${systems[@]}"; do
        git merge -X ours "origin/update/${system}/${package}"
    done

    echo "Pushing changes"
    git push --force origin "update/${package}"

    if [[ -n "${pr}" ]]; then
        echo "Editing pr"
        gh pr edit "${pr}" \
            --title "chore(deps): update ${package} to v${version}" \
            --body "${body}"
    else
        echo "Creating pr"
        pr=$(
            gh pr create \
                --title "chore(deps): update ${package} to v${version}" \
                --body "${body}" \
                --head "update/${package}" \
                --base main
        )
    fi

    echo "Merging pr"
    gh pr merge "${pr}" \
        --auto \
        --delete-branch \
        --squash \
        --subject "chore(deps): update ${package} to v${version}" \
        --body "${body}"

    echo "Pruning branches"
    for system in "${systems[@]}"; do
        git push origin --delete "update/${system}/${package}"
    done

    git checkout main
    echo "::endgroup::"
done
