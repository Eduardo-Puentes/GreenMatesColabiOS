import Foundation

class GreenMatesApi {
    static let shared = GreenMatesApi()
    private let baseURL = "http://10.50.90.159:3000"
    
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: T? = nil,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                request.httpBody = try jsonEncoder.encode(body)
            } catch {
                completion(.failure(error))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    // MARK: - API Calls
    
    // Get User
    func getUser(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        makeRequest(endpoint: "/api/collaborator/\(uid)") { result in
            switch result {
            case .success(let data):
                do {
                    let userResponse = try self.jsonDecoder.decode(UserResponse.self, from: data)
                    completion(.success(userResponse.collaborator))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Create User
    func createUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(endpoint: "/api/collaborator", method: "POST", body: user) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Add Workshop
    func addWorkshop(taller: Taller, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(endpoint: "/api/course", method: "POST", body: taller) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Add Recolecta
    func addRecolecta(recolecta: Recolecta, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(endpoint: "/api/recollect", method: "POST", body: recolecta) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get Courses
    func getCourses(uid: String, completion: @escaping (Result<[getTaller], Error>) -> Void) {
        makeRequest(endpoint: "/api/course/collaborator_courses/\(uid)") { result in
            switch result {
            case .success(let data):
                do {
                    let courses = try self.jsonDecoder.decode([getTaller].self, from: data)
                    completion(.success(courses))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get Recolectas
    func getRecolectas(uid: String, completion: @escaping (Result<[getRecolecta], Error>) -> Void) {
        makeRequest(endpoint: "/api/recollect/collaborator_recollects/\(uid)") { result in
            switch result {
            case .success(let data):
                do {
                    let recolectas = try self.jsonDecoder.decode([getRecolecta].self, from: data)
                    completion(.success(recolectas))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Add to Recolecta
    func addToRecolecta(recollectId: String, body: RecolectaRequestBody, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(endpoint: "/api/recollect/add_to_recollect/\(recollectId)", method: "PATCH", body: body) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Add Assistance
    func addAssistance(courseId: String, body: TallerRequestBody, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(endpoint: "/api/course/add_assistant/\(courseId)", method: "PATCH", body: body) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
