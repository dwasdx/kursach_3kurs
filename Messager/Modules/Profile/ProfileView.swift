//
//  ProfileView.swift
//  Messager
//
//  Created by Андрей Журавлев on 02.03.2021.
//

import SwiftUI

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
    
    init(router: ProfileRouting?) {
        self.viewModel = ProfileViewModel(router: router)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        
                    }, label: {
                        HStack {
//                            PersonProfileView(name: viewModel.$name, username: viewModel.$username)
//                            PersonProfileView(name: viewModel.name, username: viewModel.username)
                            PersonProfileView(name: "adsfs", username: "dads")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color.black)
                    .frame(width: nil, height: 60, alignment: .center)
                }
                
                Section(header: Text("Account")) {
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Media", imageName: "gear")

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color.black)
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Stickers", imageName: "gear")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color.black)
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Blocked", imageName: "gear")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color.black)
                }
                
                Section(header: Text("System")) {
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Notifications", imageName: "gear")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color.black)
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "Privacy and Security", imageName: "gear")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color.black)
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            SettingsPageView(title: "User Interface", imageName: "gear")
                            
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    })
                    .foregroundColor(Color.black)
                }
            }
            .listStyle(GroupedListStyle())
//            .background(Color.white)
            .navigationBarTitle("Settings")
        }
//        .background(Color.white)
    }
}

fileprivate struct PersonProfileView: View {
//    @Binding var name: String
//    @Binding var username: String
    @State var name: String
    @State var username: String
    
    var body: some View {
        HStack {
            Image(systemName: "person")
                .frame(width: 52, height: 52, alignment: .center)
                .background(Color.gray)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .fontWeight(.bold)
                Text(username)
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
            Image(systemName: imageName)
            Text(title)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    
    static var previews: some View {
        ProfileView(router: nil)
        PersonProfileView(name: "Vladimir", username: "dwasd")
            .frame(width: 375, height: 100, alignment: .center)
    }
}
