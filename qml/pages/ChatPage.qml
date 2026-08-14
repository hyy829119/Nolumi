// qml/pages/ChatPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Page {
    id: root

    signal settingsRequested

    property string companionName: "Nolumi"
    property url companionAvatar: ""
    property url userAvatar: ""

    enum ConversationState {
        Idle,
        Listening,
        Thinking,
        Speaking
    }

    property int conversationState: ChatPage.Idle

    background: Rectangle {
        color: "#F7F7F8"
    }

    Button {
        id: settingsButton

        width: 42
        height: 42

        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 18
        anchors.rightMargin: 18

        flat: true

        contentItem: Text {
            text: "⚙"

            color: "#666666"
            font.pixelSize: 20

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: width / 2

            color: settingsButton.hovered ? "#E9E9EA" : "transparent"
        }

        onClicked: {
            root.settingsRequested()
        }
    }

    ColumnLayout {
        anchors.fill: parent

        anchors.topMargin: 66
        anchors.bottomMargin: 30
        anchors.leftMargin: 24
        anchors.rightMargin: 24

        spacing: 0
        // TA 区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent

                spacing: 16

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.companionName

                    color: "#202020"

                    font.pixelSize: 18
                    font.bold: true
                }

                Item {
                    width: 170
                    height: 170

                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: aiGlow

                        anchors.centerIn: parent

                        width: 155
                        height: 155
                        radius: width / 2

                        color: "transparent"

                        border.width: root.conversationState === ChatPage.Speaking ? 2 : 0

                        border.color: "#B8B8B8"

                        opacity: root.conversationState === ChatPage.Speaking ? 0.7 : 0

                        SequentialAnimation on scale {
                            running: root.conversationState === ChatPage.Speaking

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
                        id: aiAvatar

                        anchors.centerIn: parent

                        width: 130
                        height: 130
                        radius: width / 2

                        color: "#E6E6E8"

                        clip: true

                        scale: root.conversationState === ChatPage.Speaking ? 1.05 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }

                        Image {
                            anchors.fill: parent

                            source: root.companionAvatar

                            fillMode: Image.PreserveAspectCrop

                            visible: root.companionAvatar.toString().length > 0
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: root.companionAvatar.toString(
                                         ).length === 0

                            text: root.companionName.length > 0 ? root.companionName.charAt(
                                                                      0) : "N"

                            color: "#777777"

                            font.pixelSize: 42
                            font.bold: true
                        }
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: {
                        switch (root.conversationState) {
                        case ChatPage.Listening:
                            return "正在听你说"
                        case ChatPage.Thinking:
                            return "想一想..."
                        case ChatPage.Speaking:
                            return "正在和你说话"
                        default:
                            return "想说的时候，我在"
                        }
                    }

                    color: "#989898"

                    font.pixelSize: 14
                }

                VoiceWave {
                    anchors.horizontalCenter: parent.horizontalCenter

                    running: root.conversationState === ChatPage.Speaking
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            Layout.leftMargin: 30
            Layout.rightMargin: 30

            color: "#E5E5E5"
        }
        // 用户区域
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors.centerIn: parent

                spacing: 18

                Avatar {
                    id: userAvatarItem

                    width: 100
                    height: 100

                    anchors.horizontalCenter: parent.horizontalCenter

                    source: root.userAvatar
                    fallbackText: "我"

                    active: root.conversationState === ChatPage.Listening
                }

                Button {
                    id: talkButton

                    width: 72
                    height: 72

                    anchors.horizontalCenter: parent.horizontalCenter

                    contentItem: Text {
                        text: root.conversationState === ChatPage.Listening ? "■" : "🎙"

                        color: "#FFFFFF"

                        font.pixelSize: 25

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: width / 2

                        color: root.conversationState === ChatPage.Listening ? "#444444" : "#202020"

                        scale: talkButton.pressed ? 0.94 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 90
                            }
                        }
                    }

                    onClicked: {

                        // 当前阶段先用按钮模拟状态
                        // 后面接 Python：
                        // ConversationManager.startListening()
                        // ConversationManager.stopListening()
                        if (root.conversationState === ChatPage.Listening) {

                            root.conversationState = ChatPage.Thinking
                        } else {

                            root.conversationState = ChatPage.Listening
                        }
                    }
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.conversationState === ChatPage.Listening ? "我在听" : "点击开始说话"

                    color: "#999999"

                    font.pixelSize: 13
                }
            }
        }
    }
}
