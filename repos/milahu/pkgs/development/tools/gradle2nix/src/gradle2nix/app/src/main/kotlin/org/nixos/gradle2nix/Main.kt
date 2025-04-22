package org.nixos.gradle2nix

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.context
import com.github.ajalt.clikt.core.main
import com.github.ajalt.clikt.output.MordantHelpFormatter
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.ajalt.clikt.parameters.arguments.multiple
import com.github.ajalt.clikt.parameters.groups.default
import com.github.ajalt.clikt.parameters.groups.mutuallyExclusiveOptions
import com.github.ajalt.clikt.parameters.groups.single
import com.github.ajalt.clikt.parameters.options.convert
import com.github.ajalt.clikt.parameters.options.default
import com.github.ajalt.clikt.parameters.options.defaultLazy
import com.github.ajalt.clikt.parameters.options.flag
import com.github.ajalt.clikt.parameters.options.option
import com.github.ajalt.clikt.parameters.options.split
import com.github.ajalt.clikt.parameters.types.enum
import com.github.ajalt.clikt.parameters.types.file
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.encodeToStream
import org.gradle.tooling.model.gradle.GradleBuild
import org.nixos.gradle2nix.model.ArtifactType
import org.nixos.gradle2nix.model.DependencySet
import org.nixos.gradle2nix.model.RESOLVE_ALL_TASK
import java.io.File
import java.net.URI

data class Config(
    val appHome: File,
    val gradleHome: File,
    val gradleSource: GradleSource,
    val gradleJdk: File?,
    val gradleArgs: List<String>,
    val outDir: File,
    val projectDir: File,
    val tasks: List<String>,
    val artifacts: List<ArtifactType>,
    val logger: Logger,
    val dumpEvents: Boolean,
)

@OptIn(ExperimentalSerializationApi::class)
val JsonFormat =
    Json {
        ignoreUnknownKeys = true
        prettyPrint = true
        prettyPrintIndent = "  "
    }

sealed interface GradleSource {
    data class Distribution(
        val uri: URI,
    ) : GradleSource

    data class Path(
        val path: File,
    ) : GradleSource

    data object Project : GradleSource

    data class Wrapper(
        val version: String,
    ) : GradleSource
}

enum class LogLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR,
}

class Gradle2Nix :
    CliktCommand(
        name = "gradle2nix",
    ) {
    private val tasks: List<String> by option(
        "--task",
        "-t",
        metavar = "TASK",
        help = "Gradle tasks to run",
    ).split(",").default(listOf(RESOLVE_ALL_TASK))

    private val artifacts: List<ArtifactType> by option(
        "--artifacts",
        "-a",
        metavar = "ARTIFACTS",
        help = "Comma-separated list of artifacts to download",
        helpTags = mapOf("artifacts" to "doxygen,javadoc,samples,sources,usermanual"),
    ).enum<ArtifactType>(key = { it.name.lowercase() }).split(",").default(emptyList())

    private val projectDir: File by option(
        "--project",
        "-p",
        help = "Path to the project root",
    ).file(
        mustExist = true,
        mustBeReadable = true,
        canBeFile = false,
    ).convert { file ->
        getProjectRoot(file) ?: fail("Could not locate project root in \"$file\" or its parents.")
    }.defaultLazy("Current directory") {
        File(".")
    }

    private val outDir: File? by option(
        "--out-dir",
        "-o",
        metavar = "DIR",
        help = "Path to write generated files",
    ).file(canBeFile = false, canBeDir = true)
        .defaultLazy("<project>") { projectDir }

    internal val lockFile: String by option(
        "--lock-file",
        "-l",
        metavar = "FILENAME",
        help = "Name of the generated lock file",
    ).default("gradle.lock")

    private val gradleSource: GradleSource by mutuallyExclusiveOptions(
        option(
            "--gradle-dist",
            metavar = "URI",
            help = "Gradle distribution URI",
        ).convert { GradleSource.Distribution(URI(it)) },
        option(
            "--gradle-home",
            metavar = "DIR",
            help = "Gradle home path (e.g. \\`nix eval --raw nixpkgs#gradle.outPath\\`/lib/gradle)",
        ).file(mustExist = true, canBeFile = false).convert { GradleSource.Path(it) },
        option(
            "--gradle-wrapper",
            help = "Gradle wrapper version",
        ).convert { GradleSource.Wrapper(it) },
        name = "Gradle installation",
        help = "Where to find Gradle. By default, use the project's wrapper.",
    ).single().default(GradleSource.Project)

    private val gradleJdk: File? by option(
        "--gradle-jdk",
        "-j",
        metavar = "DIR",
        help = "JDK home to use for launching Gradle (e.g. \\`nix eval --raw nixpkgs#openjdk.home\\`)",
    ).file(canBeFile = false, canBeDir = true)

    private val logLevel: LogLevel by option(
        "--log",
        help = "Print messages with this priority or higher",
    ).enum<LogLevel>(key = { it.name.lowercase() })
        .default(LogLevel.INFO, "info")

    private val dumpEvents: Boolean by option(
        "--dump-events",
        help = "Dump Gradle event logs to the output directory",
    ).flag()

    private val stacktrace: Boolean by option(
        "--stacktrace",
        help = "Print a stack trace on error",
    ).flag()

    private val gradleArgs: List<String> by argument(
        name = "ARGS",
        help = "Extra arguments to pass to Gradle",
    ).multiple()

    init {
        context {
            helpFormatter = { MordantHelpFormatter(it, showDefaultValues = true) }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    override fun run() {
        val logger = Logger(logLevel = logLevel, stacktrace = stacktrace)

        val appHome =
            System.getProperty("org.nixos.gradle2nix.share")?.let(::File)
                ?: error("Could not locate the /share directory in the gradle2nix installation: ${System.getenv("APP_HOME")}")
        logger.debug("appHome=$appHome")
        val gradleHome =
            System.getenv("GRADLE_USER_HOME")?.let(::File) ?: File("${System.getProperty("user.home")}/.gradle")
        logger.debug("gradleHome=$gradleHome")
        val config =
            Config(
                appHome,
                gradleHome,
                gradleSource,
                gradleJdk,
                gradleArgs,
                outDir ?: projectDir,
                projectDir,
                tasks,
                artifacts,
                logger,
                dumpEvents,
            )

        val buildSrcs =
            connect(config).use { connection ->
                val root = runBlocking { connection.buildModel() }
                val builds: List<GradleBuild> =
                    buildList {
                        add(root)
                        addAll(root.editableBuilds)
                    }
                builds.mapNotNull { build ->
                    build.rootProject.projectDirectory
                        .resolve("buildSrc")
                        .takeIf { it.exists() }
                }
            }

        val dependencySets = mutableListOf<DependencySet>()

        connect(config).use { connection ->
            dependencySets.add(runBlocking { connection.build("project", config) })
        }

        for (buildSrc in buildSrcs) {
            connect(config, buildSrc).use { connection ->
                dependencySets.add(
                    runBlocking {
                        connection.build(
                            buildSrc.toRelativeString(projectDir.absoluteFile).replace('/', '_'),
                            config,
                            listOf(RESOLVE_ALL_TASK),
                        )
                    },
                )
            }
        }

        val env =
            try {
                processDependencies(config, dependencySets)
            } catch (e: Throwable) {
                logger.error("Dependency parsing failed", e)
            }

        config.outDir.mkdirs()

        val outLockFile = config.outDir.resolve(lockFile)
        logger.info("Writing lock file to $outLockFile")
        outLockFile.outputStream().buffered().use { output ->
            JsonFormat.encodeToStream(env, output)
        }
    }
}

fun main(args: Array<String>) {
    Gradle2Nix().main(args)
}
