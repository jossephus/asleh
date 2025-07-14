package com.jossephus.asleh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.jossephus.asleh.ui.theme.AslehTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            AslehTheme {
                CalcScreen()
            }
        }
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    val now = java.util.Date()
    val timestampMillis: Long = now.time
    val timezoneOffsetSeconds: Int = java.util.TimeZone.getDefault().rawOffset / 1000

    Text(
        text = "Hello ${uniffi.asleh.evaluateFend("1 + 1", 10.toUInt(), timestampMillis.toUInt(), timezoneOffsetSeconds.toUInt() )}!",
        modifier = modifier
    )
}


@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    AslehTheme {
        Greeting("Android")
    }
}