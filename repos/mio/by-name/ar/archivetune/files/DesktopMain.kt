package moe.rukamori.archivetune

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.key.Key
import androidx.compose.ui.input.key.KeyEventType
import androidx.compose.ui.input.key.isCtrlPressed
import androidx.compose.ui.input.key.isMetaPressed
import androidx.compose.ui.input.key.key
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.input.key.type
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import androidx.compose.ui.window.rememberWindowState
import androidx.compose.ui.zIndex
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import moe.rukamori.archivetune.constants.DarkModeKey
import moe.rukamori.archivetune.constants.PureBlackKey
import moe.rukamori.archivetune.ui.component.BottomSheetMenu
import moe.rukamori.archivetune.ui.component.BottomSheetPage
import moe.rukamori.archivetune.ui.component.BottomSheetPageState
import moe.rukamori.archivetune.ui.component.LocalBottomSheetPageState
import moe.rukamori.archivetune.ui.component.LocalMenuState
import moe.rukamori.archivetune.ui.component.MenuState
import moe.rukamori.archivetune.ui.component.rememberBottomSheetState
import moe.rukamori.archivetune.ui.player.BottomSheetPlayer
import moe.rukamori.archivetune.ui.screens.ExploreScreen
import moe.rukamori.archivetune.ui.screens.Screens
import moe.rukamori.archivetune.ui.screens.navigationBuilder
import moe.rukamori.archivetune.ui.screens.search.OnlineSearchScreen
import moe.rukamori.archivetune.ui.screens.search.onlineSearchResultRoute
import moe.rukamori.archivetune.ui.screens.settings.DarkMode
import moe.rukamori.archivetune.ui.theme.ArchiveTuneTheme
import moe.rukamori.archivetune.utils.rememberEnumPreference
import moe.rukamori.archivetune.utils.rememberPreference
import moe.rukamori.archivetune.viewmodels.HomeViewModel
import androidx.datastore.preferences.DesktopPreferenceStore
import moe.rukamori.archivetune.constants.*
import moe.rukamori.archivetune.innertube.YouTube
import moe.rukamori.archivetune.innertube.models.YouTubeLocale
import moe.rukamori.archivetune.paxsenix.PaxsenixLyrics
import java.util.Locale

fun main() {
    PaxsenixLyrics.setUserAgent("ArchiveTune", BuildConfig.VERSION_NAME)

    val defLocale = Locale.getDefault()
    val languageTag = defLocale.toLanguageTag().replace("-Hant", "")
    val defaultGl = defLocale.country.takeIf { it in CountryCodeToName } ?: "US"
    val defaultHl = defLocale.language.takeIf { it in LanguageCodeToName }
        ?: languageTag.takeIf { it in LanguageCodeToName }
        ?: "en"

    val prefs = DesktopPreferenceStore.currentPreferences
    val savedGl = prefs[ContentCountryKey]?.takeIf { it != SYSTEM_DEFAULT }
    val savedHl = prefs[ContentLanguageKey]?.takeIf { it != SYSTEM_DEFAULT }

    YouTube.locale = YouTubeLocale(
        gl = savedGl ?: defaultGl,
        hl = savedHl ?: defaultHl,
    )

    if (prefs[UseLoginForBrowse] != false) {
        YouTube.useLoginForBrowse = true
    }

    application {
        val playerConnection = getGlobalPlayerConnection()
        val mediaMetadata by playerConnection?.mediaMetadata?.collectAsState() ?: remember { mutableStateOf(null) }
        val isPlayerActive = playerConnection != null && mediaMetadata != null

        val windowTitle = remember(mediaMetadata) {
            val meta = mediaMetadata
            if (meta != null) {
                val artist = meta.artists.joinToString(", ") { it.name }.takeIf { it.isNotBlank() }
                if (artist != null) "${meta.title} • $artist — ArchiveTune" else "${meta.title} — ArchiveTune"
            } else {
                "ArchiveTune"
            }
        }

        var isSearchActive by remember { mutableStateOf(false) }

        Window(
            onCloseRequest = ::exitApplication,
            title = windowTitle,
            icon = painterResource("mipmap-xxxhdpi/ic_launcher.png"),
            state = rememberWindowState(width = 1200.dp, height = 800.dp)
        ) {
            val darkTheme by rememberEnumPreference(DarkModeKey, defaultValue = DarkMode.AUTO)
            val pureBlackEnabled by rememberPreference(PureBlackKey, defaultValue = false)
            val isSystemInDarkTheme = isSystemInDarkTheme()
            val useDarkTheme = remember(darkTheme, isSystemInDarkTheme) {
                if (darkTheme == DarkMode.AUTO) isSystemInDarkTheme else darkTheme == DarkMode.ON
            }
            val pureBlack = pureBlackEnabled && useDarkTheme

            val navController = rememberNavController()
            val currentBackStackEntry by navController.currentBackStackEntryAsState()
            val currentRoute = currentBackStackEntry?.destination?.route ?: Screens.Home.route

            val items = listOf("Home", "Search", "Explore", "Library", "History", "Settings")
            val icons: List<@Composable () -> Unit> = listOf(
                { Icon(Icons.Filled.Home, contentDescription = "Home") },
                { Icon(Icons.Filled.Search, contentDescription = "Search") },
                { Icon(Icons.Filled.Star, contentDescription = "Explore") },
                { Icon(Icons.Filled.List, contentDescription = "Library") },
                { Icon(painterResource(R.drawable.history), contentDescription = "History") },
                { Icon(Icons.Filled.Settings, contentDescription = "Settings") },
            )
            val tabRoutes = listOf(Screens.Home.route, Screens.Search.route, "explore", Screens.Library.route, "history", "settings")

            val selectedItem = when {
                currentRoute == Screens.Search.route || currentRoute.startsWith("search/") || isSearchActive -> 1
                currentRoute == "explore" || currentRoute == Screens.MoodAndGenres.route || currentRoute == "new_release" || currentRoute == "charts_screen" -> 2
                currentRoute == Screens.Library.route ||
                    currentRoute.startsWith("album/") ||
                    currentRoute.startsWith("artist/") ||
                    currentRoute.startsWith("playlist/") ||
                    currentRoute.startsWith("auto_playlist/") ||
                    currentRoute.startsWith("local_playlist/") ||
                    currentRoute.startsWith("online_playlist/") ||
                    currentRoute.startsWith("spotify_playlist/") ||
                    currentRoute == "local_songs" ||
                    currentRoute == "stats" -> 3
                currentRoute == "history" -> 4
                currentRoute == "settings" || currentRoute.startsWith("settings/") || currentRoute == "account" || currentRoute.startsWith("login") -> 5
                currentRoute == Screens.Home.route || currentRoute == "news" || currentRoute.startsWith("view_news") || currentRoute.startsWith("year_in_music") -> 0
                else -> -1
            }

            val homeScrollBehavior = TopAppBarDefaults.enterAlwaysScrollBehavior()
            val libraryScrollBehavior = TopAppBarDefaults.enterAlwaysScrollBehavior()
            val homeViewModel: HomeViewModel = androidx.hilt.navigation.compose.hiltViewModel()

            val menuState = remember { MenuState() }
            val bottomSheetPageState = remember { BottomSheetPageState() }

            val navBarHeight = 80.dp
            val miniPlayerHeight = 70.dp
            val collapsedHeight = navBarHeight + miniPlayerHeight

        BoxWithConstraints(
            modifier = Modifier.fillMaxSize()
        ) {
            val playerBottomSheetState = rememberBottomSheetState(
                dismissedBound = 0.dp,
                collapsedBound = collapsedHeight,
                expandedBound = maxHeight,
            )

            LaunchedEffect(mediaMetadata) {
                if (mediaMetadata != null && playerBottomSheetState.isDismissed) {
                    playerBottomSheetState.collapseSoft()
                } else if (mediaMetadata == null && !playerBottomSheetState.isDismissed) {
                    playerBottomSheetState.dismiss()
                }
            }

            var searchQuery by remember { mutableStateOf("") }
            val searchFocusRequester = remember { FocusRequester() }

            LaunchedEffect(isSearchActive) {
                if (isSearchActive) {
                    searchFocusRequester.requestFocus()
                }
            }

            val openSearchRequested by currentBackStackEntry?.savedStateHandle?.getStateFlow("openSearch", false)?.collectAsState() ?: remember { mutableStateOf(false) }
            LaunchedEffect(openSearchRequested) {
                if (openSearchRequested) {
                    isSearchActive = true
                    currentBackStackEntry?.savedStateHandle?.set("openSearch", false)
                }
            }

            val playerAwareBottomPadding = navBarHeight + (if (isPlayerActive && !playerBottomSheetState.isDismissed) miniPlayerHeight else 0.dp)

            CompositionLocalProvider(
                LocalPlayerConnection provides playerConnection,
                LocalDatabase provides (androidx.hilt.navigation.compose.getGlobalMusicDatabase() as moe.rukamori.archivetune.db.MusicDatabase),
                LocalPlayerAwareWindowInsets provides androidx.compose.foundation.layout.WindowInsets(bottom = playerAwareBottomPadding),
                LocalDownloadUtil provides getGlobalDownloadUtil(),
                LocalSyncUtils provides getGlobalSyncUtils(),
                LocalMenuState provides menuState,
                LocalBottomSheetPageState provides bottomSheetPageState,
            ) {
                ArchiveTuneTheme(
                    darkTheme = useDarkTheme,
                    pureBlack = pureBlack,
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .onKeyEvent { keyEvent ->
                                if (keyEvent.type == KeyEventType.KeyDown) {
                                    if ((keyEvent.isCtrlPressed || keyEvent.isMetaPressed) && (keyEvent.key == Key.F || keyEvent.key == Key.K)) {
                                        isSearchActive = true
                                        true
                                    } else when (keyEvent.key) {
                                        Key.Escape -> {
                                            if (androidx.activity.compose.BackDispatcher.handleBack()) {
                                                true
                                            } else if (isSearchActive) {
                                                isSearchActive = false
                                                true
                                            } else if (bottomSheetPageState.isVisible) {
                                                bottomSheetPageState.dismiss()
                                                true
                                            } else if (menuState.isVisible) {
                                                menuState.dismiss()
                                                true
                                            } else if (playerBottomSheetState.isExpanded) {
                                                playerBottomSheetState.collapseSoft()
                                                true
                                            } else if (navController.previousBackStackEntry != null) {
                                                navController.popBackStack()
                                                true
                                            } else {
                                                false
                                            }
                                        }
                                        Key.MediaPlayPause -> {
                                            playerConnection?.player?.togglePlayPause()
                                            true
                                        }
                                        Key.MediaPlay -> {
                                            playerConnection?.player?.play()
                                            true
                                        }
                                        Key.MediaPause -> {
                                            playerConnection?.player?.pause()
                                            true
                                        }
                                        Key.MediaNext, Key.MediaSkipForward -> {
                                            playerConnection?.player?.seekToNext()
                                            true
                                        }
                                        Key.MediaPrevious, Key.MediaSkipBackward -> {
                                            playerConnection?.player?.seekToPrevious()
                                            true
                                        }
                                        Key.MediaStop -> {
                                            playerConnection?.player?.stop()
                                            true
                                        }
                                        else -> false
                                    }
                                } else {
                                    false
                                }
                            }
                    ) {
                        NavHost(
                            navController = navController,
                            startDestination = Screens.Home.route,
                            modifier = Modifier.fillMaxSize()
                        ) {
                            navigationBuilder(
                                navController = navController,
                                scrollBehavior = homeScrollBehavior,
                                homeViewModel = homeViewModel,
                                latestVersionName = { "" },
                                libraryScrollBehavior = libraryScrollBehavior,
                            )
                            composable("explore") {
                                ExploreScreen(navController)
                            }
                        }

                        if (playerConnection != null) {
                            BottomSheetPlayer(
                                state = playerBottomSheetState,
                                navController = navController,
                                pureBlack = pureBlack,
                            )

                            if (playerBottomSheetState.progress > 0.05f && !isSearchActive) {
                                val returnAlpha = ((playerBottomSheetState.progress - 0.05f) / 0.95f).coerceIn(0f, 1f)
                                FilledTonalIconButton(
                                    onClick = { playerBottomSheetState.collapseSoft() },
                                    enabled = playerBottomSheetState.progress >= 0.5f,
                                    modifier = Modifier
                                        .align(Alignment.TopStart)
                                        .padding(top = 16.dp, start = 16.dp)
                                        .graphicsLayer { alpha = returnAlpha }
                                        .zIndex(20f),
                                    colors = IconButtonDefaults.filledTonalIconButtonColors(
                                        containerColor = (if (pureBlack) Color(0xFF1E1E1E) else MaterialTheme.colorScheme.surfaceContainerHigh).copy(alpha = 0.85f),
                                        contentColor = MaterialTheme.colorScheme.onSurface,
                                    ),
                                ) {
                                    Icon(
                                        imageVector = Icons.Filled.ArrowBack,
                                        contentDescription = "Return to main screen",
                                    )
                                }
                            }
                        }

                        val navSlideDistance = navBarHeight
                        val navSlideOffset = navSlideDistance * playerBottomSheetState.progress.coerceIn(0f, 1f)

                        NavigationBar(
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .offset { IntOffset(0, navSlideOffset.roundToPx()) }
                        ) {
                            items.forEachIndexed { index, item ->
                                NavigationBarItem(
                                    icon = icons[index],
                                    label = { Text(item) },
                                    selected = selectedItem == index,
                                    onClick = {
                                        val targetRoute = tabRoutes[index]
                                        if (currentRoute != targetRoute) {
                                            navController.navigate(targetRoute) {
                                                popUpTo(Screens.Home.route) {
                                                    saveState = true
                                                }
                                                launchSingleTop = true
                                                restoreState = true
                                            }
                                        } else if (targetRoute == Screens.Search.route) {
                                            isSearchActive = true
                                        }
                                    }
                                )
                            }
                        }

                        if (isSearchActive) {
                            Surface(
                                modifier = Modifier.fillMaxSize().zIndex(5f),
                                color = if (pureBlack) Color.Black else MaterialTheme.colorScheme.surface,
                            ) {
                                Column(modifier = Modifier.fillMaxSize()) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth().padding(12.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        IconButton(onClick = { isSearchActive = false }) {
                                            Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
                                        }
                                        OutlinedTextField(
                                            value = searchQuery,
                                            onValueChange = { searchQuery = it },
                                            modifier = Modifier
                                                .weight(1f)
                                                .padding(horizontal = 8.dp)
                                                .focusRequester(searchFocusRequester)
                                                .onKeyEvent { keyEvent ->
                                                    if (keyEvent.type == KeyEventType.KeyDown && (keyEvent.key == Key.Enter || keyEvent.key == Key.NumPadEnter)) {
                                                        if (searchQuery.isNotBlank()) {
                                                            isSearchActive = false
                                                            navController.navigate(onlineSearchResultRoute(searchQuery))
                                                            true
                                                        } else false
                                                    } else false
                                                },
                                            placeholder = { Text("Search songs, albums, artists...") },
                                            singleLine = true,
                                            keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                                            keyboardActions = KeyboardActions(
                                                onSearch = {
                                                    if (searchQuery.isNotBlank()) {
                                                        isSearchActive = false
                                                        navController.navigate(onlineSearchResultRoute(searchQuery))
                                                    }
                                                }
                                            ),
                                            trailingIcon = {
                                                if (searchQuery.isNotEmpty()) {
                                                    IconButton(onClick = { searchQuery = "" }) {
                                                        Icon(Icons.Filled.Clear, contentDescription = "Clear")
                                                    }
                                                }
                                            }
                                        )
                                        Button(
                                            onClick = {
                                                if (searchQuery.isNotBlank()) {
                                                    isSearchActive = false
                                                    navController.navigate(onlineSearchResultRoute(searchQuery))
                                                }
                                            }
                                        ) {
                                            Text("Search")
                                        }
                                    }
                                    OnlineSearchScreen(
                                        query = searchQuery,
                                        onQueryChange = { searchQuery = it.text },
                                        navController = navController,
                                        onSearch = { text ->
                                            if (text.isNotBlank()) {
                                                isSearchActive = false
                                                navController.navigate(onlineSearchResultRoute(text))
                                            }
                                        },
                                        onDismiss = { isSearchActive = false },
                                        pureBlack = pureBlack,
                                    )
                                }
                            }
                        }

                        BottomSheetMenu(
                            state = menuState,
                            modifier = Modifier.align(Alignment.BottomCenter),
                        )

                        BottomSheetPage(
                            state = bottomSheetPageState,
                            modifier = Modifier.align(Alignment.BottomCenter),
                        )
                    }
                }
            }
        }
    }
}
}
