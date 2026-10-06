// Txt.qml — Text com a fonte e a cor padrão do tema

import QtQuick
import qs

Text {
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBody
    renderType: Text.QtRendering
}
