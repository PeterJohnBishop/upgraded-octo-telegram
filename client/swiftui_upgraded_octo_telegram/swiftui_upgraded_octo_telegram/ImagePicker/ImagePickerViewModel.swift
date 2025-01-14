//
//  ImagePickerViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/14/25.
//

import Foundation
import SwiftUI
import Observation
import PhotosUI
import _PhotosUI_SwiftUI

@Observable class ImagePickerViewModel {
    var selectedItems: [PhotosPickerItem] = []
    var images: [UIImage] = []
    
    func loadMedia(from items: [PhotosPickerItem]) async {
        
        images = []
            
        for item in items {
            // Load the media as either Data (for images) or URL (for video)
            if let imageData = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: imageData) {
                images.append(image)
            }
        }
    }
    
}
