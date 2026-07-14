//@ pragma UseQApplication

import qtQuick
import Quickshell
import "./modules/bar/"

shellroot {
    id: root

    Loader{
        active: true
        sourceComponent: bar{}
    }
}