import Foundation
import SkyfigGenerator

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

do {
    try run(arguments: Array(CommandLine.arguments.dropFirst()))
} catch let error as CLIError {
    writeError(error.description)
    exit(EXIT_FAILURE)
} catch let error as SkyfigValidationError {
    writeError(error.description)
    exit(EXIT_FAILURE)
} catch let error as GeneratorError {
    writeError(error.description)
    exit(EXIT_FAILURE)
} catch {
    writeError(error.localizedDescription)
    exit(EXIT_FAILURE)
}

private func run(arguments: [String]) throws {
    guard let command = arguments.first else { throw CLIError.usage }
    let parsed = try parseOptions(Array(arguments.dropFirst()))

    switch command {
    case "validate":
        let input = try required("input", in: parsed)
        let document = try TokenIO.load(from: URL(fileURLWithPath: input))
        print("Valid Skyfig schema \(document.schemaVersion): \(document.name)")
    case "generate":
        let input = try required("input", in: parsed)
        let output = try required("output", in: parsed)
        let namespace = parsed.values["namespace"] ?? "SkyfigTokens"
        let document = try TokenIO.load(from: URL(fileURLWithPath: input))
        let outputURL = generatedFileURL(for: output)
        try SwiftEmitter.write(document, to: outputURL, namespace: namespace, check: parsed.flags.contains("check"))
        print(parsed.flags.contains("check") ? "Generated source is current: \(outputURL.path)" : "Generated \(outputURL.path)")
    case "normalize-figma", "normalize":
        let input = try required("input", in: parsed)
        let output = try required("output", in: parsed)
        let name = parsed.values["name"] ?? "Skyfig Figma Tokens"
        let document = try FigmaImporter.importVariables(
            from: Data(contentsOf: URL(fileURLWithPath: input)),
            name: name
        )
        try TokenIO.writeCanonical(document, to: URL(fileURLWithPath: output))
        print("Normalized \(output)")
    case "help", "--help", "-h":
        print(usageText)
    default:
        throw CLIError.unknownCommand(command)
    }
}

private struct ParsedOptions {
    var values: [String: String] = [:]
    var flags: Set<String> = []
}

private func parseOptions(_ arguments: [String]) throws -> ParsedOptions {
    var result = ParsedOptions()
    var index = 0
    while index < arguments.count {
        let argument = arguments[index]
        guard argument.hasPrefix("--") else { throw CLIError.unexpectedArgument(argument) }
        let name = String(argument.dropFirst(2))
        if name == "check" {
            result.flags.insert(name)
            index += 1
            continue
        }
        guard index + 1 < arguments.count, !arguments[index + 1].hasPrefix("--") else {
            throw CLIError.missingValue(argument)
        }
        result.values[name] = arguments[index + 1]
        index += 2
    }
    return result
}

private func required(_ name: String, in options: ParsedOptions) throws -> String {
    guard let value = options.values[name] else { throw CLIError.missingOption("--\(name)") }
    return value
}

private func generatedFileURL(for output: String) -> URL {
    let url = URL(fileURLWithPath: output)
    if url.pathExtension == "swift" { return url }
    return url.appendingPathComponent("Tokens.generated.swift")
}

private enum CLIError: Error, CustomStringConvertible {
    case usage
    case unknownCommand(String)
    case unexpectedArgument(String)
    case missingValue(String)
    case missingOption(String)

    var description: String {
        switch self {
    case .usage: usageText()
    case .unknownCommand(let command): "Unknown command: \(command)\n\n\(usageText())"
        case .unexpectedArgument(let argument): "Unexpected argument: \(argument)"
        case .missingValue(let option): "Missing value for \(option)"
        case .missingOption(let option): "Missing required option \(option)"
        }
    }
}

private func usageText() -> String {
    """
Skyfig — Figma design tokens to typed Swift

USAGE
  skyfig validate --input <tokens.json>
  skyfig normalize-figma --input <figma-response.json> --output <tokens.json> [--name <name>]
  skyfig generate --input <tokens.json> --output <file-or-directory> [--namespace <SwiftTypeName>] [--check]
"""
}

private func writeError(_ description: String) {
    let message = "error: " + description + "\n"
    FileHandle.standardError.write(Data(message.utf8))
}
