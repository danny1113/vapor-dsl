
# VaporDSL

This is a Swift Package using result builder to build a DSL on top of the [Vapor](https://github.com/vapor/vapor) framework inspired by SwiftUI.

VaporDSL provides a declarative API that allows you to build back-end server with simple and structured syntax, you can understand your server's structure while you code.

> **Important:** There is a similar name called `RoutesBuilder`, which is a protocol provided by the Vapor framework, is different from `RouteBuilder`, which is the result builder of VaporDSL. **This name might be change in the future if a better name that could better represents the RouteBuilder is founded to prevent misunderstanding.**

- [VaporDSL](#vapordsl)
- [How to use](#how-to-use)
  - [Add VaporDSL to your Swift Package dependency](#add-vapordsl-to-your-swift-package-dependency)
  - [Initialize your web application](#initialize-your-web-application)
  - [Design your server structure](#design-your-server-structure)
    - [Group](#group)
    - [Route](#route)
    - [MiddlewareGroup](#middlewaregroup)


# How to use

## Add VaporDSL to your Swift Package dependency

```swift
dependencies: [
    // ...
    .package(name: "VaporDSL", url: "https://github.com/danny1113/vapor-dsl.git", from: "1.0.0")
]
```


## Initialize your web application

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

## Design your server structure

### Group

`Group` is a struct which conforms to the `RouteCollection` protocol, it will group and add all of its child routes. You can create even more complex structure by create a group inside a group.

> **Note:** Initialize `Group` without the `_ path` parameter will has no effect on server structure.

```swift
// root path
Group {
    // api
    Group("api") {
        
        // Route, Controller...
    }
}
```

### Route

Route represents a endpoint on the server, it use `use(method:path:body:closure:)` provided by the Vapor framework to create new route.

> **Note:** Initialize `Route` without the `_ path` parameter will create a route on its parent's root path.

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

You can also group the routes in its own controller, just simply conforms to the `RouteBuildable` protocol.

```swift
struct LoginController: RouteBuildable {
    var body: some RouteBuildable {
        Group {
            Route("login", on: .GET, use: login)
            
            // Group, Route, Controller...
        }
    }
    
    func login(req: Request) async throws -> View {
        return try await req.view.render("login")
    }
}
```

Now you learned how to use `Group` and `Route`, you can composite your server with structure syntax:

```swift
try Application {
    
    // GET /
    Route { req in
        return "Hello, world!"
    }
    
    Group("api") {
        
        // GET /api/status
        Route("status", on: .GET) { req in
            return "ok"
        }
    }
    
    LoginController()
}
.run()
```

### MiddlewareGroup

MiddlewareGroup groups all its routes inside a middleware, you can also chain multiple middlewares together.

```swift
MiddlewareGroup(
    UserAuthenticator(),
    UserModel.guardMiddleware()
) {
    Route("hello") { req in
        return req.view.render("hello")
    }
}
```
