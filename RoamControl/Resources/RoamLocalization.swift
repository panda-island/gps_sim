import Foundation

/// Localizes runtime-generated user-facing messages while preserving English
/// as the fallback for messages that are not present in the translation table.
func roamLocalized(_ message: String) -> String {
    String(localized: String.LocalizationValue(message))
}
