//
//  Application+init.swift
//  
//
//  Created by Danny Pang on 2022/6/11.
//

import Vapor


extension Application {
    /**
     Creates a `Application` instance and register all routes inside its build block.
     
     You can create your entire web application just by writing your code inside the `Application` content closure. You can also do additional setup like Leaf, Fluent, Middlewares after initialize the application inside `then()` function.
     
     ```swift
     try Application {
        // Group, Route, Controller...
     
     }
     .then { app in
        print(app.routes.all)
     
        // other additional setup...
     }
     .run()
     ```
     
     Or if you're using the template provided by Vapor, because `Group` conforms to the `RouteCollection` protocol provided by Vapor, you can register it directly.
     
     ```swift
     func routes(_ app: Application) throws {
        let collection = Group {
            // Group, Route, Controller...
     
        }
     
        try app.register(collection: collection)
     }
     ```
     **/
    public convenience init<Content: RouteBuildable>(
        _ environment: Environment = .development,
        _ eventLoopGroupProvider: EventLoopGroupProvider = .createNew,
        @RouteBuilder content: () -> Content
    ) throws {
        self.init(environment, eventLoopGroupProvider)
        let collection = content()
        Swift.print("Applicatio register ", collection)
        try register(collection: collection.body)
    }
    
    public func then(_ closure: @escaping (Application) throws -> ()) -> Application {
        do {
            try closure(self)
        } catch {
            print(error)
            print("Application shutdown")
            shutdown()
        }
        return self
    }
    
    public func routes() -> Application {
        print(self.routes.all)
        return self
    }
    
    public func middleware(_ middleware: any Middleware, at position: Middlewares.Position = .end) -> Application {
        self.middleware.use(middleware, at: position)
        return self
    }
    
}
