// qml/pages/SettingsPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    signal backRequested

    property string currentVoice: "温柔女声"
    property real speechRate: 1.0

    property bool autoPlay: true
    property bool allowInterrupt: true

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

    Label {
        anchors.top: parent.top
        anchors.topMargin: 25

        anchors.horizontalCenter: parent.horizontalCenter

        text: "设置"

        color: "#202020"

        font.pixelSize: 20
        font.bold: true
    }

    Flickable {
        anchors.fill: parent

        anchors.topMargin: 80
        anchors.bottomMargin: 20

        contentWidth: width
        contentHeight: settingsColumn.height

        clip: true

        ScrollBar.vertical: ScrollBar {}

        ColumnLayout {
            id: settingsColumn

            width: Math.min(parent.width - 40, 420)

            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 16
            // 声音设置
            Label {
                text: "声音"

                color: "#8A8A8A"

                font.pixelSize: 13
                font.bold: true

                Layout.leftMargin: 6
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                radius: 14
                color: "#FFFFFF"

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    Label {
                        text: "TA 的声音"

                        color: "#202020"
                        font.pixelSize: 15

                        Layout.fillWidth: true
                    }

                    Label {
                        text: root.currentVoice

                        color: "#888888"
                        font.pixelSize: 14
                    }

                    Label {
                        text: "›"

                        color: "#999999"
                        font.pixelSize: 22
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        voicePopup.open()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 88

                radius: 14
                color: "#FFFFFF"

                ColumnLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    anchors.topMargin: 12
                    anchors.bottomMargin: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "语速"

                            color: "#202020"
                            font.pixelSize: 15

                            Layout.fillWidth: true
                        }

                        Label {
                            text: root.speechRate.toFixed(1) + "x"

                            color: "#888888"
                            font.pixelSize: 13
                        }
                    }

                    Slider {
                        id: speechRateSlider

                        Layout.fillWidth: true

                        from: 0.7
                        to: 1.3

                        stepSize: 0.1

                        value: root.speechRate

                        onMoved: {
                            root.speechRate = value
                        }
                    }
                }
            }

            Item {
                Layout.preferredHeight: 4
            }
            // 对话设置
            Label {
                text: "对话"

                color: "#8A8A8A"

                font.pixelSize: 13
                font.bold: true

                Layout.leftMargin: 6
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                radius: 14
                color: "#FFFFFF"

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    Label {
                        text: "自动播放声音"

                        color: "#202020"
                        font.pixelSize: 15

                        Layout.fillWidth: true
                    }

                    Switch {
                        checked: root.autoPlay

                        onToggled: {
                            root.autoPlay = checked
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                radius: 14
                color: "#FFFFFF"

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    Label {
                        text: "允许打断 TA"

                        color: "#202020"
                        font.pixelSize: 15

                        Layout.fillWidth: true
                    }

                    Switch {
                        checked: root.allowInterrupt

                        onToggled: {
                            root.allowInterrupt = checked
                        }
                    }
                }
            }

            Item {
                Layout.preferredHeight: 4
            }
            // 音频设备
            Label {
                text: "设备"

                color: "#8A8A8A"

                font.pixelSize: 13
                font.bold: true

                Layout.leftMargin: 6
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                radius: 14
                color: "#FFFFFF"

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    Label {
                        text: "麦克风"

                        color: "#202020"
                        font.pixelSize: 15

                        Layout.fillWidth: true
                    }

                    Label {
                        text: "默认设备"

                        color: "#888888"
                        font.pixelSize: 14
                    }

                    Label {
                        text: "›"

                        color: "#999999"
                        font.pixelSize: 22
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        console.log("TODO: microphone device")
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64

                radius: 14
                color: "#FFFFFF"

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 18
                    anchors.rightMargin: 18

                    Label {
                        text: "扬声器"

                        color: "#202020"
                        font.pixelSize: 15

                        Layout.fillWidth: true
                    }

                    Label {
                        text: "默认设备"

                        color: "#888888"
                        font.pixelSize: 14
                    }

                    Label {
                        text: "›"

                        color: "#999999"
                        font.pixelSize: 22
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        console.log("TODO: output device")
                    }
                }
            }

            Item {
                Layout.preferredHeight: 30
            }
        }
    }

    Popup {
        id: voicePopup

        width: Math.min(root.width - 40, 360)
        height: 330

        anchors.centerIn: Overlay.overlay

        modal: true
        focus: true

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 18
            color: "#FFFFFF"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 8

            Label {
                text: "选择声音"

                color: "#202020"

                font.pixelSize: 18
                font.bold: true

                Layout.bottomMargin: 6
            }

            Repeater {
                model: [{
                        "name": "温柔女声",
                        "description": "温柔 · 自然"
                    }, {
                        "name": "自然女声",
                        "description": "轻松 · 自然"
                    }, {
                        "name": "温和男声",
                        "description": "温和 · 清晰"
                    }, {
                        "name": "沉稳男声",
                        "description": "沉稳 · 平静"
                    }]

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54

                    radius: 10

                    color: root.currentVoice === modelData.name ? "#F0F0F1" : "transparent"

                    RowLayout {
                        anchors.fill: parent

                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 2

                            Label {
                                text: modelData.name

                                color: "#202020"
                                font.pixelSize: 14
                            }

                            Label {
                                text: modelData.description

                                color: "#999999"
                                font.pixelSize: 12
                            }
                        }

                        Label {
                            visible: root.currentVoice === modelData.name

                            text: "✓"

                            color: "#202020"

                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.currentVoice = modelData.name
                            voicePopup.close()
                        }
                    }
                }
            }
        }
    }
}
