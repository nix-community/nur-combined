major () {
    tuple=(${1//./ })
    echo "${tuple[0]}"
}

minor () {
    tuple=(${1//./ })
    echo "${tuple[1]}"
}

patch_version () {
    offset_regex='add_canonic_versions\((?:\s*"(?:[0-9\.A-Za-z\+]+\s?)+")+\K,(?=\s*"[0-9\.A-Za-z\+]+",?\s*\))'
    match_regex='add_canonic_versions\((?:\s*"(?:[0-9\.A-Za-z\+]+\s?)+")+,\s*"\K[0-9\.A-Za-z\+]+(?=",?\s*\))'

    offsets=($(pcregrep --file-offsets -M $offset_regex xdis/magics.py))
    versions=($(pcregrep -o -M $match_regex xdis/magics.py))

    target_version="$(major $1).$(minor $1)"

    for i in $(seq 1 ${#versions[@]}); do
        if [[ ${versions[i]} == ${target_version}* ]] && [[ ${versions[i]} != ${target_version}*pypy ]] && [[ ${versions[i]} != ${target_version}*Graal ]] then
            cp xdis/magics.py xdis/magics.py.bak
            offset=(${offsets[i]//,/ })
            offset=${offset[0]}
            { head -c $offset xdis/magics.py.bak; printf " \" ${1}\" "; tail -c "+$(expr $offset + 1)" xdis/magics.py.bak; } > xdis/magics.py
            rm xdis/magics.py.bak
            echo "added $1 to ${versions[i]}"
        fi
    done
}

while (( "$#" )); do
    patch_version "$1"
    shift
done

