import qtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id:Panel

    anchors {
        
         top: true
         left: true
         right: true

    }
    implicitHeight:40
    margins {
        top: 0
        left: 0
        right: 0
    }    
        Rectangle {
            id: bar
            anchor.fill: parent
            color: "#1a1a1a"
            radius: 15
            border.color "#333333"
            border.width: 3

            row {
                id: workspacesRow

                anchors {
                    left.parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin:16
                }
            spacing: 8

            Repeater {
                model: Hyprland.workspaces
                Rectangle {
                    width: 32
                    height: 24
                    radius: 15
                    color:modelData.active ? "#4a9eff" : "#333333"
                    border.color: "#555555"
                    border.width: 2

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspaces " + mnodelData.id)
                    }
                    Text {
                        text:modelData.id
                        anchors.centerIn: parent
                        color: modelData.active ? "#ffffff" : "#cccccc"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono"
                    }
                }
            }
            }
        }
    }
}