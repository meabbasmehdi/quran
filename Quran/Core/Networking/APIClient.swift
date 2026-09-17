import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let code: Int
    let status: String
    let data: T
}

actor APIClient {
    static let shared = APIClient()
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(
            url: endpoint.url,
            cachePolicy: .reloadRevalidatingCacheData,
            timeoutInterval: endpoint.timeoutInterval
        )
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Quran-tvOS/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw QuranError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw QuranError.decodingFailed
                }
            case 500...599:
                throw QuranError.serverError(httpResponse.statusCode)
            default:
                throw QuranError.invalidResponse
            }
            
        } catch let error as QuranError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw QuranError.noInternet
            case .timedOut:
                throw QuranError.timeout
            default:
                throw QuranError.unknown
            }
        } catch {
            throw QuranError.unknown
        }
    }
    
    func fetchAPIResponse<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let response: APIResponse<T> = try await fetch(endpoint)
        return response.data
    }
}
