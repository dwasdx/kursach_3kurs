//
//  ContactsView.swift
//  Messager
//
//  Created by Андрей Журавлев on 08.03.2021.
//

import SwiftUI

final class ContactsViewController: UIViewController, UIViewControllerRepresentable {
    typealias UIViewControllerType = UIHostingController<ContactsView>
    
    weak var router: ContactRouting?
    
    func makeUIViewController(context: Context) -> UIHostingController<ContactsView> {
        let vc = UIHostingController(rootView: ContactsView(router: router))
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<ContactsView>, context: Context) {
        
    }
}

struct ContactsView: View {
    
    @ObservedObject var viewModel: ContactsViewModel
    
    init(router: ContactRouting?) {
        viewModel = ContactsViewModel(router: router)
    }
    
    var body: some View {
//        NavigationView {
        List {
            SearchBar(text: $viewModel.searchString)
                .padding(.horizontal, -16)
            ForEach(viewModel.filteredContacts) { (contact: ContactModel) -> SingleContactView in
                SingleContactView(contact: contact) { contact in
                    viewModel.didTapContact(contact)
                }
            }
        }
        .listSeparatorStyle(.none)
        .navigationBarTitle("Contacts", displayMode: .inline)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            viewModel.fetchContacts()
        })
        .alert(isPresented: $viewModel.isAllowedContactsAccess, content: {
            Alert(title: Text("Access denied"), message: Text("Access to contacts is denied. Please, go to Settings -> Messager and allow access to contacts so that you could see, which of your contacts are registred in Messager"), dismissButton: .default(Text("Ok")))
        })
//        }
        
        
    }
}

fileprivate struct SingleContactView: View {
    
    @Binding var contact: ContactModel
    var tapHandler: ((ContactModel) -> Void)
    init() {
        self._contact = .constant(ContactModel(id: UUID().uuidString,
                                               name: "Name123",
                                               phoneNumber: "+78005553535",
                                               isInApp: true))
        self.tapHandler = { _ in }
    }
    
    init(contact: ContactModel, tapHandler: @escaping ((ContactModel) -> Void)) {
        self._contact = .constant(contact)
        self.tapHandler = tapHandler
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: contact.avatarUrl!)
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                //                .background(contact.avatarUrl == nil ? Color.blue : Color.clear)
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                    Text(contact.phoneNumber)
                        .fontWeight(.thin)
                        .foregroundColor(.gray)
                }
                Spacer()
                if contact.isInApp {
                    Image("appIcon")
                        .resizable()
                        .frame(width: 15, height: 15, alignment: .center)
                        .offset(x: -16, y: -10)
                }
            }
            Divider()
                .foregroundColor(.black)
                .frame(width: nil, height: 3, alignment: .center)
                .padding(.leading, 40)
        }
        .onTapGesture {
            tapHandler(contact)
        }
//        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}

struct ContactsView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContactsView(router: nil)
        SingleContactView()
    }
}
