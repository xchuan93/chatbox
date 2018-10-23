//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Foundation
import Photos

public protocol AssetLibraryDelegate: class {
    func assetLibraryDidChange(_ library: AssetLibrary)
}

open class AssetLibrary {
    open weak var delegate: AssetLibraryDelegate?
    fileprivate var fetchingAssets = false
    open let synchronous: Bool
    
    open var count: UInt {
        guard let fetch = self.fetch else {
            return 0
        }
        return UInt(fetch.count)
    }
    
    public enum AssetError: Error {
        case outOfRange, notLoadedError
    }
    
    open func asset(atIndex index: UInt) throws -> PHAsset {
        guard let fetch = self.fetch else {
            throw AssetError.notLoadedError
        }
        
        if index >= count {
            throw AssetError.outOfRange
        }
        return fetch.object(at: Int(index))
    }
    
    open func refetchAssets(synchronous: Bool = false) {
        guard !self.fetchingAssets else {
            return
        }
        
        self.fetchingAssets = true
        
        let syncOperation = {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.fetch = PHAsset.fetchAssets(with: options)
            
            let completion = {
                self.delegate?.assetLibraryDidChange(self)
                self.fetchingAssets = false
            }
            
            if synchronous {
                completion()
            }
            else {
                DispatchQueue.main.async(execute: completion)
            }
        }
        
        if synchronous {
            syncOperation()
        }
        else {
            DispatchQueue(label: "WireAssetLibrary", qos: DispatchQoS.background, attributes: [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: .none).async(execute: syncOperation)
        }
    }
    
    fileprivate var fetch: PHFetchResult<PHAsset>?
    
    init(synchronous: Bool = false) {
        self.synchronous = synchronous
        self.refetchAssets(synchronous: synchronous)
    }
}
