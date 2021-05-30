//
//  ContactProfileView.swift
//  Messager
//
//  Created by Андрей Журавлев on 30.05.2021.
//

import SwiftUI
import SDWebImageSwiftUI

final class ContactProfileViewController: UIViewController, UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIHostingController<ContactProfileView>
    
    var router: ContactProfileRouting?
    var contact: ContactModel!
    var shouldShowChatButton: Bool?
    
    func makeUIViewController(context: Context) -> UIHostingController<ContactProfileView> {
        let vc = UIHostingController(
            rootView: ContactProfileView(contact: contact,
                                         router: router,
                                         shouldShowChatButton: shouldShowChatButton ?? contact.isInApp)
        )
        return vc
    }
    func updateUIViewController(_ uiViewController: UIHostingController<ContactProfileView>, context: Context) {
        
    }
    
}

struct ContactProfileView: View {
    
//    var contact: ContactModel
    @ObservedObject var viewModel: ContactProfileViewModel
    let shouldShowChatButton: Bool
    
    init(contact: ContactModel,
         router: ContactProfileRouting?,
         shouldShowChatButton: Bool) {
//        self.contact = contact
        self.viewModel = ContactProfileViewModel(router: router, contact: contact)
        self.shouldShowChatButton = shouldShowChatButton
    }
    
    var body: some View {
//        NavigationView {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                Rectangle()
                    .frame(width: nil, height: 8, alignment: .center)
                    .foregroundColor(.clear)
                    .background(Color.clear)
                if viewModel.imageData == nil {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.all, 20)
                        .background(Rectangle()
                                        .foregroundColor(.blue)
                                        .frame(width: 80, height: 80))
                        .clipShape(Circle())
                } else {
                    Image(uiImage: UIImage(data: viewModel.imageData!)!)
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 4, content: {
                    let name = viewModel.name
                    let nickname = viewModel.nickname
                    Text(name.isEmpty ? name : nickname)
                        .font(.title.weight(.medium))
                    if !name.isEmpty, !nickname.isEmpty {
                        Text(nickname)
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                })
                .padding(.horizontal, 16)
                .frame(width: UIScreen.main.bounds.width, height: nil, alignment: .leading)
            }
            Divider()
            if shouldShowChatButton {
                Button(action: {
                    viewModel.didTapChat()
                }, label: {
                    HStack {
                        Text("Chat")
                        Spacer()
                    }
                    .padding(.leading, 16)
                })
                Divider()
                    .padding(.leading, 16)
            }
            //                Rectangle()
            //                    .frame(width: nil, height: 20, alignment: .center)
            //                    .foregroundColor(Color(.secondarySystemBackground))
            //                    .offset(x: 0, y: -7)
            if !viewModel.phoneNumber.isEmpty {
                Button(action: {
                    if let url = URL(string: "tel://\(viewModel.phoneNumber)"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }, label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Phone number")
                                .font(.caption)
                                .foregroundColor(Color(.label))
                            Text(viewModel.phoneNumber)
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            
                        }
                        Spacer()
                    }
                })
                .padding(.leading, 16)
                .padding(.vertical, 2)
                
                Divider()
                    .padding(.leading, 16)
            }
            
            if !viewModel.userInfo.isEmpty {
                VStack(alignment: .leading, spacing: 4, content: {
                    Text("Information")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(viewModel.userInfo)
                })
                .padding(.horizontal, 16)
                .frame(width: UIScreen.main.bounds.width, height: nil, alignment: .leading)
            }
            Spacer()
        }
        
//        .padding(.top, 8)
//        }
    }
}

struct ContactProfile_Previews: PreviewProvider {
    static var previews: some View {
        ContactProfileView(contact: ContactModel(id: "asdf",
                                                 name: "Ivan",
                                                 phoneNumber: "+78005553535",
                                                 isInApp: true),
                           router: nil,
                           shouldShowChatButton: true)
    }
}
