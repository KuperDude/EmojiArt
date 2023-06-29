//
//  PhotoViewModel.swift
//  EmojiArt
//
//  Created by MyBook on 09.06.2022.
//

import Foundation
import Combine

class PhotoViewModel: ObservableObject {
    @Published var models = [PhotoModel]()
    
    //Supports
    let manager = LoadDataManager.instance
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getData()
    }
    
    func getData() {
        manager.$models
            .sink { [weak self] models in
                self?.models = models
            }
            .store(in: &cancellables)
    }
}
