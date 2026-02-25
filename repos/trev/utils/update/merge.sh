#!/usr/bin/env bash

readarray -t branches < <(git for-each-ref --format='%(refname:strip=4)' "refs/remotes/origin/update")
declare -A updates

for branch in "${branches[@]}"; do
    if [[ "${branch}" != *"/"* ]]; then
        continue
    fi

    system=$(echo "${branch}" | cut -d "/" -f 1)
    package=$(echo "${branch}" | cut -d "/" -f 2)
    updates["${package}"]+="${system}"
done

for package in "${!updates[@]}"; do
    systems="${updates["${package}"]}"

    echo "::group::updating ${package}"
    git checkout -B "update/${package}"

    echo "getting pr"
    pr_number="$(gh pr list --head "update/${package}" --state open --json number --jq '.[].number')"

    echo "getting commit message"
    subject=$(git show -s --format=%s "origin/update/${systems[0]}/${package}")
    body=$(git show -s --format=%b "origin/update/${systems[0]}/${package}")
    version=${subject##* }

    echo "merging changes"
    for system in "${systems[@]}"; do
        git merge -X ours --no-ff "origin/update/${system}/${package}"
    done

    echo "pushing changes"
    git push --force origin "update/${package}"

    if [[ -n "${pr_number}" ]]; then
        echo "editing pr"
        gh pr edit "${pr_number}" \
            --title "chore(deps): update ${package} to ${version}" \
            --body "${body}"
    else
        echo "creating pr"
        url=$(
            gh pr create \
                --title "chore(deps): update ${package} to ${version}" \
                --body "${body}" \
                --head "update/${package}" \
                --base main
        )
        gh pr merge --rebase --auto "${url}"
    fi

    echo "pruning branches"
    for system in "${systems[@]}"; do
        git push origin --delete "update/${system}/${package}"
    done

    echo "::endgroup::"
done
