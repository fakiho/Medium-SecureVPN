//
//  DefaultFlagRepository.swift
//  Secure VPN
//
//  Created by Ali Fakih on 7/1/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import Foundation
import AFNetworks

public class DefaultImageFlagRepository {
    
    let dataTransferService: DataTransferService
    let imageNotFoundData: Data?
    
    public init(dataTransferService: DataTransferService, imageNotFoundData: Data?) {
        self.dataTransferService = dataTransferService
        self.imageNotFoundData = imageNotFoundData
    }
}
extension DefaultImageFlagRepository: FlagImagesRepository {
    public func image(with imagePath: String, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        let endpoint = APIEndpoints.flagImage(path: imagePath)
        let networkTask = dataTransferService.request(with: endpoint) { [weak self] response in
            guard let self = self else { return }
            switch response {
            
            case .success(let data):
                completion(.success(data))
                return
            case .failure(let error):
                completion(.failure(error))
                if case let DataTransferError.networkFailure(networkError) = error,
                networkError.isNotFoundError,
                    let imageNotFoundData = self.imageNotFoundData {
                    completion(.success(imageNotFoundData))
                    return
                }
                return
            }
        }
        
        return RepositoryTask(networkTask: networkTask, operation: nil)
    }
}
