import QtQuick
import Quickshell.Io

QtObject {
    id: svc
    required property var host

    property var presets: []         // [name]
    property string rawList: ""
    property string wallpaper: ""
    readonly property string current: host.settings.last
    readonly property var ipc: ["qs", "-c", "sekaipop", "ipc", "call"]
    readonly property var base: ipc.concat(["presets"])

    function parseList(text) {
        var out = [];
        text = (text || "").trim();
        if (text === "") return out;
        try {
            var j = JSON.parse(text);
            if (Array.isArray(j)) {
                for (var i = 0; i < j.length; i++) {
                    var e = j[i];
                    if (typeof e === "string") out.push(e);
                    else if (e && e.name) out.push(String(e.name));
                }
                return out;
            }
        } catch (err) {}
        var lines = text.split("\n");
        for (var k = 0; k < lines.length; k++) {
            var l = lines[k].replace(/^[\s*>\-•›★☆]+/, "").trim();
            if (l !== "") out.push(l);
        }
        return out;
    }

    function step(dir) {
        if (presets.length === 0) return;
        var idx = presets.indexOf(current);
        if (idx < 0) idx = dir > 0 ? -1 : 0;
        idx = (idx + dir + presets.length) % presets.length;
        var name = presets[idx];
        host.setSetting("last", name);
        applyProc.command = base.concat(["apply", name]);
        applyProc.running = true;
    }

    function refresh() {
        listProc.running = true;
        if (host.settings.mode === "image" && host.settings.image === "")
            wallProc.running = true;
    }

    property Process listProc: Process {
        command: svc.base.concat(["list"])
        stdout: StdioCollector {
            onStreamFinished: { svc.rawList = text; svc.presets = svc.parseList(text); }
        }
    }
    property Process wallProc: Process {
        command: svc.ipc.concat(["wallpaper", "get"])
        stdout: StdioCollector {
            onStreamFinished: svc.wallpaper = text.trim()
        }
    }
    property Process applyProc: Process {
        onExited: svc.refresh()
    }
    property Timer poll: Timer {
        running: host.working
        repeat: true
        triggeredOnStart: true
        interval: 10000
        onTriggered: svc.refresh()
    }
}
