val scala3Version = "3.2.1"

lazy val root = project
  .in(file("."))
  .settings(
    name := "Nix Flake Template",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    libraryDependencies += "org.scalameta" %% "munit" % "0.7.29" % Test
  )

// avoid generating docs
Compile / doc / sources                := Nil
Compile / packageDoc / publishArtifact := false

enablePlugins(JavaAppPackaging)
