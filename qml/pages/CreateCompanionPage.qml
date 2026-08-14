// qml/pages/CreateCompanionPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Page {
    id: root

    signal createFinished(string name, url avatar)
    signal backRequested

    property url selectedAvatar: ""

    background: Rectangle {
        color: "#F7F7F8"
    }

    Button {
        id: backButton

        width: 42
        height: 42

        anchors.left: parent.left
        anchors.top: parent.top

        anchors.leftMargin: 18
        anchors.topMargin: 18

        flat: true

        contentItem: Text {
            text: "‹"

            color: "#555555"
            font.pixelSize: 30

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: width / 2

            color: backButton.hovered ? "#E9E9EA" : "transparent"
        }

        onClicked: {
            root.backRequested()
        }
    }

    ColumnLayout {
        width: Math.min(parent.width - 48, 360)

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        spacing: 20

        Label {
            Layout.alignment: Qt.AlignHCenter

            text: "TA 叫什么名字？"

            color: "#181818"

            font.pixelSize: 26
            font.bold: true
        }

        Label {
            Layout.alignment: Qt.AlignHCenter

            text: "给你的陪伴伙伴起个名字"

            color: "#969696"

            font.pixelSize: 14
        }

        Item {
            Layout.preferredHeight: 12
        }

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 140
            Layout.preferredHeight: 140

            Rectangle {
                id: avatarBackground
                anchors.fill: parent
                radius: width / 2
                color: "#E9E9EA"
                clip: true
                Image {
                    id: avatarImage
                    anchors.fill: parent
                    source: root.selectedAvatar
                    fillMode: Image.PreserveAspectCrop
                    visible: root.selectedAvatar.toString().length > 0
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.selectedAvatar.toString().length === 0
                    text: "+"
                    color: "#999999"
                    font.pixelSize: 42
                    font.weight: Font.Light
                }
            }

            Rectangle {
                width: 38
                height: 38
                radius: width / 2

                anchors.right: parent.right
                anchors.bottom: parent.bottom

                color: "#202020"

                border.width: 3
                border.color: "#F7F7F8"

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: "#FFFFFF"
                    font.pixelSize: 22
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    avatarDialog.open()
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.selectedAvatar.toString(
                      ).length > 0 ? "点击头像可以重新选择" : "给 TA 选张头像"
            color: "#999999"
            font.pixelSize: 13
        }

        Item {
            Layout.preferredHeight: 4
        }

        TextField {
            id: nameField
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            placeholderText: "例如：小暖"
            maximumLength: 20
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            font.pixelSize: 16
            selectByMouse: true
            background: Rectangle {
                radius: 12
                color: "#FFFFFF"
                border.width: nameField.activeFocus ? 1 : 0
                border.color: "#202020"
            }

            Keys.onReturnPressed: {
                if (createButton.enabled) {
                    createButton.clicked()
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: nameField.text.length + " / 20"
            color: "#B0B0B0"
            font.pixelSize: 12
        }

        Item {
            Layout.preferredHeight: 6
        }

        Button {
            id: createButton

            Layout.fillWidth: true
            Layout.preferredHeight: 50
            enabled: nameField.text.trim().length > 0
            contentItem: Text {
                text: "认识一下"

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                color: createButton.enabled ? "#FFFFFF" : "#AAAAAA"

                font.pixelSize: 16
                font.bold: true
            }

            background: Rectangle {
                radius: 12

                color: createButton.enabled ? "#202020" : "#E5E5E5"

                scale: createButton.pressed ? 0.98 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 80
                    }
                }
            }

            onClicked: {
                root.createFinished(nameField.text.trim(), root.selectedAvatar)
            }
        }
    }

    FileDialog {
        id: avatarDialog

        title: "选择头像"

        nameFilters: ["图片文件 (*.png *.jpg *.jpeg *.webp)"]

        onAccepted: {
            root.selectedAvatar = selectedFile
        }
    }
}
