import sys

path = 'app/src/main/kotlin/moe/rukamori/archivetune/utils/potoken/BotGuardTokenGenerator.kt'
content = open(path).read()

html_block = """                val html =
                    withContext(Dispatchers.IO) {
                        webView.context.assets
                            .open("po_token.html")
                            .bufferedReader()
                            .use { it.readText() }
                    }"""
content = content.replace(html_block, '                val html = ""\n')

js_block = """                            webView.context.assets
                                .open("botguard.js")
                                .bufferedReader()
                                .use { it.readText() }"""
content = content.replace(js_block, '                            ""\n')

content = content.replace('wv.post(engine::close)', 'engine.close()')
open(path, 'w').write(content)
