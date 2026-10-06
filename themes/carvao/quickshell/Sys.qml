// Sys.qml — estado e ações do sistema compartilhados pela barra e pelo painel
// (relógio, clima, áudio, rede, bluetooth, notificações, energia)

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // ---- Relógio ----
    // Nomes em português — Qt.formatDateTime não localiza pt-BR por padrão
    readonly property var weekdays: ["Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado"]
    readonly property var months: ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"]

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property date now: clock.date
    readonly property string time: Qt.formatDateTime(now, "hh:mm")
    readonly property string weekday: weekdays[now.getDay()]
    readonly property string longDate: now.getDate() + " de " + months[now.getMonth()] + " de " + now.getFullYear()

    // ---- Áudio (PipeWire) ----
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool audioReady: !!(sink && sink.ready && sink.audio)
    readonly property real volume: audioReady ? sink.audio.volume : 0
    readonly property bool muted: audioReady ? sink.audio.muted : false
    readonly property int volumePercent: Math.round(volume * 100)

    // Saídas de verdade: sinks de hardware/virtuais, sem os streams dos apps
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)

    // Sem o tracker o PwNode não fica "bound" e volume/muted não atualizam
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    function setVolume(v) {
        if (audioReady) sink.audio.volume = Math.max(0, Math.min(1, v))
    }

    function toggleMute() {
        if (audioReady) sink.audio.muted = !sink.audio.muted
    }

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node
    }

    function sinkName(node) {
        return node.description || node.nickname || node.name
    }

    // ---- Rede cabeada (só status; sem Wi-Fi nesta máquina) ----
    property string ethInterface: "enp7s0"
    property bool ethConnected: false

    Process {
        id: ethProc
        command: ["nmcli", "-t", "-g", "GENERAL.STATE", "device", "show", root.ethInterface]
        // saída típica: "100 (connected)"
        stdout: StdioCollector {
            onStreamFinished: root.ethConnected = text.trim().startsWith("100")
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: ethProc.running = true
    }

    function openNetworkSettings() {
        Quickshell.execDetached(["nm-connection-editor"])
    }

    // ---- Bluetooth ----
    property bool btEnabled: false

    Process {
        id: btCheckProc
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: root.btEnabled = /Powered:\s*yes/i.test(text)
        }
    }

    Process {
        id: btToggleProc
        onExited: btRecheckTimer.restart()
    }

    Timer {
        id: btRecheckTimer
        interval: 600
        onTriggered: btCheckProc.running = true
    }

    function toggleBluetooth() {
        btToggleProc.command = ["bluetoothctl", "power", btEnabled ? "off" : "on"]
        btToggleProc.running = true
    }

    // ---- Janela de aparência (aberta pela engrenagem do painel) ----
    property bool appearanceOpen: false

    // ---- Notificações ----
    property bool dnd: false

    // ---- Clima (Open-Meteo, sem chave de API) ----
    property int weatherTemp: 0
    property string weatherIcon: ""
    property string weatherLabel: ""
    property bool weatherLoaded: false

    function weatherInfo(code) {
        if (code === 0) return { icon: Icons.sunny, label: "Céu limpo" }
        if (code <= 2) return { icon: Icons.partlyCloudy, label: "Poucas nuvens" }
        if (code === 3) return { icon: Icons.cloudy, label: "Nublado" }
        if (code === 45 || code === 48) return { icon: Icons.fog, label: "Neblina" }
        if (code >= 51 && code <= 57) return { icon: Icons.rainy, label: "Garoa" }
        if (code >= 61 && code <= 67) return { icon: Icons.rainy, label: "Chuva" }
        if (code >= 71 && code <= 77) return { icon: Icons.snowy, label: "Neve" }
        if (code >= 80 && code <= 82) return { icon: Icons.pouring, label: "Pancadas de chuva" }
        if (code >= 95) return { icon: Icons.storm, label: "Tempestade" }
        return { icon: Icons.thermometer, label: "—" }
    }

    Process {
        id: weatherProc
        command: ["curl", "-s", "https://api.open-meteo.com/v1/forecast?latitude=-22.9977&longitude=-43.6247&current_weather=true&timezone=America/Sao_Paulo"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    const info = root.weatherInfo(data.current_weather.weathercode)
                    root.weatherTemp = Math.round(data.current_weather.temperature)
                    root.weatherIcon = info.icon
                    root.weatherLabel = info.label
                    root.weatherLoaded = true
                } catch (e) {
                    console.log("Erro ao processar clima:", e)
                }
            }
        }
    }

    Timer {
        interval: 900000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherProc.running = true
    }

    // ---- Workspaces ----
    function focusWorkspace(id) {
        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({workspace=" + id + "})"])
    }

    // ---- Energia (sempre via ~/.local/bin/power, que fecha o Steam antes) ----
    function power(action) {
        Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/power", action])
    }

    function lock() {
        Quickshell.execDetached(["hyprlock"])
    }

    // Chamado quando o painel abre, pra não mostrar estado velho
    function refresh() {
        ethProc.running = true
        btCheckProc.running = true
    }

    Component.onCompleted: btCheckProc.running = true
}
