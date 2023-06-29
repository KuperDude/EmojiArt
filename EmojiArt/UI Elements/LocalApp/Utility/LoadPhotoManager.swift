//
//  LoadPhotoManager.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import Foundation
import Combine

class LoadDataManager {
    @Published var models = [PhotoModel]()
    var cancellables = Set<AnyCancellable>()
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/photos")
    static let instance = LoadDataManager() //Singleton
    
    private init() {
        getData()
    }
    
    func getData() {
        guard let url = url else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap(transformToData)
            .decode(type: [PhotoModel].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .sink { [weak self] models in
                self?.models = models
            }
            .store(in: &cancellables)
    }
    
    func transformToData(output: Publishers.SubscribeOn<URLSession.DataTaskPublisher, DispatchQueue>.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return output.data
    }
    
}
