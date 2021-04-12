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
    
    init(
        router: ContactRouting?,
        contactsService: ContactsServiceable = ContactsService.shared
    ) {
        self.contactsService = contactsService
        filteredContacts = []
        filteredContacts = contactsSorted
        fetchContacts()
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
    
    private func fetchContacts() {
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
                    
                } catch {
                    self.isAllowedContactsAccess = true
                }
            }
    }
}
