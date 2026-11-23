import QtQuick

Item {
    id: root
    required property var host
    readonly property var svc: host.service
    readonly property var t: host.theme
    readonly property var s: host.settings

    readonly property bool imageMode: s.mode === "image"
    readonly property bool fullLayout: s.imageLayout === "full"
    readonly property string imagePath: s.image !== "" ? s.image : svc.wallpaper
    readonly property string imageUrl: imagePath === "" ? ""
        : ((imagePath.indexOf("file://") === 0 || imagePath.indexOf("http") === 0)
           ? imagePath : "file://" + imagePath)
    readonly property bool imageOnBackground: imageMode && fullLayout && imageUrl !== ""

    implicitWidth: s.width
    implicitHeight: s.height

    function isImageFile(u) {
        return /\.(png|jpe?g|webp|gif|bmp|svg|avif)$/i.test(u.split("?")[0]);
    }

    // image / swatch stage: the top strip, or the whole card
    Item {
        id: stage
        x: root.fullLayout && root.imageMode ? 0 : 12
        y: root.fullLayout && root.imageMode ? 0 : 12
        width: root.fullLayout && root.imageMode ? root.width : root.width - 24
        height: root.fullLayout && root.imageMode ? root.height : Math.max(24, root.height * 0.35)
        clip: true

        Row {
            id: swatches
            visible: !root.imageMode
            anchors.fill: parent
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

        Image {
            id: pic
            visible: root.imageMode
            source: root.imageMode ? root.imageUrl : ""
            asynchronous: true
            sourceSize.width: 1600
            readonly property bool custom: root.s.imageFit === "custom"
            width: custom ? root.s.imageWidth : stage.width
            height: custom ? root.s.imageHeight : stage.height
            x: (stage.width - width) / 2 + (custom ? root.s.imageX : 0)
            y: (stage.height - height) / 2 + (custom ? root.s.imageY : 0)
            fillMode: root.s.imageFit === "contain" ? Image.PreserveAspectFit
                    : root.s.imageFit === "cover" ? Image.PreserveAspectCrop
                    : Image.Stretch
        }

        Rectangle {
            visible: root.imageMode && !root.fullLayout
            anchors.fill: parent
            color: "transparent"
            border.width: 1
            border.color: t.pLine
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

        Rectangle {
            width: parent.width - 2 * 36 - 2 * 8
            height: 36
            radius: 8
            color: root.imageOnBackground ? Qt.alpha(t.pSurface, 0.8) : "transparent"

            Text {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
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

    // drop an image file on the widget
    DropArea {
        id: drop
        anchors.fill: parent
        onEntered: (event) => {
            var ok = event.hasUrls && event.urls.length > 0
                     && root.isImageFile(event.urls[0].toString());
            event.accepted = ok;
        }
        onDropped: (event) => {
            if (!event.hasUrls || event.urls.length === 0) return;
            var u = event.urls[0].toString();
            if (!root.isImageFile(u)) return;
            event.accept(Qt.CopyAction);
            root.host.setSetting("image", u);
            root.host.setSetting("mode", "image");
        }

        Rectangle {
            anchors.fill: parent
            visible: drop.containsDrag
            color: "transparent"
            border.width: 2
            border.color: t.accentCyan
            radius: t.radiusOuter
        }
    }
}
