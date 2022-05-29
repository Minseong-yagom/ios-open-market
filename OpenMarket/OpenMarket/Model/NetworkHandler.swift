//
//  URLSeesion.swift
//  OpenMarket
//
//  Created by 두기, minseong on 2022/05/10.
//

import Foundation

struct NetworkHandler {
    private let session: URLSessionProtocol
    private let baseURL = "https://market-training.yagom-academy.kr/"
    
    init(session: URLSessionProtocol = URLSession(configuration: .default)) {
        self.session = session
    }
    
    private func makeURL(api: APIable) -> URL? {
        var component = URLComponents(string: api.host + api.path)
        
        component?.queryItems = api.params?.compactMap {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        return component?.url
    }
    
    func request(api: APIable, response: @escaping (Result<Data?, APIError>) -> Void) {
        guard let url = makeURL(api: api) else {
            return response(.failure(.convertError))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = api.method.string
        
        if api.method == .post {
            for header in api.header {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
            
            request.httpBody = api.data
        }
        
        session.receiveResponse(request: request) { responseResult in
            guard responseResult.error == nil else {
                return response(.failure(.transportError))
            }
            
            guard let statusCode = (responseResult.response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                return response(.failure(.responseError))
            }
            
            switch api.method {
            case .get:
                response(.success(responseResult.data))
            case .post:
                response(.success(responseResult.data))
            case .delete:
                response(.success(responseResult.data))
            case .patch:
                response(.success(responseResult.data))
            }
        }
    }
}
