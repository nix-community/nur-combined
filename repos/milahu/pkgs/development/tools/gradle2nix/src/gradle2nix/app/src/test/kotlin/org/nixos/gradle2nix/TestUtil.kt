package org.nixos.gradle2nix

import com.github.ajalt.clikt.core.main
import io.kotest.assertions.fail
import io.kotest.common.ExperimentalKotest
import io.kotest.common.KotestInternal
import io.kotest.core.extensions.MountableExtension
import io.kotest.core.listeners.AfterSpecListener
import io.kotest.core.names.TestName
import io.kotest.core.source.sourceRef
import io.kotest.core.spec.Spec
import io.kotest.core.test.NestedTest
import io.kotest.core.test.TestScope
import io.kotest.core.test.TestType
import io.kotest.matchers.file.shouldBeAFile
import io.kotest.matchers.shouldBe
import io.ktor.http.ContentType
import io.ktor.http.Url
import io.ktor.server.engine.embeddedServer
import io.ktor.server.http.content.staticFiles
import io.ktor.server.netty.Netty
import io.ktor.server.netty.NettyApplicationEngine
import io.ktor.server.routing.routing
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerializationException
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromStream
import kotlinx.serialization.json.encodeToStream
import java.io.File
import java.io.FileFilter
import java.nio.file.Files
import java.nio.file.Paths
import kotlin.random.Random

private val app = Gradle2Nix()

@OptIn(ExperimentalSerializationApi::class)
private val json =
    Json {
        prettyPrint = true
        prettyPrintIndent = "  "
    }

val testLogger = Logger(logLevel = LogLevel.DEBUG, stacktrace = true)

fun fixture(path: String): File = Paths.get("../fixtures", path).toFile()

@OptIn(ExperimentalKotest::class, ExperimentalSerializationApi::class, KotestInternal::class)
suspend fun TestScope.fixture(
    project: String,
    vararg args: String,
    test: suspend TestScope.(File, Env) -> Unit,
) {
    val tmp = Paths.get("build/tmp/gradle2nix").apply { toFile().mkdirs() }
    val baseDir = Paths.get("../fixtures/projects", project).toFile()
    val children =
        baseDir
            .listFiles(FileFilter { it.isDirectory && (it.name == "groovy" || it.name == "kotlin") })
            ?.toList()
    val cases =
        if (children.isNullOrEmpty()) {
            listOf(project to baseDir)
        } else {
            children.map { "$project.${it.name}" to it }
        }
    for (case in cases) {
        registerTestCase(
            NestedTest(
                name = TestName(case.first),
                disabled = false,
                config = null,
                type = TestType.Dynamic,
                source = sourceRef(),
            ) {
                var dirName = case.second.toString().replace("/", ".")
                while (dirName.startsWith(".")) dirName = dirName.removePrefix(".")
                while (dirName.endsWith(".")) dirName = dirName.removeSuffix(".")

                val tempDir = File(tmp.toFile(), dirName)
                tempDir.deleteRecursively()
                case.second.copyRecursively(tempDir)

                if (!tempDir.resolve("settings.gradle").exists() && !tempDir.resolve("settings.gradle.kts").exists()) {
                    Files.createFile(tempDir.resolve("settings.gradle").toPath())
                }
                app.main(
                    args.toList() +
                        listOf(
                            "-p",
                            tempDir.toString(),
                            "--log",
                            "debug",
                            "--stacktrace",
                            "--dump-events",
                            "--",
                            "-Dorg.nixos.gradle2nix.m2=$m2",
                            "--info",
                        ),
                )
                val file = tempDir.resolve(app.lockFile)
                file.shouldBeAFile()
                val env: Env =
                    file.inputStream().buffered().use { input ->
                        Json.decodeFromStream(input)
                    }
                test(tempDir, env)
            },
        )
    }
}

val updateGolden = System.getProperty("org.nixos.gradle2nix.update-golden") != null

@OptIn(ExperimentalSerializationApi::class)
suspend fun TestScope.golden(
    project: String,
    vararg args: String,
) {
    fixture(project, *args) { dir, env ->
        val filename = "${testCase.name.testName}.json"
        val goldenFile = File("../fixtures/golden/$filename")
        if (updateGolden) {
            goldenFile.parentFile.mkdirs()
            goldenFile.outputStream().buffered().use { output ->
                json.encodeToStream(env, output)
            }
        } else {
            if (!goldenFile.exists()) {
                fail("Golden file '$filename' doesn't exist. Run with --update-golden to generate.")
            }
            val goldenData =
                try {
                    goldenFile.readText()
                } catch (e: SerializationException) {
                    fail("Failed to load golden data from '$filename'. Run with --update-golden to regenerate.")
                }
            json.encodeToString(env) shouldBe goldenData
        }
    }
}

val m2: String = requireNotNull(System.getProperty("org.nixos.gradle2nix.m2"))

object MavenRepo : MountableExtension<MavenRepo.Config, NettyApplicationEngine>, AfterSpecListener {
    class Config {
        var repository: File = File("../fixtures/repositories/m2")
        var path: String = ""
        var port: Int? = null
        var host: String = DEFAULT_HOST
    }

    const val DEFAULT_HOST = "0.0.0.0"

    private val coroutineScope = CoroutineScope(Dispatchers.Default)
    private var server: NettyApplicationEngine? = null
    private val config = Config()

    init {
        require(config.repository.exists()) {
            "test repository doesn't exist: ${config.repository}"
        }
        val m2Url = Url(m2)
        config.path = m2Url.encodedPath
        config.host = m2Url.host
        config.port = m2Url.port
    }

    override fun mount(configure: Config.() -> Unit): NettyApplicationEngine {
        config.configure()
        // try 3 times to find a port if random
        return tryStart(3).also { this.server = it }
    }

    private fun tryStart(attempts: Int): NettyApplicationEngine =
        try {
            val p = config.port ?: Random.nextInt(10000, 65000)
            val s =
                embeddedServer(Netty, port = p, host = config.host) {
                    routing {
                        staticFiles(
                            remotePath = config.path,
                            dir = config.repository,
                            index = null,
                        ) {
                            enableAutoHeadResponse()
                            contentType { path ->
                                when (path.extension) {
                                    "pom", "xml" -> ContentType.Text.Xml
                                    "jar" -> ContentType("application", "java-archive")
                                    else -> ContentType.Text.Plain
                                }
                            }
                        }
                    }
                }
            coroutineScope.launch { s.start(wait = true) }
            s.engine
        } catch (e: Throwable) {
            if (config.port == null && attempts > 0) tryStart(attempts - 1) else throw e
        }

    override suspend fun afterSpec(spec: Spec) {
        server?.stop()
    }
}
