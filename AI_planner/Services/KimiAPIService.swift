//
//  KimiAPIService.swift
//  AI_planner
//
//  Created by Judy459 on 2/24/26.
//

import Foundation

// MARK: - API Request/Response Models

struct KimiChatRequest: Encodable {
    let model: String
    let messages: [KimiMessage]
    let temperature: Double
    let stream: Bool
}

struct KimiMessage: Codable {
    let role: String   // "system", "user", "assistant"
    let content: String
}

struct KimiChatResponse: Decodable {
    let choices: [KimiChoice]
}

struct KimiChoice: Decodable {
    let message: KimiResponseMessage?
    let delta: KimiResponseMessage?
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message, delta
        case finishReason = "finish_reason"
    }
}

struct KimiResponseMessage: Decodable {
    let role: String?
    let content: String?
}

// MARK: - Error Types

enum KimiAPIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case httpError(statusCode: Int, body: String)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API Key 未配置。请在 Secrets.xcconfig 中设置 MOONSHOT_API_KEY。"
        case .invalidURL:
            return "无效的 API 地址。"
        case .httpError(let code, let body):
            if code == 401 { return "API Key 无效，请检查配置。" }
            if code == 429 { return "请求过于频繁，请稍后再试。" }
            return "服务器错误 (\(code)): \(body)"
        case .decodingError(let error):
            return "响应解析失败: \(error.localizedDescription)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        }
    }
}

// MARK: - Service

class KimiAPIService {
    static let shared = KimiAPIService()
    
    private let endpoint = "https://api.moonshot.cn/v1/chat/completions"
    private let model = "moonshot-v1-32k"
    
    private var apiKey: String? {
        Bundle.main.infoDictionary?["MOONSHOT_API_KEY"] as? String
    }
    
    private init() {}
    
    // MARK: - Streaming Request
    
    func streamChat(messages: [KimiMessage], temperature: Double = 0.6) async throws -> AsyncThrowingStream<String, Error> {
        guard let key = apiKey, !key.isEmpty, !key.contains("your-api-key") else {
            throw KimiAPIError.missingAPIKey
        }
        guard let url = URL(string: endpoint) else {
            throw KimiAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 120
        
        let body = KimiChatRequest(
            model: model,
            messages: messages,
            temperature: temperature,
            stream: true
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw KimiAPIError.networkError(URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to read some error info from the stream
            var errorBody = ""
            for try await line in bytes.lines {
                errorBody += line
                if errorBody.count > 500 { break }
            }
            throw KimiAPIError.httpError(statusCode: httpResponse.statusCode, body: errorBody)
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonString = String(line.dropFirst(6))
                        
                        if jsonString == "[DONE]" {
                            continuation.finish()
                            return
                        }
                        
                        guard let jsonData = jsonString.data(using: .utf8) else { continue }
                        
                        do {
                            let chunk = try JSONDecoder().decode(KimiChatResponse.self, from: jsonData)
                            if let content = chunk.choices.first?.delta?.content {
                                continuation.yield(content)
                            }
                        } catch {
                            // Skip malformed chunks, continue streaming
                            continue
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Non-streaming Request (fallback)
    
    func sendChat(messages: [KimiMessage], temperature: Double = 0.6) async throws -> String {
        guard let key = apiKey, !key.isEmpty, !key.contains("your-api-key") else {
            throw KimiAPIError.missingAPIKey
        }
        guard let url = URL(string: endpoint) else {
            throw KimiAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let body = KimiChatRequest(
            model: model,
            messages: messages,
            temperature: temperature,
            stream: false
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw KimiAPIError.networkError(URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw KimiAPIError.httpError(statusCode: httpResponse.statusCode, body: body)
        }
        
        do {
            let decoded = try JSONDecoder().decode(KimiChatResponse.self, from: data)
            return decoded.choices.first?.message?.content ?? ""
        } catch {
            throw KimiAPIError.decodingError(error)
        }
    }
}
