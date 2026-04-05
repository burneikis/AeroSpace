public struct ListTreeCmdArgs: CmdArgs {
    /*conforms*/ public var commonState: CmdArgsCommonState
    public var fullTree: Bool = false
    public init(rawArgs: StrArrSlice) { self.commonState = .init(rawArgs) }
    public static let parser: CmdParser<Self> = .init(
        kind: .listTree,
        allowInConfig: false,
        help: list_tree_help_generated,
        flags: [
            "--workspace": ArgParser(\.workspaceName, upcastArgParserFun(parseWorkspaceNameSubArg)),
            "--full": trueBoolFlag(\.fullTree),
        ],
        posArgs: [],
    )
}
