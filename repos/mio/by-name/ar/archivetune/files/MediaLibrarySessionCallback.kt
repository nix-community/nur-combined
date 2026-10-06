package moe.rukamori.archivetune.playback

/*
 * Upstream's MediaLibrarySessionCallback serves the Android Auto / MediaBrowser
 * tree out of MusicService's MediaLibrarySession. There is no MediaLibrarySession
 * on the desktop port and MusicService is inert, so this type only needs to exist.
 */
class MediaLibrarySessionCallback
