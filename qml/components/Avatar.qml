// qml/components/Avatar.qml
import QtQuick

Item {
    id: root

    property url source: ""
    property string fallbackText: "N"
    property bool active: false

    property color backgroundColor: "#E6E6E8"
    property color textColor: "#777777"
    property color activeBorderColor: "#B8B8B8"

    Rectangle {
        id: glow

        anchors.centerIn: parent

        width: parent.width + 18
        height: parent.height + 18
        radius: width / 2

        color: "transparent"

        border.width: root.active ? 2 : 0
        border.color: root.activeBorderColor

        opacity: root.active ? 0.65 : 0

        SequentialAnimation on scale {
            running: root.active
            loops: Animation.Infinite

            NumberAnimation {
                from: 1.0
                to: 1.08
                duration: 850
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                from: 1.08
                to: 1.0
                duration: 850
                easing.type: Easing.InOutSine
            }
        }
    }

    Rectangle {
        id: avatar

        anchors.fill: parent

        radius: width / 2

        color: root.backgroundColor
        clip: true

        scale: root.active ? 1.04 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Image {
            anchors.fill: parent

            source: root.source

            fillMode: Image.PreserveAspectCrop

            visible: root.source.toString().length > 0

            asynchronous: true
            cache: true
        }

        Text {
            anchors.centerIn: parent

            visible: root.source.toString().length === 0

            text: root.fallbackText

            color: root.textColor

            font.pixelSize: Math.max(20, root.width * 0.32)
            font.bold: true
        }
    }
}
