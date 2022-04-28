//
//  FlagImagesRepositoryInterfaces.swift
//  Secure VPN
//
//  Created by Ali Fakih on 7/1/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation

public protocol FlagImagesRepository {
    func image(with imagePath: String, completion: @escaping(Result<Data, Error>) -> Void) -> Cancellable?
}
