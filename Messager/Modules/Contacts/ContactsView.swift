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
        NavigationView {
//            VStack {
//                SearchBar(text: $viewModel.searchString)
//
//                List(viewModel.filteredContacts) { contact in
//                    SingleContactView(contact: contact)
//
//                }
//                .listSeparatorStyle(.singleLine, color: nil, inset: EdgeInsets(top: 0, leading: 56, bottom: 0, trailing: 0))
//                .animation(.default)
//            }
            List {
                SearchBar(text: $viewModel.searchString)
                    .padding(.horizontal, -16)
                ForEach(viewModel.filteredContacts) { (contact: ContactModel) -> SingleContactView in
                    SingleContactView(contact: contact)
                }
            }
            .listSeparatorStyle(.none)
//            .listStyle(DefaultListStyle())
            .navigationBarTitle("Contacts", displayMode: .inline)
            
        }
        
    }
}

fileprivate struct SingleContactView: View {
    
    @Binding var contact: ContactModel
    init() {
        self._contact = .constant(ContactModel(id: UUID().uuidString,
                                               name: "Name123",
                                               phoneNumber: "+78005553535"))
    }
    
    init(contact: ContactModel) {
        self._contact = .constant(contact)
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: contact.avatarUrl!)
                    .frame(width: 40, height: 40, alignment: .center)
                    .background(Color.blue)
                    .clipShape(Circle())
                //                .background(contact.avatarUrl == nil ? Color.blue : Color.clear)
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                    Text(contact.phoneNumber)
                        .fontWeight(.thin)
                        .foregroundColor(.gray)
                }
                Spacer()
                // something indicating about whether user is in app or not
            }
            Divider()
                .foregroundColor(.black)
                .frame(width: nil, height: 3, alignment: .center)
                .padding(.leading, 40)
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
