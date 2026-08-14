// qml/components/LoadingIndicator.qml
import QtQuick

Item {
    id: root

    property bool running: false
    property color indicatorColor: "#777777"

    width: 36
    height: 36

    visible: running

    Rectangle {
        id: indicator

        width: 30
        height: 30

        anchors.centerIn: parent

        radius: width / 2

        color: "transparent"

        border.width: 3
        border.color: root.indicatorColor

        Rectangle {
            width: 8
            height: 8

            radius: width / 2

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            anchors.topMargin: -2

            color: "#F7F7F8"
        }
    }

    RotationAnimation {
        target: indicator

        property: "rotation"

        from: 0
        to: 360

        duration: 900

        loops: Animation.Infinite
        running: root.running
    }
}
