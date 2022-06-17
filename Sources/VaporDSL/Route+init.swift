//
//  Route+init.swift
//  
//
//  Created by Danny Pang on 2022/6/11.
//

import Vapor


public extension Route {
    /**
     Creates a endpoint on the server.
     
     Route represents a endpoint on the server, it use `use(method:path:body:closure:)` provided by the Vapor framework to create new route.
     
     > Note: Initialize `Route` without the `_ path` parameter will create a route on its parent's root path.
     
     ```swift
     Group("api") {
     
        // default HTTPMethod: .GET
        // GET /api/
        Route(use: index)
     
        // GET /api/todos
        Route("todos") { req in
            return req.view.render("todos")
        }
     
        // POST /api/todos
        Route("todos", on: .POST, use: todo)
     }
     ```
     **/
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    convenience init<Response: AsyncResponseEncodable>(
        _ path: PathComponent...,
        on method: HTTPMethod = .GET,
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @escaping (Request) async throws -> Response
    ) {
        
        let responder = AsyncBasicResponder { request in
            if case .collect(let max) = body, request.body.data == nil {
                _ = try await request.body.collect(max: max?.value ?? request.application.routes.defaultMaxBodySize.value).get()
                
            }
            return try await closure(request).encodeResponse(for: request)
        }
        
        self.init(method: method, path: path, responder: responder, requestType: Request.self, responseType: Response.self)
    }
    
    /**
     Creates a endpoint on the server.
     
     Route represents a endpoint on the server, it use `use(method:path:body:closure:)` provided by the Vapor framework to create new route.
     
     > Note: Initialize `Route` without the `_ path` parameter will create a route on its parent's root path.
     
     ```swift
     Group("api") {
         // default HTTPMethod: .GET
         // GET /api/
         Route(use: index)
         
         // GET /api/todos
         Route("todos") { req in
            return req.view.render("todos")
         }
         
         // POST /api/todos
         Route("todos", on: .POST, use: todo)
     }
     ```
     **/
    convenience init<Response: ResponseEncodable>(
        _ path: PathComponent...,
        on method: HTTPMethod = .GET,
        body: HTTPBodyStreamStrategy = .collect,
        use closure: @escaping (Request) throws -> Response
    ) {
        
        let responder = BasicResponder { request in
            if case .collect(let max) = body, request.body.data == nil {
                return request.body.collect(
                    max: max?.value ?? request.application.routes.defaultMaxBodySize.value
                ).flatMapThrowing { _ in
                    try closure(request)
                }.encodeResponse(for: request)
            } else {
                return try closure(request)
                    .encodeResponse(for: request)
            }
        }
        
        self.init(method: method, path: path, responder: responder, requestType: Request.self, responseType: Response.self)
    }
}

extension Route: RouteBuildable {
    public var body: some RouteBuildable {
        self
    }
}
