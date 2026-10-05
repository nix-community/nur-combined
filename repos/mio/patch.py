with open('scratch/ArchiveTune-patched/app/build.gradle.kts', 'r') as f:
    content = f.read()

content = content.replace(
    '    implementation(project(":core"))\n    implementation(project(":lyrics:kugou"))',
    '    implementation(project(":core"))\n    implementation(project(":lastfm"))\n    implementation(project(":lyrics:kugou"))'
)

with open('scratch/ArchiveTune-patched/app/build.gradle.kts', 'w') as f:
    f.write(content)
