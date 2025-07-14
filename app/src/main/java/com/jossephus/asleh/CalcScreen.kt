package com.jossephus.asleh

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch

data class Entry(val input: String, val result: String)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CalcScreen() {
    val entries = remember { mutableStateListOf<Entry>() }
    var input by remember { mutableStateOf("") }
    val listState = rememberLazyListState()
    val coroutineScope = rememberCoroutineScope()
    val focusRequester = remember { FocusRequester() }

//    LaunchedEffect(Unit) {
//        focusRequester.requestFocus()
//    }

    Scaffold(
        topBar = {
            TopAppBar(
                modifier = Modifier
                    .height(70.dp),
                title = {},
                actions = {
                    Text(
                        "clear",
                        color = Color.White,
                        modifier = Modifier.clickable {
//                            entries.clear()
                        }
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color(0xFF2B2B2B)
                )
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
                .background(Color(0xFF2B2B2B))
                .padding(16.dp)
        ) {
            LazyColumn(
                state = listState,
                modifier = Modifier.weight(1f)
            ) {
                itemsIndexed(entries) { _, entry ->
                    HistoryItem(entry)
                }

                item {
                    InputBox(
                        value = input,
                        onValueChange = { input = it },
                        onSend = {
                            if (input.isNotBlank()) {
                                val now = java.util.Date()
                                val timestampMillis: Long = now.time
                                val timezoneOffsetSeconds: Int = java.util.TimeZone.getDefault().rawOffset / 1000

                                val calc = uniffi.asleh.evaluateFend(input, 10.toUInt(), timestampMillis.toUInt(), timezoneOffsetSeconds.toUInt() )
                                entries.add(Entry(input = input, result = calc))
                                input = ""

                                // scroll to bottom
                                coroutineScope.launch {
                                    listState.animateScrollToItem(index = listState.layoutInfo.totalItemsCount)
                                    focusRequester.requestFocus()
                                }
                            } else {
                                entries.add(Entry(input = input, result = ""))
                            }
                        },
                        focusRequester = focusRequester
                    )
                }
            }
        }
    }
}

@Composable
fun HistoryItem(entry: Entry) {
    val promptColor = Color(0xFF6A8759)
    val resultColor = Color(0xFFA9B7C6)

    Column(modifier = Modifier.fillMaxWidth()) {
        Row {
            Text(
                text = "> ",
                color = promptColor,
                style = code()
            )
            Text(
                text = entry.input,
                color = resultColor,
                style = code()
            )
        }
        Text(
            text = entry.result,
            color = resultColor,
            style = code(),
            modifier = Modifier.padding(bottom = 8.dp) // Space between entries
        )
    }
}

@Composable
fun InputBox(
    value: String,
    onValueChange: (String) -> Unit,
    onSend: () -> Unit,
    focusRequester: FocusRequester
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "> ",
            color = Color(0xFF6A8759),
            style = code()
        )
        BasicTextField(
            value = value,
            onValueChange = onValueChange,
            modifier = Modifier
                .fillMaxWidth()
                .focusRequester(focusRequester),
            textStyle = code().copy(color = Color(0xFFA9B7C6)),
            keyboardOptions = KeyboardOptions(
                imeAction = ImeAction.Send
            ),
            keyboardActions = KeyboardActions(
                onSend = { onSend() }
            ),
            singleLine = true,
            cursorBrush = SolidColor(Color.White)
        )
    }
}

@Composable
fun code(): TextStyle {
    return TextStyle(
        fontFamily = FontFamily.Monospace,
        fontSize = 14.sp,
        color = Color.White
    )
}