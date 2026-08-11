package com.example

import org.gradle.api.Plugin
import org.gradle.api.Project

open class ApplyPluginPublishPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        project.pluginManager.apply("com.gradle.plugin-publish")
    }
}
