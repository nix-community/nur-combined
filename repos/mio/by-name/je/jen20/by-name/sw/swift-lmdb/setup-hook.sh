devendorSwiftLMDB() {
    if [ -L Packages ]; then
        local packagesPath=$(readlink Packages)
        rm Packages
        cp -r "$packagesPath" Packages
    fi

    chmod -R u+w Packages/swift-lmdb

    patch -d Packages/swift-lmdb -p1 < @devendorPatch@
    substituteInPlace Packages/swift-lmdb/Sources/CLMDB/module.modulemap \
        --replace-fail 'header "' 'header "@lmdbInclude@/include/'
}

postPatchHooks+=(devendorSwiftLMDB)
