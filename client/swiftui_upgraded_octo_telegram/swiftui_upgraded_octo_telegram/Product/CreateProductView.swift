//
//  CreateProductView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/13/25.
//

import SwiftUI

struct CreateProductView: View {
    @State private var productVM: ProductViewModel = ProductViewModel()
    @State private var selectedCategory: MenuCategory = .appetizer
    @State private var priceInput: String = ""
    @State private var featuredSelection: Bool = false
    @State var s3ViewModel: S3ViewModel = S3ViewModel()
    @State var imagePickerViewModel: ImagePickerViewModel = ImagePickerViewModel()
    @State var selectedImages: [UIImage] = []
    @State var showCamera: Bool = false
    @State var sourceType: SourceType = .photoLibrary
    @State var uploaded: Bool = false
    @State var uploadType: String = "multiple"
    @State var created: Bool = false
    @State var showAlert: Bool = false
    @Binding var currentUser: UserModel

    func formattedPrice(from input: String) -> Double {
            return Double(input) ?? 0.00
        }
    
    var body: some View {
        ScrollView {
            Spacer()
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
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
                    .padding(.horizontal)
                }
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .foregroundStyle(.black.opacity(1))
                    .fontWeight(.ultraLight)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 5, y: 15)
            }
                Spacer()
            HStack{
                 Spacer()
                 ImagePickerView(imagePickerViewModel: $imagePickerViewModel, uploadType: $uploadType)
                     .onChange(of: imagePickerViewModel.images, {
                         oldValue, newValue in
                         if !newValue.isEmpty {
                             selectedImages = imagePickerViewModel.images
                         }
                     }).padding()
                 Spacer()
                Button(action: {
                    sourceType = .camera
                    self.showCamera.toggle()
                }, label: {
                    Image(systemName: "camera.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.black)
                })
                .sheet(isPresented: $showCamera) {
                    accessMediaView(selectedImages: $selectedImages, sourceType: $sourceType) // Pass Binding here
                        .ignoresSafeArea()
                }
                .padding()

                 Spacer()
                 Button(action: {
                     if !selectedImages.isEmpty {
                         Task{
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
                         Image(systemName: "checkmark.circle")
                             .resizable()
                             .frame(width: 50, height: 50)
                             .foregroundStyle(.black)
                     }
                 }).padding()
                 Spacer()
             }.padding()
            TextField("Name", text: $productVM.product.name)
                    .tint(.black)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                HStack{
                    Text("Description").foregroundStyle(.black)
                        .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 0))
                    Spacer()
                }
                TextEditor(text: $productVM.product.description)
                    .frame(height: 100) // Adjust to accommodate 5 lines
                    .padding(8)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    ).padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    .tint(.black)
                HStack{
                    Text("Category").foregroundStyle(.black)
                        .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 0))
                    Spacer()
                }
                Picker("Select a Category", selection: $selectedCategory) {
                    ForEach(MenuCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                ).padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                TextField("$ Price", text: $priceInput)
                    .tint(.black)
                    .keyboardType(.decimalPad)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                Toggle(isOn: $featuredSelection) {
                    Text(featuredSelection ? "Featured" : "Not Featured")
                    .foregroundStyle(.black)
                }
                .toggleStyle(SwitchToggleStyle(tint: .black))
                .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                Button("Submit", action: {
                    productVM.product.images = s3ViewModel.imageUrls
                    productVM.product.price = formattedPrice(from: priceInput)
                    productVM.product.category = selectedCategory.id
                    Task{
                        do {
                            let newProduct = try                         await productVM.createProduct(newProduct: productVM.product)
                            DispatchQueue.main.async {
                                created = newProduct
                            }
                        } catch {
                            DispatchQueue.main.async {
                                showAlert = true
                                productVM.errorMessage = error.localizedDescription
                            }
                        }
                    }
                })
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                .navigationDestination(isPresented: $created, destination: {
                    HomeView(currentUser: $currentUser)
                })
            
        }.onAppear{
            
        }
    }
}

struct CreateProduct_Previews: PreviewProvider {
    @State static var sampleUser = UserModel(id: "99999999", name: "Mike Ellingsworth", email: "m.ellingsworth@gmail.com", password: "123456789ABC")

    static var previews: some View {
        HomeView(currentUser: $sampleUser)
    }
}
