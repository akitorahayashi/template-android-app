package com.akitorahayashi.templateandroidapp
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import com.akitorahayashi.templateandroidapp.ui.theme.DarkColorScheme
import com.akitorahayashi.templateandroidapp.ui.theme.LightColorScheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            val darkTheme = isSystemInDarkTheme()
            val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
            MaterialTheme(colorScheme = colorScheme) {
                InitialScreen()
            }
        }
    }
}
