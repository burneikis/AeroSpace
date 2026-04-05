import AppKit
import Common

struct ListTreeCommand: Command {
    let args: ListTreeCmdArgs
    /*conforms*/ let shouldResetClosedWindowsCache = false

    func run(_ env: CmdEnv, _ io: CmdIo) async throws -> Bool {
        let workspaces: [Workspace]
        if let workspaceName = args.workspaceName {
            workspaces = [Workspace.get(byName: workspaceName.raw)]
        } else {
            workspaces = Workspace.all
        }

        for workspace in workspaces {
            let monitor = workspace.workspaceMonitor
            io.out("Workspace '\(workspace.name)' (monitor: \(monitor.name))")
            try await printTreeNode(workspace.rootTilingContainer, indent: "  ", io: io)

            let floatingWindows = workspace.floatingWindows
            if !floatingWindows.isEmpty {
                io.out("  [floating]")
                for window in floatingWindows {
                    let title = try await window.title
                    let appName = window.app.name ?? "unknown"
                    io.out("    window(\(window.windowId)) \(appName) - \(title)")
                }
            }

            let fullscreenWindows = workspace.macOsNativeFullscreenWindowsContainer.children
            if !fullscreenWindows.isEmpty {
                io.out("  [fullscreen]")
                for child in fullscreenWindows {
                    if let window = child as? Window {
                        let title = try await window.title
                        let appName = window.app.name ?? "unknown"
                        io.out("    window(\(window.windowId)) \(appName) - \(title)")
                    }
                }
            }

            let hiddenWindows = workspace.macOsNativeHiddenAppsWindowsContainer.children
            if !hiddenWindows.isEmpty {
                io.out("  [hidden]")
                for child in hiddenWindows {
                    if let window = child as? Window {
                        let title = try await window.title
                        let appName = window.app.name ?? "unknown"
                        io.out("    window(\(window.windowId)) \(appName) - \(title)")
                    }
                }
            }
        }
        return true
    }

    @MainActor
    private func printTreeNode(_ node: TreeNode, indent: String, io: CmdIo) async throws {
        switch node.nodeCases {
        case .tilingContainer(let container):
            let layoutDesc = "\(container.layout)(\(container.orientation))"
            io.out("\(indent)\(layoutDesc)")
            for child in container.children {
                try await printTreeNode(child, indent: indent + "  ", io: io)
            }
        case .window(let window):
            let title = try await window.title
            let appName = window.app.name ?? "unknown"
            io.out("\(indent)window(\(window.windowId)) \(appName) - \(title)")
        case .workspace, .macosMinimizedWindowsContainer,
             .macosHiddenAppsWindowsContainer, .macosFullscreenWindowsContainer,
             .macosPopupWindowsContainer:
            break
        }
    }
}
