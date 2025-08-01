package com.akitorahayashi.templateandroidapp

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.akitorahayashi.templateandroidapp.ui.theme.DarkColorScheme
import com.akitorahayashi.templateandroidapp.ui.theme.LightColorScheme

@Composable
fun InitialScreen() {
    Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
        Box(
            modifier =
                Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
            contentAlignment = Alignment.Center,
        ) {
            Text(text = "Hello Android!")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun InitialScreenPreview() {
    val darkTheme = androidx.compose.foundation.isSystemInDarkTheme()
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    androidx.compose.material3.MaterialTheme(colorScheme = colorScheme) {
        InitialScreen()
    }
}
