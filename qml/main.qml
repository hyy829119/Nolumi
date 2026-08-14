// qml/Main.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "pages"
import "components"

ApplicationWindow {
    id: root

    width: 420
    height: 760
    minimumWidth: 360
    minimumHeight: 640
    maximumWidth: 360
    maximumHeight: 640

    visible: true
    title: "Nolumi"

    color: "#F7F7F8"

    // 当前页面
    property string currentPage: "login"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: loginPageComponent
    }

    Component {
        id: loginPageComponent

        LoginPage {
            onLoginSuccess: {
                root.currentPage = "createCompanion"
                stackView.push(createCompanionPageComponent)
            }
        }
    }

    Component {
        id: createCompanionPageComponent

        CreateCompanionPage {
            onCreateFinished: function (name, avatar) {
                root.currentPage = "chat"

                stackView.push(chatPageComponent, {
                                   "companionName": name,
                                   "companionAvatar": avatar
                               })
            }

            onBackRequested: {
                stackView.pop()
                root.currentPage = "login"
            }
        }
    }

    Component {
        id: chatPageComponent

        ChatPage {
            onSettingsRequested: {
                root.currentPage = "settings"
                stackView.push(settingsPageComponent)
            }
        }
    }

    Component {
        id: settingsPageComponent

        SettingsPage {
            onBackRequested: {
                stackView.pop()
                root.currentPage = "chat"
            }
        }
    }

    // 统一页面切换函数
    function openLoginPage() {
        stackView.clear()
        stackView.push(loginPageComponent)
        currentPage = "login"
    }

    function openCreateCompanionPage() {
        stackView.push(createCompanionPageComponent)
        currentPage = "createCompanion"
    }

    function openChatPage(properties) {
        stackView.push(chatPageComponent, properties || {})
        currentPage = "chat"
    }

    function openSettingsPage() {
        stackView.push(settingsPageComponent)
        currentPage = "settings"
    }

    function goBack() {
        if (stackView.depth > 1) {
            stackView.pop()
        }
    }
}
