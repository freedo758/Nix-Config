import qtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id:Panel

    anchors{
        
         top: true
         left: true
         right: true

    }
    implicitHeight:40
    margins {
        top: 0
        left: 0
        right: 0
        Rectangle {
            id: bar
            anchor.fill: parent
            color: "#1a1a1a"
            radius: 15
            border.color "#333333"
            border.width: 3

            row{
                
            }
        }
    }
}