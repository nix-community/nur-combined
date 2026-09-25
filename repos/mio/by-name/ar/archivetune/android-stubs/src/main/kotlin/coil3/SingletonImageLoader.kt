package coil3


object SingletonImageLoader {
    interface Factory {
        fun newImageLoader(context: PlatformContext): coil3.ImageLoader
    }
    fun setSafe(factory: Factory) {}
}

