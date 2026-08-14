// qml/components/RoundButton.qml
import QtQuick
import QtQuick.Controls

Button {
    id: root

    property color normalColor: "#202020"
    property color hoverColor: "#303030"
    property color pressedColor: "#111111"
    property color disabledColor: "#E5E5E5"

    property color textColor: "#FFFFFF"
    property color disabledTextColor: "#AAAAAA"

    property int buttonRadius: 12

    contentItem: Text {
        text: root.text

        color: root.enabled ? root.textColor : root.disabledTextColor

        font.pixelSize: 15
        font.bold: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: root.buttonRadius

        color: {
            if (!root.enabled) {
                return root.disabledColor
            }

            if (root.pressed) {
                return root.pressedColor
            }

            if (root.hovered) {
                return root.hoverColor
            }

            return root.normalColor
        }

        scale: root.pressed ? 0.97 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 80
            }
        }
    }
}
