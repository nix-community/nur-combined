import sys

content = open(sys.argv[1]).read()
target = """        val jpsBuild = Standalone.runBuild(
          { jpsLoggerFactory.createLog(it) },
          context.options.resolveInJpsBuild,
          messages,
          emptyList(),
          buildOptions,
          isMake = false
        )"""

replacement = """        val jpsBuild = try {
          Standalone.runBuild(
            { jpsLoggerFactory.createLog(it) },
            context.options.resolveInJpsBuild,
            messages,
            emptyList(),
            buildOptions,
            isMake = false
          )
        } catch (e: Throwable) {
          println("FATAL JPS ERROR: " + e.message)
          e.printStackTrace()
          try {
            val clazz = Class.forName("com.intellij.util.JavaVersionShimKt")
            println("JavaVersionShimKt loaded from: " + clazz.protectionDomain.codeSource.location)
          } catch (e2: Throwable) {
            println("Failed to get JavaVersionShimKt location")
          }
          throw e
        }"""

with open(sys.argv[1], "w") as f:
    f.write(content.replace(target, replacement).replace("throw NotImplementedError(\"Run build via Jps compilation is disabled\")", "// throw NotImplementedError(\"Run build via Jps compilation is disabled\")"))
