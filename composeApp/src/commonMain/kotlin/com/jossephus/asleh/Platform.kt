package com.jossephus.asleh

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform