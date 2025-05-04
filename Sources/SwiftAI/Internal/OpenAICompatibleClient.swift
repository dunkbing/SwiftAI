import Foundation

/// Internal client to handle logic common to OpenAI-compatible APIs.
internal final class OpenAICompatibleClient {
    private let apiKey: String
    private let apiBaseURL: URL
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init(apiKey: String, baseURL: URL, urlSession: URLSession) {
        self.apiKey = apiKey
        self.apiBaseURL = baseURL
        self.urlSession = urlSession

        // Setup JSON coder/decoder (same as before)
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func generateTextInternal(model: String, messages: [ChatMessage], options: RequestOptions?) async throws -> String {
        let requestBody = OpenAIRequest(model: model, messages: messages, stream: false, options: options)
        let request = try createURLRequest(path: "/chat/completions", body: requestBody)

        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.networkError(URLError(.badServerResponse))
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown API Error"
                throw AIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
            }

            let openAIResponse = try jsonDecoder.decode(OpenAIResponse.self, from: data)
            guard let firstChoiceContent = openAIResponse.choices.first?.message.content else {
                 throw AIError.responseParsingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "No content found in response choices.")))
            }
            return firstChoiceContent

        } catch let error as AIError {
            throw error
        } catch let error as DecodingError {
            throw AIError.responseParsingError(error)
        } catch {
            throw AIError.networkError(error)
        }
    }

    func streamTextInternal(model: String, messages: [ChatMessage], options: RequestOptions?) async throws -> AsyncThrowingStream<AIStreamChunk, Error> {
        let requestBody = OpenAIRequest(model: model, messages: messages, stream: true, options: options)
        let request = try createURLRequest(path: "/chat/completions", body: requestBody)

        let (byteStream, response) = try await urlSession.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.networkError(URLError(.badServerResponse))
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            var errorData = Data()
            // Simple error body reading
            for try await byte in byteStream { errorData.append(byte); if errorData.count > 1024 { break } }
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown API Error during streaming"
            throw AIError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        return AsyncThrowingStream<AIStreamChunk, Error> { continuation in
            Task {
                do {
                    for try await line in byteStream.lines {
                        if line.hasPrefix("data: "), let data = line.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8) {
                             if String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" {
                                continuation.finish()
                                return
                            }
                            do {
                                let chunk = try self.jsonDecoder.decode(OpenAIStreamChunk.self, from: data)
                                if let textDelta = chunk.choices.first?.delta.content, !textDelta.isEmpty {
                                    let isFinal = chunk.choices.first?.finish_reason != nil
                                    let streamChunk = AIStreamChunk(textDelta: textDelta, id: chunk.id, isFinal: isFinal, rawProviderResponse: data)
                                    continuation.yield(streamChunk)
                                } else if chunk.choices.first?.finish_reason != nil {
                                     let streamChunk = AIStreamChunk(textDelta: "", id: chunk.id, isFinal: true, rawProviderResponse: data)
                                     continuation.yield(streamChunk)
                                }
                                if chunk.choices.first?.finish_reason != nil {
                                    continuation.finish()
                                    return
                                }
                            } catch let decodingError as DecodingError {
                                print("SSE Decoding Error: \(decodingError)")
                                print("Problematic Data: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8")")
                            } catch {
                                continuation.finish(throwing: AIError.streamingError("Error processing stream chunk: \(error.localizedDescription)"))
                                return
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: AIError.networkError(error))
                }
            }
        }
    }


    private func createURLRequest<Body: Encodable>(path: String, body: Body) throws -> URLRequest {
        let url = apiBaseURL.appendingPathComponent(path) // Uses the baseURL passed during init
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try jsonEncoder.encode(body)
        } catch {
            throw AIError.responseParsingError(error)
        }
        return request
    }
}
