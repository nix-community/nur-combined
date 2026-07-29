import json
with open('by-name/je/jetbrains_idea-oss/idea_maven_artefacts.json', 'r') as f:
    data = json.load(f)

for item in data:
    if item['url'] == 'org/jetbrains/kotlin/kotlin-dist-for-ide/2.3.20/kotlin-dist-for-ide-2.3.20.jar':
        item['url'] = 'org/jetbrains/kotlin/kotlin-dist-for-ide/2.4.0/kotlin-dist-for-ide-2.4.0.jar'
        item['hash'] = 'd12b996e50fe7b245a0a5045bac8c0bd5cbc227a792e44b41b0ae80e042c8490'
        item['path'] = 'org/jetbrains/kotlin/kotlin-dist-for-ide/2.4.0/kotlin-dist-for-ide-2.4.0.jar'
    elif item['url'] == 'org/jetbrains/kotlin/kotlin-jps-plugin-classpath/2.3.20/kotlin-jps-plugin-classpath-2.3.20.jar':
        item['url'] = 'org/jetbrains/kotlin/kotlin-jps-plugin-classpath/2.4.0/kotlin-jps-plugin-classpath-2.4.0.jar'
        item['hash'] = '80d785cfe4309db0246069b3313d11a119fe8ee38bd8b102bd8bb4978a1c61be'
        item['path'] = 'org/jetbrains/kotlin/kotlin-jps-plugin-classpath/2.4.0/kotlin-jps-plugin-classpath-2.4.0.jar'
    elif item['url'] == 'org/jetbrains/kotlin/kotlin-jps-plugin-tests-for-ide/2.3.20/kotlin-jps-plugin-tests-for-ide-2.3.20.jar':
        item['url'] = 'org/jetbrains/kotlin/kotlin-jps-plugin-tests-for-ide/2.4.0/kotlin-jps-plugin-tests-for-ide-2.4.0.jar'
        item['hash'] = 'fb292f37213201021a9c2ff5c4ea96a45796ce049d0974b78fdfe547810e0c68'
        item['path'] = 'org/jetbrains/kotlin/kotlin-jps-plugin-tests-for-ide/2.4.0/kotlin-jps-plugin-tests-for-ide-2.4.0.jar'

with open('by-name/je/jetbrains_idea-oss/idea_maven_artefacts.json', 'w') as f:
    json.dump(data, f, indent=4)
