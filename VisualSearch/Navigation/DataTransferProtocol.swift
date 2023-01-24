//
//  DataTransferProtocol.swift
//  VisualSearch
//
//  Created by Anas Mostefaoui on 24/01/2023.
//  Copyright © 2023 Nyris. All rights reserved.
//
import Foundation

protocol DataTransferProtocol : AnyObject {
    associatedtype Data
    
    func transfer(data:Data)
    func transfer(data:Data?)
    func transfer(data:[Data])
}

extension DataTransferProtocol {
    func transfer(data:Data) {}
    func transfer(data:Data?) {}
    func transfer(data:[Data]) {}
}
