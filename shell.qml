import QtQuick 2.15
import Quickshell
import Quickshell.Io
import QtQuick.Effects

ShellRoot {
    id: root
    property int animationDuration: 1000

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            aboveWindows: true
            height: 700
            anchors.left: true
            anchors.right: true
            color: "#00000000"

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

                ParallelAnimation {
                    id: panelAnimation

                    SequentialAnimation {

                        NumberAnimation {
                            target: myRectangle
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: root.animationDuration / 4
                        }

                        NumberAnimation {
                            target: myRectangle
                            property: "opacity"
                            from: 1
                            to: 1
                            duration: root.animationDuration / 2
                        }

                        NumberAnimation {
                            target: myRectangle
                            property: "opacity"
                            from: 1
                            to: 0
                            duration: root.animationDuration / 4
                        }
                    }

                    NumberAnimation {
                        target: shadowText
                        property: "font.letterSpacing"
                        from: 1
                        to: 10
                        duration: root.animationDuration
                    }

                    onStopped: {
                        Qt.quit();
                    }
                }

                Process {
                    running: true
                    command: ["sh", "-c", "echo $DARK_TEXT"]
                    stdout: StdioCollector {
                        onStreamFinished: {
                            if (this.text && this.text.trim() !== "") {
                                mainText.text = this.text;
                            }
                        }
                    }
                }

                Process {
                    running: true
                    command: ["sh", "-c", "echo $DARK_DURATION"]
                    stdout: StdioCollector {
                      onStreamFinished: {
                        if (this.text && this.text.trim() !== "" ){
                            root.animationDuration = parseInt(this.text);
                        }
                      }
                    }
                }

                Process {
                    running: true
                    command: ["sh", "-c", "echo $DARK_COLOR"]
                    stdout: StdioCollector {
                      onStreamFinished: {
                        if (this.text && this.text.trim() !== ""){
                            console.log(this.text)
                            mainText.color = this.text.trim();
                        }
                      }
                    }
                }

            }
        }
    }
}
