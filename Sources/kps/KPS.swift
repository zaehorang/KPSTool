import ArgumentParser

@main
struct KPS: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kps",
        abstract: "Korean Problem Solving - Algorithm problem tracking CLI",
        version: "0.1.0",
        subcommands: []
    )
}
