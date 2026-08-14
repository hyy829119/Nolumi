// qml/pages/LoginPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root

    signal loginSuccess

    background: Rectangle {
        color: "#F7F7F8"
    }

    ColumnLayout {
        width: Math.min(parent.width - 48, 360)

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        spacing: 18

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 92

            Rectangle {
                width: 76
                height: 76
                radius: width / 2

                anchors.horizontalCenter: parent.horizontalCenter
                color: "#202020"

                Text {
                    anchors.centerIn: parent
                    text: "N"
                    color: "#FFFFFF"
                    font.pixelSize: 28
                    font.bold: true
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "欢迎回来"
            color: "#181818"
            font.pixelSize: 26
            font.bold: true
        }

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "想说的时候，我在"
            color: "#929292"
            font.pixelSize: 14
        }

        Item {
            Layout.preferredHeight: 10
        }

        TextField {
            id: accountField
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            placeholderText: "手机号 / 用户名"
            font.pixelSize: 15
            leftPadding: 16
            rightPadding: 16
            selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter
            background: Rectangle {
                radius: 12
                color: "#FFFFFF"
                border.width: accountField.activeFocus ? 1 : 0
                border.color: "#202020"
            }
        }

        TextField {
            id: passwordField
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            placeholderText: "密码"
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            font.pixelSize: 15
            leftPadding: 16
            rightPadding: 16
            selectByMouse: true
            background: Rectangle {
                radius: 12
                color: "#FFFFFF"
                border.width: passwordField.activeFocus ? 1 : 0
                border.color: "#202020"
            }
            Keys.onReturnPressed: {
                if (loginButton.enabled) {
                    loginButton.clicked()
                }
            }
        }

        Button {
            id: loginButton
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            enabled: accountField.text.trim().length > 0
                     && passwordField.text.length > 0
            contentItem: Text {
                text: "登录"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: loginButton.enabled ? "#FFFFFF" : "#AAAAAA"
                font.pixelSize: 16
                font.bold: true
            }

            background: Rectangle {
                radius: 12
                color: loginButton.enabled ? "#202020" : "#E5E5E5"
                scale: loginButton.pressed ? 0.98 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 80
                    }
                }
            }

            onClicked: {
                // 当前阶段先直接进入。
                // 后面这里改成：
                // AppContext.authManager.login(
                //     accountField.text,
                //     passwordField.text
                // )
                root.loginSuccess()
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter

            flat: true

            contentItem: Text {
                text: "第一次使用？创建账号"

                color: "#888888"
                font.pixelSize: 13

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: "transparent"
            }

            onClicked: {
                console.log("TODO: register")
            }
        }
    }
}
