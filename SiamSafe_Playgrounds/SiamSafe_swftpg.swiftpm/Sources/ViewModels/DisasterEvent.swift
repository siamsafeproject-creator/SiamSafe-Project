import Foundation

// MARK: - Disaster Event

struct DisasterEvent: Identifiable {
    
    let id: String
    let title: String
    let description: String
    let type: DisasterType
    let severity: Severity
    let latitude: Double
    let longitude: Double
    let createdAt: Date
    let status: String
}

// MARK: - Disaster Type

enum DisasterType: String, CaseIterable, Identifiable {
    
    case flood
    case fire
    case landslide
    case storm
    case earthquake
    case other
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .flood:
            return "น้ำท่วม"
        case .fire:
            return "ไฟไหม้"
        case .landslide:
            return "ดินถล่ม"
        case .storm:
            return "พายุ"
        case .earthquake:
            return "แผ่นดินไหว"
        case .other:
            return "อื่น ๆ"
        }
    }
}

// MARK: - Severity

enum Severity: String, CaseIterable, Identifiable {
    
    case low
    case medium
    case high
    case critical
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .low:
            return "ต่ำ"
        case .medium:
            return "ปานกลาง"
        case .high:
            return "สูง"
        case .critical:
            return "วิกฤต"
        }
    }
}
