// Media.qml — player MPRIS (título, artista, controles)

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs
import qs.components

RowLayout {
    id: media

    // Prefere o player que está tocando; senão, o primeiro da lista
    readonly property MprisPlayer player: {
        const players = Mpris.players.values
        return players.find(p => p.isPlaying) ?? players[0] ?? null
    }
    readonly property bool hasPlayer: player !== null

    visible: hasPlayer
    spacing: Theme.spacing

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Txt {
            Layout.fillWidth: true
            text: media.player ? (media.player.trackTitle || "Sem título") : ""
            elide: Text.ElideRight
        }

        Txt {
            Layout.fillWidth: true
            visible: text !== ""
            text: media.player ? (media.player.trackArtist || "") : ""
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSmall
            elide: Text.ElideRight
        }
    }

    IconButton {
        icon: Icons.previous
        enabled: media.player && media.player.canGoPrevious
        onClicked: media.player.previous()
    }

    IconButton {
        icon: media.player && media.player.isPlaying ? Icons.pause : Icons.play
        iconColor: Theme.text
        onClicked: media.player.togglePlaying()
    }

    IconButton {
        icon: Icons.next
        enabled: media.player && media.player.canGoNext
        onClicked: media.player.next()
    }
}
