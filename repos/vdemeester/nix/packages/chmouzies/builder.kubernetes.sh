source $stdenv/setup

BINARIES="tktl ocla kcl kselect expose-openshift-registry-for-ko.sh decode-kubernetes-secrets.py"

mkdir -p $out/bin
for b in ${BINARIES}; do
    cp $src/kubernetes/${b} $out/bin/
done
