source "$stdenv"/setup

cp -r "$src" ./

chmod --recursive u=rwx ./"$(basename "$src")"

cd ./"$(basename "$src")"

./configure

make

mkdir --parents "$out"/bin

cp ./src/pngloss "$out"/bin

