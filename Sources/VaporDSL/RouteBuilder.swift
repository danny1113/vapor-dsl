//
//  RouteBuilder.swift
//  
//
//  Created by Danny Pang on 2022/6/11.
//

import Vapor


@resultBuilder
public enum RouteBuilder {
    
    public static func buildBlock<Content: RouteBuildable>(_ components: Content) -> Content {
        return components
    }
    
    public static func buildEither<Content: RouteBuildable>(first component: Content) -> Content {
        return component
    }
    
    public static func buildEither<Content: RouteBuildable>(second component: Content) -> Content {
        return component
    }
    
#if swift(>=5.7)
    // TODO - buildPartialBlock
#endif
}

public extension RouteBuilder {
    static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleRoute<(C0, C1)>
    where C0: RouteBuildable, C1: RouteBuildable {
        TupleRoute((c0, c1))
    }
    
    static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleRoute<(C0, C1, C2)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable {
        TupleRoute((c0, c1, c2))
    }
    
    static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleRoute<(C0, C1, C2, C3)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable, C3: RouteBuildable {
        TupleRoute((c0, c1, c2, c3))
    }
    
    static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleRoute<(C0, C1, C2, C3, C4)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable, C3: RouteBuildable, C4: RouteBuildable {
        TupleRoute((c0, c1, c2, c3, c4))
    }
    
    static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleRoute<(C0, C1, C2, C3, C4, C5)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable, C3: RouteBuildable, C4: RouteBuildable, C5: RouteBuildable {
        TupleRoute((c0, c1, c2, c3, c4, c5))
    }
    
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleRoute<(C0, C1, C2, C3, C4, C5, C6)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable, C3: RouteBuildable, C4: RouteBuildable, C5: RouteBuildable, C6: RouteBuildable {
        TupleRoute((c0, c1, c2, c3, c4, c5, c6))
    }
    
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleRoute<(C0, C1, C2, C3, C4, C5, C6, C7)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable, C3: RouteBuildable, C4: RouteBuildable, C5: RouteBuildable, C6: RouteBuildable, C7: RouteBuildable {
        TupleRoute((c0, c1, c2, c3, c4, c5, c6, c7))
    }
    
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleRoute<(C0, C1, C2, C3, C4, C5, C6, C7, C8)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable, C3: RouteBuildable, C4: RouteBuildable, C5: RouteBuildable, C6: RouteBuildable, C7: RouteBuildable, C8: RouteBuildable {
        TupleRoute((c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }
    
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleRoute<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>
    where C0: RouteBuildable, C1: RouteBuildable, C2: RouteBuildable, C3: RouteBuildable, C4: RouteBuildable, C5: RouteBuildable, C6: RouteBuildable, C7: RouteBuildable, C8: RouteBuildable, C9: RouteBuildable {
        TupleRoute((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
    }
}

extension Never: RouteBuildable {
    public typealias Body = Never
    public var body: Never { fatalError() }
}

public struct TupleRoute<T>: RouteBuildable, RouteCollection {
    let value: T
    
    public init(_ content: T) {
        self.value = content
    }
    
    public var body: some RouteBuildable {
        self
    }
    
    public func boot(routes: RoutesBuilder) throws {
        // Convert tuple to [Any]
        let tupleMirror = Mirror(reflecting: value)
        let tupleElements = tupleMirror.children.map(\.value)
        
        for element in tupleElements {
            if let route = element as? Route {
                routes.add(route)
            } else if let collection = element as? RouteCollection {
                try routes.register(collection: collection)
            }
        }
    }
}


public protocol RouteBuildable: RouteCollection {
    associatedtype Body: RouteBuildable
    
    @RouteBuilder var body: Self.Body { get }
}

public extension RouteBuildable {
    func boot(routes: RoutesBuilder) throws {
        try routes.register(collection: body)
    }
}

public extension RouteBuildable {
    func debug() -> some RouteBuildable {
        let _ = print(Mirror(reflecting: self).subjectType)
        return self
    }
}
