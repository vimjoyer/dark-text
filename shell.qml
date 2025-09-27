import QtQuick 2.15
import Quickshell
import QtQuick.Effects

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            aboveWindows: true
            height: 700
            anchors.left: true
            anchors.right: true
            color: "#00000000"
            // color: "black"

            Rectangle {
                id: myRectangle
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 200

                color: "#00000000"

                RectangularShadow {
                    anchors.fill: myRectangle
                    radius: 10
                    blur: 50
                    spread: 40
                    color: "#000000"
                }

                Text {
                    id: mainText
                    text: "NixOS Rebuilt"
                    font.pixelSize: 200
                    color: "#fad049"
                    font.family: "Times New Roman"

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: shadowText
                    text: mainText.text
                    font.pixelSize: mainText.font.pixelSize
                    font.family: mainText.font.family
                    color: mainText.color
                    anchors.horizontalCenter: mainText.horizontalCenter
                    anchors.verticalCenter: mainText.verticalCenter
                    anchors.topMargin: 10
                    opacity: 0.4
                    font.letterSpacing: 1
                }

                Component.onCompleted: {
                    panelAnimation.start();
                }

                SequentialAnimation {
                    id: panelAnimation

                    ParallelAnimation {

                        NumberAnimation {
                            target: myRectangle
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: 1000
                        }

                        NumberAnimation {
                            target: shadowText
                            property: "font.letterSpacing"
                            from: 1
                            to: 3
                            duration: 2000
                        }
                    }

                    NumberAnimation {
                        target: myRectangle
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 1000
                    }
                }
            }
        }
    }
}
