import Foundation

// MARK: - WaterEntry
// Each tap of a quick-add button creates one entry.
// Entries are grouped by date in AppState computed properties.

struct WaterEntry: Identifiable, Codable {
    var id: UUID   = UUID()
    let amount: Int       // ml
    let date: Date

    init(amount: Int, date: Date = Date()) {
        self.amount = amount
        self.date   = date
    }
}

// MARK: - Quick-add presets shown in WaterTrackingView

enum WaterQuickAdd: Int, CaseIterable, Identifiable {
    case sip    = 150
    case glass  = 250
    case bottle = 500
    case large  = 750

    var id: Int { rawValue }

    var label: String { "\(rawValue) ml" }

    var icon: String {
        switch self {
        case .sip:    return "drop"
        case .glass:  return "cup.and.saucer"
        case .bottle: return "waterbottle"
        case .large:  return "waterbottle.fill"
        }
    }
}
