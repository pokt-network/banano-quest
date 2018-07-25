//
//  ValueTransformer.swift
//  banano-quest
//
//  Created by Luis De Leon on 7/25/18.
//  Copyright © 2018 Michael O'Rourke. All rights reserved.
//  Creadit to: https://gist.github.com/tomduckering/6976e984f575249b7f66320ac1d978f2

import Foundation

private class BasicValueTransformer: ValueTransformer {
    let transform: (AnyObject?) -> (AnyObject?)
    
    init(transform: @escaping (AnyObject?) -> (AnyObject?)) {
        self.transform = transform
    }
    
    // MARK: NSValueTransformer
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSObject.self
    }
    
    func transformedValue(value: AnyObject?) -> AnyObject? {
        return transform(value)
    }
}

private class ReversibleValueTransformer: BasicValueTransformer {
    let reverseTransform: (AnyObject?) -> (AnyObject?)
    
    init(transform: @escaping (AnyObject?) -> (AnyObject?), reverseTransform: @escaping (AnyObject?) -> (AnyObject?)) {
        self.reverseTransform = reverseTransform
        super.init(transform: transform)
    }
    
    // MARK: NSValueTransformer
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        return reverseTransform(value)
    }
}

public extension ValueTransformer {
    /**
     Registers a value transformer with a given name and transform function.
     :param: name The name of the transformer.
     :param: transform The function that performs the transformation.
     */
    class func setValueTransformerWithName<T, U>(name: String, transform: @escaping (T) -> (U?)) {
        let transformer = BasicValueTransformer { value in
            return (value as? T).flatMap {
                transform($0) as? AnyObject
            }
        }
        
        self.setValueTransformer(transformer, forName: NSValueTransformerName(name))
    }
    
    /**
     Registers a reversible value transformer with a given name and transform functions.
     :param: name The name of the transformer.
     :param: transform The function that performs the forward transformation.
     :param: reverseTransform The function that performs the reverse transformation.
     */
    class func setValueTransformerWithName<T, U>(name: String, transform: @escaping (T) -> (U?), reverseTransform: @escaping (U) -> (T?)) {
        let transformer = ReversibleValueTransformer(transform: { value in
            return (value as? T).flatMap {
                transform($0) as? AnyObject
            }
        }, reverseTransform: { value in
            return (value as? U).flatMap {
                reverseTransform($0) as? AnyObject
            }
        })
        
        self.setValueTransformer(transformer, forName: NSValueTransformerName(name))
    }
}
