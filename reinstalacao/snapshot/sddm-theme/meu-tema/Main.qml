import QtQuick 2.0

Rectangle {
    width: 1920
    height: 1080

    // 1. O Wallpaper de Fundo
    Image {
        id: background
        anchors.fill: parent
        source: "file:///usr/share/sddm/themes/meu-tema/wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    // 2. Painel Central de Vidro
    Rectangle {
        width: 320
        height: 380
        anchors.centerIn: parent
        color: Qt.rgba(0, 0, 0, 0.4) 
        radius: 20 

        Column {
            anchors.centerIn: parent
            spacing: 20

            // 3. Avatar da Foto (Agora lendo arquivo .png)
            Rectangle {
                width: 100
                height: 100
                radius: 50
                color: "transparent"
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true 

                Image {
                    anchors.fill: parent
                    source: "file:///usr/share/sddm/themes/meu-tema/avatar.png"
                    fillMode: Image.PreserveAspectCrop
                }
            }

            // 4. Nome do Usuário
            Text {
                text: "Ferreira"
                color: "white"
                font.pixelSize: 22
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // 5. Caixa de Senha
            Rectangle {
                width: 240
                height: 40
                radius: 20
                color: Qt.rgba(1, 1, 1, 0.15)
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 1
                anchors.horizontalCenter: parent.horizontalCenter

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    verticalAlignment: TextInput.AlignVCenter
                    color: "white"
                    font.pixelSize: 16
                    echoMode: TextInput.Password
                    focus: true
                    clip: true

                    Text {
                        text: "Senha"
                        color: Qt.rgba(1, 1, 1, 0.5)
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                        visible: parent.text === ""
                    }

                    onAccepted: {
                        statusText.text = "Autenticando..."
                        sddm.login("ferreira", text, 0)
                        text = ""
                    }
                }
            }

            // 6. Texto de Status
            Text {
                id: statusText
                text: ""
                color: "white"
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // 7. Botões de Energia (Rodapé)
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 40
        spacing: 30

        // Botão Desligar
        Rectangle {
            width: 140
            height: 40
            radius: 10
            color: Qt.rgba(0, 0, 0, 0.5)
            border.color: Qt.rgba(1, 1, 1, 0.3)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "⏻ Desligar"
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }

        // Botão Reiniciar
        Rectangle {
            width: 140
            height: 40
            radius: 10
            color: Qt.rgba(0, 0, 0, 0.5)
            border.color: Qt.rgba(1, 1, 1, 0.3)
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "⭮ Reiniciar"
                color: "white"
                font.pixelSize: 16
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }
    }
}
