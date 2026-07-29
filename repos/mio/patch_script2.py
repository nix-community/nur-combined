import sys

content = open(sys.argv[1]).read()
target = """        val jpsBuild = try {"""

replacement = """
          try {
            val clazz = Class.forName("com.intellij.util.JavaVersionShimKt")
            println("JavaVersionShimKt loaded from: " + clazz.protectionDomain.codeSource.location)
          } catch (e2: Throwable) {
            println("Failed to get JavaVersionShimKt location")
          }
        val jpsBuild = try {"""

with open(sys.argv[1], "w") as f:
    f.write(content.replace(target, replacement))
