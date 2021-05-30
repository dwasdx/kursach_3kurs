//
//  ContactsViewModel.swift
//  Messager
//
//  Created by Андрей Журавлев on 08.03.2021.
//

import Foundation
import Combine

final class ContactsViewModel: ObservableObject {
    
    private weak var router: ContactRouting?
    
    private let contactsLock = NSLock()
    
    private var contacts = [
        ContactModel(id: UUID().uuidString,
                     name: "Ivan",
                     phoneNumber: "+78005553535"),
        ContactModel(id: UUID().uuidString,
                     name: "Andrei",
                     phoneNumber: "+78005553535"),
        ContactModel(id: UUID().uuidString,
                     name: "Alexei",
                     phoneNumber: "+78005553535"),
        ContactModel(id: UUID().uuidString,
                     name: "Igor",
                     phoneNumber: "+78005553535"),
        ContactModel(id: UUID().uuidString,
                     name: "Ilya",
                     phoneNumber: "+78005553535"),
        ContactModel(id: UUID().uuidString,
                     name: "Dima",
                     phoneNumber: "+78005553535"),
    ] {
        didSet {
            filterContacts(forString: searchString)
        }
    }
    
    private var contactsSorted: [ContactModel] {
        contacts.sorted(by: { $0.name < $1.name })
    }
    @Published var filteredContacts: [ContactModel]
    @Published var isAllowedContactsAccess = false
    @Published var searchString = "" {
        didSet {
            filterContacts(forString: searchString)
        }
    }
    
    private let contactsService: ContactsServiceable
    private let firestoreService: FirestoreUserServiceable
    
    init(
        router: ContactRouting?,
        contactsService: ContactsServiceable = ContactsService.shared,
        firestoreService: FirestoreUserServiceable = FirestoreService.shared
    ) {
        self.router = router
        self.contactsService = contactsService
        self.firestoreService = firestoreService
        filteredContacts = []
        filteredContacts = contactsSorted
//        fetchContacts()
    }
    
    private func setFilteredContacts(_ contacts: [ContactModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.filteredContacts = contacts
        }
    }
    
    private func filterContacts(forString string: String) {
        if string.isEmpty {
            setFilteredContacts(contactsSorted)
            return
        }
        let filteredArray = contacts.filter { (contact) -> Bool in
            contact.name.lowercased().contains(string.lowercased()) || contact.phoneNumber.decimalString.contains(string.decimalString)
        }
        let sorted = filteredArray.sorted(by: { $0.name < $1.name })
        setFilteredContacts(sorted)
    }
    
    func fetchContacts() {
        DispatchQueue(label: "com.Messager.fetchContacts",
                      qos: .utility,
                      attributes: [],
                      autoreleaseFrequency: .workItem,
                      target: nil)
            .async { [weak self] in
                guard let self = self else {
                    return
                }
                do {
                    self.contacts.removeAll()
                    try self.contactsService.iterateAllContacts { (contact, stop) in
                        let name = self.contactsService.getFullName(for: contact) ?? "N/A"
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                        let contact = ContactModel(id: UUID().uuidString,
                                                   name: name,
                                                   phoneNumber: phoneNumber)
                        self.contacts.append(contact)
                    }
                    self.checkContacts()
                } catch {
                    self.isAllowedContactsAccess = true
                }
            }
    }
    
    private func checkContacts() {
        #warning("Needed fix for Invalid Query. 'in' filters support a maximum of 10 elements in the value array")
        let phoneNumbers = contacts.map { $0.phoneNumber.decimalString }
//        let phoneNumbers = [String](repeating: "fdsfas", count: 11)
        dump(phoneNumbers, name: "Phone numbers")
//        var iter = 0
        phoneNumbers.chunk(size: 10).forEach { numbers in
            self.contactsLock.lock()
//            print("iter \(iter)")
//            iter += 1
            firestoreService.getUsersByPhoneNumbers(numbers) { [weak self] result in
                defer {
//                    print("result \(result)")
                    self?.contactsLock.unlock()
                }
                guard let self = self else {
                    return
                }
                switch result {
                    case .success(let users):
                        dump(users, name: "Found users", maxDepth: 2)
                        users.forEach { user in
                            if let index = self.contacts.firstIndex(where: { $0.phoneNumber.decimalString == user.phoneNumber?.decimalString }) {
                                self.contacts[index].isInApp = true
                            }
                        }
                    case .failure(let error):
                        print(error)
                }
            }
        }
        firestoreService.getUsersByPhoneNumbers(phoneNumbers) { result in
            switch result {
                case .success(let users):
                    dump(users, name: "Found users", maxDepth: 2)
                    users.forEach { user in
                        if let index = self.contacts.firstIndex(where: { $0.phoneNumber.decimalString == user.phoneNumber?.decimalString }) {
                            self.contacts[index].isInApp = true
                        }
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func didTapContact(_ contact: ContactModel) {
        router?.presentContactProfileViewController(contact: contact, completion: nil)
    }
}
