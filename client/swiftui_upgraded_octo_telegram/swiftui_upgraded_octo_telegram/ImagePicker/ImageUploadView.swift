//
//  ImageUploadView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/14/25.
//

import Foundation
import SwiftUI

struct ImageUploadView: View {
    @Binding var s3ViewModel: S3ViewModel
    @Binding var imagePickerViewModel: ImagePickerViewModel
    @Binding var selectedImages: [UIImage]
    @Binding var showCamera: Bool
    @Binding var sourceType: SourceType
    @Binding var uploaded: Bool
    @State var uploadType: String = "post"
    
    var body: some View {
        VStack{
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 325, height: 325)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .onTapGesture {
                                    selectedImages.removeAll()
                                }
                        }
                    }
                    .padding()
                }
            } else {
                Image(systemName: "photo.circle")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .foregroundStyle(.black.opacity(1))
                    .fontWeight(.ultraLight)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 5, y: 15)
            }
            HStack {
                Spacer()
                ImagePickerView(imagePickerViewModel: $imagePickerViewModel, uploadType: $uploadType)
                    .onChange(of: imagePickerViewModel.images) { oldValue, newValue in
                        if !newValue.isEmpty {
                            selectedImages = imagePickerViewModel.images
                        }
                    }.padding()
                Spacer()
                Button(action: {
                    sourceType = .camera
                    self.showCamera.toggle()
                }, label: {
                    Image(systemName: "person.fill.viewfinder")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.black)
                    
                }).sheet(isPresented: $showCamera) {
                    accessMediaView(selectedImages: $selectedImages, sourceType: $sourceType).ignoresSafeArea()
                }.padding()
                Spacer()
                Button(action: {
                    if !selectedImages.isEmpty {
                        Task {
                            uploaded = await s3ViewModel.uploadImagesToS3(images: selectedImages)
                        }
                    }
                }, label: {
                    if uploaded {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "square.and.arrow.up.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.black)
                    }
                }).padding()
            }
        }
    }
}
