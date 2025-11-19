package com.jossephus.asleh

actual fun evaluateFend(
    input: String,
    timeout: UInt,
    time: UInt,
    timezoneOffset: UInt
): String {
    return asleh.evaluateFend(input, timeout, time, timezoneOffset)
}