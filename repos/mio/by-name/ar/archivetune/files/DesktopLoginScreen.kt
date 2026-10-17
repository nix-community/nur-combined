package moe.rukamori.archivetune.ui.screens

import android.net.Uri
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavController
import moe.rukamori.archivetune.viewmodels.LoginError
import moe.rukamori.archivetune.viewmodels.LoginScreenState
import moe.rukamori.archivetune.viewmodels.LoginViewModel

const val LOGIN_ROUTE = "login"
const val LOGIN_URL_ARGUMENT = "url"

fun buildLoginRoute(startUrl: String? = null): String {
    val resolvedUrl = startUrl?.trim().takeUnless { it.isNullOrBlank() } ?: return LOGIN_ROUTE
    return "$LOGIN_ROUTE?$LOGIN_URL_ARGUMENT=${Uri.encode(resolvedUrl)}"
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    navController: NavController,
    startUrl: String? = null,
    onLoginComplete: (() -> Unit)? = null,
    onNavigateBack: (() -> Unit)? = null,
    viewModel: LoginViewModel = hiltViewModel(),
) {
    val screenState by viewModel.screenState.collectAsStateWithLifecycle()
    val uriHandler = LocalUriHandler.current
    val clipboardManager = LocalClipboardManager.current
    var tokenInput by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(screenState) {
        when (val state = screenState) {
            is LoginScreenState.Success -> {
                onLoginComplete?.invoke() ?: navController.navigateUp()
            }
            is LoginScreenState.Error -> {
                errorMessage = when (state.error) {
                    LoginError.MissingDataSyncId -> "Failed to verify login (Missing DataSyncId). Please ensure your token contains complete cookie headers."
                    LoginError.LoginFailed -> "Login failed. Please check your token and try again."
                }
            }
            else -> {}
        }
    }

    val handleBack: () -> Unit = {
        if (onNavigateBack != null) onNavigateBack() else navController.navigateUp()
    }

    BackHandler(enabled = true, onBack = handleBack)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Login") },
                navigationIcon = {
                    IconButton(onClick = handleBack) {
                        Icon(
                            imageVector = Icons.Filled.ArrowBack,
                            contentDescription = "Back",
                        )
                    }
                },
            )
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp, vertical = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant,
                ),
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(
                        text = "YouTube Music Login (Desktop)",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                    )
                    Text(
                        text = "Embedded browser login is an Android feature not available on Desktop. To access your personal library and playlists, log in using your browser session cookie.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Button(
                        onClick = {
                            uriHandler.openUri(startUrl?.takeIf { it.isNotBlank() } ?: "https://music.youtube.com")
                        },
                        modifier = Modifier.padding(top = 4.dp),
                    ) {
                        Text("Open YouTube Music in Browser")
                    }
                }
            }

            Card(
                modifier = Modifier.fillMaxWidth(),
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(
                        text = "Instructions",
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.SemiBold,
                    )
                    Text(
                        text = "1. Click the button above to open YouTube Music in your browser and ensure you are logged in.\n" +
                               "2. Open Developer Tools (F12) -> Network tab.\n" +
                               "3. Click any network request to music.youtube.com (e.g. 'browse') and copy the value of the 'Cookie' request header.\n" +
                               "4. Paste it below and click 'Log In'.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )

                    OutlinedTextField(
                        value = tokenInput,
                        onValueChange = {
                            tokenInput = it
                            errorMessage = null
                        },
                        modifier = Modifier.fillMaxWidth(),
                        label = { Text("Cookie / Token") },
                        placeholder = { Text("Paste cookie string (SAPISID=...; HSID=...)") },
                        maxLines = 4,
                        isError = errorMessage != null,
                        supportingText = errorMessage?.let { { Text(it, color = MaterialTheme.colorScheme.error) } },
                    )

                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        FilledTonalButton(
                            onClick = {
                                clipboardManager.getText()?.text?.let {
                                    tokenInput = it
                                    errorMessage = null
                                }
                            }
                        ) {
                            Text("Paste from Clipboard")
                        }

                        Button(
                            onClick = {
                                if (tokenInput.isNotBlank()) {
                                    viewModel.onCookiesCaptured(tokenInput.trim())
                                }
                            },
                            enabled = tokenInput.isNotBlank() && screenState !is LoginScreenState.Loading,
                        ) {
                            if (screenState is LoginScreenState.Loading) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(18.dp),
                                    strokeWidth = 2.dp,
                                    color = MaterialTheme.colorScheme.onPrimary,
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                            }
                            Text("Log In")
                        }
                    }
                }
            }
        }
    }
}
