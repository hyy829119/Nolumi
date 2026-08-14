// qml/components/VoiceWave.qml
import QtQuick

Item {
    id: root

    property bool running: false
    property color waveColor: "#777777"
    width: 70
    height: 26

    Row {
        anchors.centerIn: parent

        spacing: 6

        Repeater {
            model: 5

            Rectangle {
                id: bar

                width: 4
                height: 8 + index * 2
                radius: 2

                color: root.waveColor

                transformOrigin: Item.Center

                SequentialAnimation on scale {
                    running: root.running
                    loops: Animation.Infinite

                    NumberAnimation {
                        from: 0.65
                        to: 1.7
                        duration: 240 + index * 60
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        from: 1.7
                        to: 0.65
                        duration: 240 + index * 60
                        easing.type: Easing.InOutSine
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }

                opacity: root.running ? 1.0 : 0.25
            }
        }
    }
}
