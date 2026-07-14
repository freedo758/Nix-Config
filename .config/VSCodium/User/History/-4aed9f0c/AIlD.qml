//@ pragma UseQApplication

import QtQuick
import Quickshell
import "./modules/bar/"

Shellroot {
    id: root

    Loader{
        active: true
        sourceComponent: bar{}
    }
}