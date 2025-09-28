import QtQuick 2.15
import Quickshell
import Quickshell.Io
import QtQuick.Effects

ShellRoot {
    id: root
    property int animationDuration: 3000

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

                Text {
                    id: mainText
                    text: "Firelink Shrine"
                    font.pixelSize: 150
                    font.family: "EB Garamond"
                    font.bold: false
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    style: TextRaised
                    styleColor: "#33000000"


                }

                Canvas {
                    id: underline
                    property color color: "#ffffff"
                    width: mainText.width + 100
                    height: 6
                    anchors.horizontalCenter: mainText.horizontalCenter
                    anchors.top: mainText.bottom
                    anchors.topMargin: -30
                    opacity: mainText.opacity

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);

                        var grad = ctx.createLinearGradient(0, 0, width, 0);
                        grad.addColorStop(0.0, "transparent");
                        grad.addColorStop(0.15, color);  
                        grad.addColorStop(0.85, color);  
                        grad.addColorStop(1.0, "transparent");

                        ctx.fillStyle = grad;
                        ctx.fillRect(0, height / 2 - 1, width, 2);
                    }

                }

                Component.onCompleted: {
                    panelAnimation.start();
                }

                SequentialAnimation {
                    id: panelAnimation
                    NumberAnimation {
                        target: myRectangle
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: root.animationDuration / 4
                    }

                    PauseAnimation {
                        duration: root.animationDuration / 2
                    }

                    NumberAnimation {
                        target: myRectangle
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: root.animationDuration / 4
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
                            if (this.text && this.text.trim() !== "") {
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
                            if (this.text && this.text.trim() !== "") {
                                mainText.color = this.text.trim();
                                underline.color = this.text.trim();
                                console.log(underline.color)
                            }
                        }
                    }
                }
            }
        }
    }
}
