//
//  GreenMatesApi.swift
//  GreenMatesColab
//
//  Created by base on 17/11/24.
//


import Foundation

struct EmptyResponse: Codable {}


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
    
    private func makeRequest<Response: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Codable? = nil,
        responseType: Response.Type,
        completion: @escaping (Result<Response, Error>) -> Void
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

            print("Raw data from \(endpoint):", String(data: data, encoding: .utf8) ?? "Invalid UTF-8")

            do {
                let decodedResponse = try self.jsonDecoder.decode(Response.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error:", error)
                completion(.failure(error))
            }
        }
        task.resume()
    }

    
    // MARK: - API Calls
    
    // Get User
    func getUser(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        makeRequest(
            endpoint: "/api/collaborator/\(uid)",
            responseType: UserResponse.self
        ) { result in
            switch result {
            case .success(let userResponse):
                completion(.success(userResponse.collaborator))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Create User
    func createUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(
            endpoint: "/api/collaborator",
            method: "POST",
            body: user,
            responseType: EmptyResponse.self // A helper type for empty responses
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addWorkshop(taller: Taller, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(
            endpoint: "/api/course",
            method: "POST",
            body: taller,
            responseType: EmptyResponse.self
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addRecolecta(recolecta: Recolecta, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(
            endpoint: "/api/recollect",
            method: "POST",
            body: recolecta,
            responseType: EmptyResponse.self
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCourses(uid: String, completion: @escaping (Result<[getTaller], Error>) -> Void) {
        makeRequest(
            endpoint: "/api/course/collaborator_courses/\(uid)",
            responseType: [getTaller].self
        ) { result in
            switch result {
            case .success(let courses):
                print("Fetched Courses: \(courses)") // Debugging line
                completion(.success(courses))
            case .failure(let error):
                print("Error fetching courses: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }


    
    // Get Recolectas
    func getRecolectas(uid: String, completion: @escaping (Result<[getRecolecta], Error>) -> Void) {
        makeRequest(
            endpoint: "/api/recollect/collaborator_recollects/\(uid)",
            responseType: [getRecolecta].self
        ) { result in
            switch result {
            case .success(let recolectas):
                completion(.success(recolectas))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    func addToRecolecta(recollectId: String, body: RecolectaRequestBody, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(
            endpoint: "/api/recollect/add_to_recollect/\(recollectId)",
            method: "PATCH",
            body: body,
            responseType: EmptyResponse.self
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addAssistance(courseId: String, body: TallerRequestBody, completion: @escaping (Result<Void, Error>) -> Void) {
        makeRequest(
            endpoint: "/api/course/add_assistant/\(courseId)",
            method: "PATCH",
            body: body,
            responseType: EmptyResponse.self
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
