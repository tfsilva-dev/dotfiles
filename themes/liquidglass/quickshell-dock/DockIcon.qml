// DockIcon.qml — ícone do dock "flutuando" (sem fundo), com magnificação ao passar o mouse

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Effects

Item {
    id: root
    property string iconPath: ""
    property string name: ""
    property string command: ""

    // O ícone cresce um pouco no hover (efeito clássico do dock do macOS)
    property int baseSize: 32
    property int hoverSize: 40

    width: hoverSize
    height: hoverSize

    Image {
        id: icon
        anchors.centerIn: parent
        source: root.iconPath
        width: mouseArea.containsMouse ? root.hoverSize : root.baseSize
        height: width
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: true

        Behavior on width {
            NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
        }

        // "queda" de sombra suave, só pra descolar do wallpaper
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#66000000"
            shadowBlur: 0.4
            shadowVerticalOffset: 2
        }

        // salto rápido no clique, estilo "bounce" do dock do macOS
        transform: Translate { id: bounce; y: 0 }
        SequentialAnimation {
            id: bounceAnim
            NumberAnimation { target: bounce; property: "y"; to: -8; duration: 100; easing.type: Easing.OutQuad }
            NumberAnimation { target: bounce; property: "y"; to: 0; duration: 160; easing.type: Easing.OutBounce }
        }
    }

    // ícone quebrado/ausente não fica em branco silenciosamente
    Rectangle {
        anchors.centerIn: parent
        width: root.baseSize
        height: root.baseSize
        radius: 6
        color: "#33ffffff"
        border.color: "#66ffffff"
        visible: icon.status === Image.Error
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            bounceAnim.restart()
            launchProc.command = root.command.split(" ")
            launchProc.running = true
        }
    }

    // Tooltip em janela própria: o painel do dock tem só 52px de altura,
    // então um item comum ficaria preso a essa faixa e a Popup do
    // QtQuick.Controls colapsava em cima do cursor, bloqueando o clique.
    PopupWindow {
        id: tooltip
        visible: mouseArea.containsMouse && root.name.length > 0
        color: "transparent"
        implicitWidth: tooltipLabel.implicitWidth + 16
        implicitHeight: tooltipLabel.implicitHeight + 10

        anchor {
            item: root
            edges: Edges.Top
            gravity: Edges.Top
            margins.bottom: 8
        }

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: "#dd1a1a1a"
            border.color: "#33ffffff"
            border.width: 1

            Text {
                id: tooltipLabel
                anchors.centerIn: parent
                text: root.name
                color: "white"
                font.pixelSize: 12
            }
        }
    }

    Process {
        id: launchProc
    }
}
