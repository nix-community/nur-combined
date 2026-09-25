package com.mikepenz.aboutlibraries


import com.mikepenz.aboutlibraries.entity.Library
open class Libs {
    open class Builder {
        fun withContext(context: android.content.Context) = this
        fun build(): Libs = Libs()
    }
    val libraries: List<Library> = emptyList()
}

