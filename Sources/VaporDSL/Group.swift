//
//  Group.swift
//  
//
//  Created by Danny Pang on 2022/6/11.
//

import Vapor


/// Group and add all of its child routes.
///
/// `Group` is a struct which conforms to the `RouteCollection` protocol, it will group and add all of its child routes. You can create even more complex structure by create a group inside a group.
///
/// > Note: Initialize `Group` without the `_ path` parameter will has no effect on server structure.
///
/// ```swift
/// Group("api") {
///     // default HTTPMethod: .GET
///     // GET /api/
///     Route(use: index)
///     
///     // GET /api/todos
///     Route("todos") { req in
///         return req.view.render("todos")
///     }
///     
///     // POST /api/todos
///     Route("todos", on: .POST, use: todo)
/// }
/// ```
@frozen
public struct Group<Content: RouteBuildable>: RouteCollection, RouteBuildable {
    let path: [PathComponent]
    let content: Content
    let then: (RoutesBuilder) throws -> RoutesBuilder
    
    public init(_ path: PathComponent..., @RouteBuilder content: () -> Content, then: @escaping (RoutesBuilder) throws -> RoutesBuilder = { builder in return builder }) {
        self.path = path
        self.content = content()
        self.then = then
    }
    
    public func boot(routes: RoutesBuilder) throws {
        var server = path.isEmpty ? routes : routes.grouped(path)
        server = try then(server)
        
        if let route = content as? Route {
            server.add(route)
        } else {
            try server.register(collection: content)
        }
    }
    
    public var body: some RouteBuildable {
        self
    }
    
}

/// Creates a middleware
///
/// You can apply middlewares to all routes inside using MiddlewareGroup.
///
/// ```swift
/// MiddlewareGroup(
///     UserAuthenticator(),
///     UserModel.guardMiddleware()
/// ) {
///     Group("api") {
///         // Group, Route, Controller...
///         
///     }
/// }
/// ```
@frozen
public struct MiddlewareGroup<Content: RouteBuildable>: RouteCollection, RouteBuildable {
    
    let middlewares: [any Middleware]
    let content: Content
    
    public init(_ middleware: any Middleware..., @RouteBuilder content: () -> Content) {
        self.middlewares = middleware
        self.content = content()
    }
    
    public func boot(routes: RoutesBuilder) throws {
        let server = routes.grouped(middlewares)
        
        if let route = content as? Route {
            server.add(route)
        } else {
            try server.register(collection: content)
        }
    }
    
    public var body: some RouteBuildable {
        self
    }
}
