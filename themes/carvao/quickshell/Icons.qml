// Icons.qml — glifos Material Design da JetBrainsMono Nerd Font
// (codepoints conferidos na fonte instalada)

pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string volumeHigh: String.fromCodePoint(0xF057E)
    readonly property string volumeMedium: String.fromCodePoint(0xF0580)
    readonly property string volumeLow: String.fromCodePoint(0xF057F)
    readonly property string volumeOff: String.fromCodePoint(0xF0581)
    readonly property string check: String.fromCodePoint(0xF012C)

    readonly property string previous: String.fromCodePoint(0xF04AE)
    readonly property string play: String.fromCodePoint(0xF040A)
    readonly property string pause: String.fromCodePoint(0xF03E4)
    readonly property string next: String.fromCodePoint(0xF04AD)

    readonly property string ethernet: String.fromCodePoint(0xF0200)
    readonly property string bluetooth: String.fromCodePoint(0xF00AF)
    readonly property string bluetoothOff: String.fromCodePoint(0xF00B2)
    readonly property string bell: String.fromCodePoint(0xF009A)
    readonly property string bellOff: String.fromCodePoint(0xF009B)

    readonly property string back: String.fromCodePoint(0xF004D)
    readonly property string close: String.fromCodePoint(0xF0156)
    readonly property string cog: String.fromCodePoint(0xF0493)
    readonly property string lock: String.fromCodePoint(0xF033E)
    readonly property string restart: String.fromCodePoint(0xF0709)
    readonly property string power: String.fromCodePoint(0xF0425)

    readonly property string sunny: String.fromCodePoint(0xF0599)
    readonly property string partlyCloudy: String.fromCodePoint(0xF0595)
    readonly property string cloudy: String.fromCodePoint(0xF0590)
    readonly property string fog: String.fromCodePoint(0xF0591)
    readonly property string rainy: String.fromCodePoint(0xF0597)
    readonly property string pouring: String.fromCodePoint(0xF0596)
    readonly property string snowy: String.fromCodePoint(0xF0598)
    readonly property string storm: String.fromCodePoint(0xF067E)
    readonly property string thermometer: String.fromCodePoint(0xF050F)

    function volumeFor(percent, muted) {
        if (muted || percent === 0) return volumeOff
        if (percent < 34) return volumeLow
        if (percent < 67) return volumeMedium
        return volumeHigh
    }
}
