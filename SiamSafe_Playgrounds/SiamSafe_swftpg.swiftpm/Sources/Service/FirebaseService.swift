import Foundation

@MainActor
protocol EventService {
    func fetchEvents(status: String) async throws -> [DisasterEvent]
    func deleteEvent(id: String) async throws
}

/// Uses the same Firestore collection and security rules as the original app.
/// No Firebase SDK or administrative credentials are required.
final class FirebaseService: EventService {
    private let baseURL = "https://firestore.googleapis.com/v1/projects/siamsafe/databases/(default)/documents"
    private let session: URLSession

    init(session: URLSession = .shared) { self.session = session }

    private func request(_ path: String, method: String, body: [String: Any]? = nil) async throws -> Data {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(response.statusCode) else {
            throw ServiceError.http(response.statusCode)
        }
        return data
    }

    func fetchEvents(status: String = "active") async throws -> [DisasterEvent] {
        guard !RuntimeEnvironment.usesMockServices else { return [] }
        let query: [String: Any] = ["structuredQuery": [
            "from": [["collectionId": "events"]],
            "where": ["fieldFilter": [
                "field": ["fieldPath": "status"], "op": "EQUAL",
                "value": ["stringValue": status]
            ]]
        ]]
        let data = try await request(":runQuery", method: "POST", body: query)
        guard let rows = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw ServiceError.invalidResponse
        }
        return rows.compactMap { row in
            guard let document = row["document"] as? [String: Any] else { return nil }
            return Self.decode(document)
        }
    }

    func addEvent(title: String, description: String, type: DisasterType, severity: Severity,
                  latitude: Double, longitude: Double) async throws -> DisasterEvent {
        let createdAt = Date()
        var id = UUID().uuidString
        if !RuntimeEnvironment.usesMockServices {
            let fields: [String: Any] = [
                "title": ["stringValue": title], "description": ["stringValue": description],
                "type": ["stringValue": type.rawValue], "severity": ["stringValue": severity.rawValue],
                "latitude": ["doubleValue": latitude], "longitude": ["doubleValue": longitude],
                "status": ["stringValue": "active"],
                "createdAt": ["timestampValue": ISO8601DateFormatter().string(from: createdAt)]
            ]
            let data = try await request("/events", method: "POST", body: ["fields": fields])
            guard let document = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let name = document["name"] as? String, let documentID = name.split(separator: "/").last else {
                throw ServiceError.invalidResponse
            }
            id = String(documentID)
        }
        return DisasterEvent(id: id, title: title, description: description, type: type,
                             severity: severity, latitude: latitude, longitude: longitude,
                             createdAt: createdAt, status: "active")
    }

    func deleteEvent(id: String) async throws {
        guard !RuntimeEnvironment.usesMockServices else { return }
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/%?#")
        guard !id.isEmpty, let encoded = id.addingPercentEncoding(withAllowedCharacters: allowed) else {
            throw URLError(.badURL)
        }
        _ = try await request("/events/" + encoded, method: "DELETE")
    }

    static func decode(_ document: [String: Any]) -> DisasterEvent? {
        guard let name = document["name"] as? String,
              let id = name.split(separator: "/").last,
              let fields = document["fields"] as? [String: [String: Any]] else { return nil }
        func string(_ key: String) -> String? { fields[key]?["stringValue"] as? String }
        func number(_ key: String) -> Double? {
            if let value = fields[key]?["doubleValue"] as? NSNumber { return value.doubleValue }
            if let value = fields[key]?["integerValue"] as? String { return Double(value) }
            return nil
        }
        guard let title = string("title"), let description = string("description"),
              let type = string("type").flatMap(DisasterType.init(rawValue:)),
              let severity = string("severity").flatMap(Severity.init(rawValue:)),
              let latitude = number("latitude"), let longitude = number("longitude"),
              let status = string("status"), let timestamp = fields["createdAt"]?["timestampValue"] as? String else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fractionalDate = formatter.date(from: timestamp)
        formatter.formatOptions = [.withInternetDateTime]
        guard let date = fractionalDate ?? formatter.date(from: timestamp) else { return nil }
        return DisasterEvent(id: String(id), title: title, description: description, type: type,
                             severity: severity, latitude: latitude, longitude: longitude,
                             createdAt: date, status: status)
    }

    private enum ServiceError: LocalizedError {
        case http(Int), invalidResponse
        var errorDescription: String? {
            switch self {
            case .http(401), .http(403):
                return "Firebase ไม่อนุญาตการเข้าถึง กรุณาตรวจสอบสิทธิ์ / Firebase access denied. Check authentication and security rules."
            case .http(let status):
                return "เชื่อมต่อ Firebase ไม่สำเร็จ / Firebase request failed (\(status))."
            case .invalidResponse:
                return "รูปแบบข้อมูล Firebase ไม่ถูกต้อง / Invalid Firebase response."
            }
        }
    }
}
