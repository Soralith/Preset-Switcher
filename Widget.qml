import QtQuick

Item {
    required property var host
    readonly property var svc: host.service
    readonly property var t: host.theme

    implicitWidth: host.settings.width
    implicitHeight: host.settings.height

    // palette preview of the live theme
    Row {
        id: swatches
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        height: Math.max(24, parent.height * 0.35)
        spacing: 6
        Repeater {
            model: [t.pSurface, t.pSurfaceHover, t.pInk, t.accentCyan, t.accentMint, t.chipFill]
            Rectangle {
                width: (swatches.width - 5 * swatches.spacing) / 6
                height: swatches.height
                radius: t.radiusOuter / 2
                color: modelData
                border.width: 1
                border.color: t.pLine
            }
        }
    }

    // < preset name >
    Row {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
        height: 36
        spacing: 8

        Rectangle {
            width: 36; height: 36; radius: 8
            color: pm.containsMouse ? t.pSurfaceHover : t.pSurfaceDivider
            border.width: t.borderWidth; border.color: t.pLine
            Text {
                anchors.centerIn: parent
                text: "<"
                color: t.pInk
                font.family: t.fontFamily
                font.pixelSize: 16
            }
            MouseArea {
                id: pm
                anchors.fill: parent
                hoverEnabled: true
                onClicked: svc.step(-1)
            }
        }

        Text {
            width: parent.width - 2 * 36 - 2 * 8
            height: 36
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: t.pInk
            font.family: t.fontFamily
            font.pixelSize: 14
            text: svc.presets.length === 0
                  ? (svc.rawList !== "" ? "can't read preset list" : "no presets")
                  : (svc.current !== ""
                     ? svc.current + "  (" + (svc.presets.indexOf(svc.current) + 1) + "/" + svc.presets.length + ")"
                     : "press < or >")
        }

        Rectangle {
            width: 36; height: 36; radius: 8
            color: nm.containsMouse ? t.pSurfaceHover : t.pSurfaceDivider
            border.width: t.borderWidth; border.color: t.pLine
            Text {
                anchors.centerIn: parent
                text: ">"
                color: t.pInk
                font.family: t.fontFamily
                font.pixelSize: 16
            }
            MouseArea {
                id: nm
                anchors.fill: parent
                hoverEnabled: true
                onClicked: svc.step(1)
            }
        }
    }
}
