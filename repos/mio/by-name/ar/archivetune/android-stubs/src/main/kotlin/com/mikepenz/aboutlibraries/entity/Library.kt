package com.mikepenz.aboutlibraries.entity


open class Library {
    val name: String = ""
    val uniqueId: String = ""
    val artifactVersion: String? = null
    val licenses: Set<License> = emptySet()
}
open class License {
    val name: String = ""
}

