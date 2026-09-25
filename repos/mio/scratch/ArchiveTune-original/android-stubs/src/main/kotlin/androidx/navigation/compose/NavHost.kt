
package androidx.navigation.compose
import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController

@Composable
fun NavHost(navController: NavHostController, startDestination: String, builder: Any.() -> Unit) {}

@Composable
fun rememberNavController(): NavHostController = NavHostController()
