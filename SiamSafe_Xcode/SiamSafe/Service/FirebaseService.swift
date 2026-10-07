import Foundation
import FirebaseFirestore

@MainActor
protocol EventService {
    func fetchEvents(status: String) async throws -> [DisasterEvent]
    func deleteEvent(id: String) async throws
}

final class FirebaseService: EventService {

    private lazy var db = Firestore.firestore()

    private var isRunningInPreview: Bool {
        RuntimeEnvironment.usesMockServices
    }
    
    // MARK: - Add Event
    
    func addEvent(
        title: String,
        description: String,
        type: DisasterType,
        severity: Severity,
        latitude: Double,
        longitude: Double
    ) async throws -> DisasterEvent {
        let createdAt = Date()
        let id: String
        if isRunningInPreview {
            id = UUID().uuidString
        } else {
            let event: [String: Any] = [
            
                "title": title,
                "description": description,
            
                "type": type.rawValue,
                "severity": severity.rawValue,
            
                "latitude": latitude,
                "longitude": longitude,
            
                "status": "active",
            
                "createdAt": Timestamp(date: createdAt)
            ]
        
            let document = try await db
                .collection("events")
                .addDocument(data: event)
            id = document.documentID
        }
        return DisasterEvent(
            id: id, title: title, description: description, type: type,
            severity: severity, latitude: latitude, longitude: longitude,
            createdAt: createdAt, status: "active"
        )
    }
    
    // MARK: - Get Events
    
    func fetchEvents(status: String = "active") async throws -> [DisasterEvent] {
        guard !isRunningInPreview else { return [] }
        
        let snapshot = try await db
            .collection("events")
            .whereField("status", isEqualTo: status)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            
            let data = document.data()
            
            guard
                let title = data["title"] as? String,
                let description = data["description"] as? String,
                let typeRaw = data["type"] as? String,
                let severityRaw = data["severity"] as? String,
                let latitude = data["latitude"] as? Double,
                let longitude = data["longitude"] as? Double,
                let status = data["status"] as? String,
                let timestamp = data["createdAt"] as? Timestamp
            else {
                return nil
            }
            
            guard
                let type = DisasterType(rawValue: typeRaw),
                let severity = Severity(rawValue: severityRaw)
            else {
                return nil
            }
            
            return DisasterEvent(
                id: document.documentID,
                title: title,
                description: description,
                type: type,
                severity: severity,
                latitude: latitude,
                longitude: longitude,
                createdAt: timestamp.dateValue(),
                status: status
            )
        }
    }
    
    func deleteEvent(id: String) async throws {
        guard !isRunningInPreview else { return }
        try await db
            .collection("events")
            .document(id)
            .delete()
    }
}
