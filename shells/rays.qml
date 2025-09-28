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
            height: 600
            anchors.left: true
            anchors.right: true
            color: "#00000000"

            Rectangle {
                id: textRectangle
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height
                visible: false

                color: "#00000000"

                Text {
                    id: mainText
                    text: "NixOS Rebuilt"
                    font.pixelSize: 200
                    color: "#fad049"
                    font.family: "EB Garamond"

                    anchors.verticalCenterOffset: 30
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            Rectangle {
                id: shaderRectangle
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height

                color: "#00000000"

                Component.onCompleted: {
                    panelAnimation.start();
                }

                Timer {
                    interval: root.animationDuration
                    running: true
                    repeat: false
                    onTriggered: Qt.quit()
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
                            textShaderAnimation.to = parseInt(this.text) / 1000;
                            textShaderAnimation.duration = parseInt(this.text);
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

                Process {
                    running: true
                    command: ["sh", "-c", "echo $TEXT_SHADER"]
                    stdout: StdioCollector {
                      onStreamFinished: {
                        if (this.text && this.text.trim() !== ""){
                            console.log(this.text)
                            textShader.fragmentShader = this.text.trim();
                        }
                      }
                    }
                }


                // Provide a ShaderEffectSource so the ShaderEffect can sample the Image.
                ShaderEffectSource {
                    id: textShaderSource
                    sourceItem: textRectangle
                    live: true
                    recursive: true
                }

                ShaderEffect {
                    id: textShader

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height

                    property variant src: textShaderSource
                    property real time: 0
                    property real duration: root.animationDuration / 1000

                    NumberAnimation on time {
                        id: textShaderAnimation
                        loops: Animation.Infinite
                        from: 0
                        to: 0
                        duration: 1
                    }
                }
            }
        }
    }
}
