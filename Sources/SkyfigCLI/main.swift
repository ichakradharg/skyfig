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
} catch let error as TokenMergeError {
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
        try validateOptions(parsed, values: ["input"], repeatable: ["input"])
        let inputs = try requiredValues("input", in: parsed)
        let document = try TokenIO.load(from: inputs.map { URL(fileURLWithPath: $0) })
        if inputs.count == 1 {
            print("Valid Skyfig schema \(document.schemaVersion): \(document.name)")
        } else {
            print("Valid \(inputs.count) Skyfig token files using schema \(document.schemaVersion): \(document.name)")
        }
    case "generate":
        try validateOptions(
            parsed,
            values: ["input", "output", "namespace"],
            flags: ["check"],
            repeatable: ["input"]
        )
        let inputs = try requiredValues("input", in: parsed)
        let output = try requiredSingleValue("output", in: parsed)
        let namespace = parsed.values["namespace"]?.last ?? "SkyfigTokens"
        let document = try TokenIO.load(from: inputs.map { URL(fileURLWithPath: $0) })
        let outputURL = generatedFileURL(for: output)
        try SwiftEmitter.write(document, to: outputURL, namespace: namespace, check: parsed.flags.contains("check"))
        let message = parsed.flags.contains("check")
            ? "Generated source is current: \(outputURL.path)"
            : "Generated \(outputURL.path)"
        print(message)
    case "normalize-figma", "normalize":
        try validateOptions(parsed, values: ["input", "output", "name"])
        let input = try requiredSingleValue("input", in: parsed)
        let output = try requiredSingleValue("output", in: parsed)
        let name = parsed.values["name"]?.last ?? "Skyfig Figma Tokens"
        let document = try FigmaImporter.importVariables(
            from: Data(contentsOf: URL(fileURLWithPath: input)),
            name: name
        )
        try TokenIO.writeCanonical(document, to: URL(fileURLWithPath: output))
        print("Normalized \(output)")
    case "help", "--help", "-h":
        try validateOptions(parsed)
        print(usageText)
    default:
        throw CLIError.unknownCommand(command)
    }
}

private struct ParsedOptions {
    var values: [String: [String]] = [:]
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
        result.values[name, default: []].append(arguments[index + 1])
        index += 2
    }
    return result
}

private func validateOptions(
    _ options: ParsedOptions,
    values allowedValues: Set<String> = [],
    flags allowedFlags: Set<String> = [],
    repeatable repeatableValues: Set<String> = []
) throws {
    for name in options.values.keys.sorted() where !allowedValues.contains(name) {
        throw CLIError.unknownOption("--\(name)")
    }
    for name in options.flags.sorted() where !allowedFlags.contains(name) {
        throw CLIError.unknownOption("--\(name)")
    }
    for name in options.values.keys.sorted() where !repeatableValues.contains(name) {
        if options.values[name, default: []].count > 1 {
            throw CLIError.repeatedOption("--\(name)")
        }
    }
}

private func requiredValues(_ name: String, in options: ParsedOptions) throws -> [String] {
    guard let values = options.values[name], !values.isEmpty else {
        throw CLIError.missingOption("--\(name)")
    }
    return values
}

private func requiredSingleValue(_ name: String, in options: ParsedOptions) throws -> String {
    let values = try requiredValues(name, in: options)
    guard values.count == 1 else { throw CLIError.repeatedOption("--\(name)") }
    return values[0]
}

private func generatedFileURL(for output: String) -> URL {
    let url = URL(fileURLWithPath: output)
    if url.pathExtension == "swift" { return url }
    return url.appendingPathComponent("Tokens.generated.swift")
}

private enum CLIError: Error, CustomStringConvertible {
    case usage
    case unknownCommand(String)
    case unknownOption(String)
    case unexpectedArgument(String)
    case missingValue(String)
    case missingOption(String)
    case repeatedOption(String)

    var description: String {
        switch self {
    case .usage: usageText()
    case .unknownCommand(let command): "Unknown command: \(command)\n\n\(usageText())"
        case .unknownOption(let option): "Unknown option: \(option)"
        case .unexpectedArgument(let argument): "Unexpected argument: \(argument)"
        case .missingValue(let option): "Missing value for \(option)"
        case .missingOption(let option): "Missing required option \(option)"
        case .repeatedOption(let option): "Option may only be provided once: \(option)"
        }
    }
}

private func usageText() -> String {
    """
Skyfig — Figma design tokens to typed Swift

USAGE
  skyfig validate --input <tokens.json> [--input <more-tokens.json> ...]
  skyfig normalize-figma --input <figma-response.json> --output <tokens.json> [--name <name>]
  skyfig generate --input <tokens.json> [--input <more-tokens.json> ...] --output <file-or-directory>
      [--namespace <SwiftTypeName>] [--check]
"""
}

private func writeError(_ description: String) {
    let message = "error: " + description + "\n"
    FileHandle.standardError.write(Data(message.utf8))
}
