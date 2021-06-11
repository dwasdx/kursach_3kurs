//
//  ProfileView.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

final class ProfileViewController: UIViewController, UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIHostingController<ProfileView>
    
    weak var router: ProfileRouting?
    
    func makeUIViewController(context: Context) -> UIHostingController<ProfileView> {
        let vc = UIHostingController(rootView: ProfileView(router: router))
        return vc
    }
    func updateUIViewController(_ uiViewController: UIHostingController<ProfileView>, context: Context) {
        
    }
}

struct ProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showVisualSettings = false
    @State private var showLogoutAlert = false
    
    init(router: ProfileRouting?) {
        self.viewModel = ProfileViewModel(router: router)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        viewModel.profileTapped()
                    }, label: {
                        HStack {
                            PersonProfileView(name: $viewModel.name,
                                              username: $viewModel.username,
                                              imageUrl: $viewModel.avatarUrl)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color(.label))
                    .frame(width: nil, height: 60, alignment: .center)
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Media", imageName: "media_settings")

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color(.label))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Stickers", imageName: "stickers_settings")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color(.label))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Blocked", imageName: "privacy_settings")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color(.label))
                }
                
                Section(header: Text("System")) {
                    Button(action: {
                        if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Notifications", imageName: "notification_settings")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color(.label))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Privacy and Security", imageName: "privacy_settings")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color(.label))
                    
                    Button(action: {
                        showVisualSettings = true
                    }, label: {
                        HStack {
                            SettingsPageView(title: "User Interface", imageName: "ui_settings")
                            NavigationLink(
                                destination: VisualSettingsView(),
                                isActive: $showVisualSettings,
                                label: {
                                    EmptyView()
                                })
                                .hidden()
                                .frame(width: 0)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color(.label))
                }
                
                Section {
                    HStack(alignment: .center) {
                        Spacer()
                        Button(action: {
                            showLogoutAlert.toggle()
                        }, label: {
                            Text("Log out")
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        })
                        Spacer()
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Settings")
        }
        .onAppear {
            viewModel.updateProfile()
        }
        .alert(isPresented: $showLogoutAlert, content: {
            Alert(title: Text("Log out"),
                  message: Text("Are you sure you want to log out?"),
                  primaryButton: .cancel(Text("Cancel"),
                                         action: nil),
                  secondaryButton: .destructive(Text("Log out"),
                                                action: {
                                                    viewModel.logoutTapped()
                                                }))
        })
    }
}

fileprivate struct PersonProfileView: View {
    @Binding var name: String?
    @Binding var username: String?
    @Binding var imageUrl: URL?
    
    var body: some View {
        HStack {
            AnimatedImage(url: imageUrl)
                .placeholder(UIImage(systemName: "person"))
                .resizable()
                .foregroundColor(Color.gray)
                .frame(width: 52, height: 52, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .background(Color.gray.opacity(0.5))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(name ?? "")
                    .fontWeight(.bold)
                Text(username ?? "")
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
            }
            
            
        }
    }
}

fileprivate struct SettingsPageView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        HStack {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
            } else {
                Image(systemName: imageName)
            }
            
            Text(title)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProfileView(router: nil)
//        PersonProfileView(name: "Vladimir", username: "dwasd")
//            .frame(width: 375, height: 100, alignment: .center)
    }
}
