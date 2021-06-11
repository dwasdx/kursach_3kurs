//
//  ChatRoomsListViewController.swift
//  Messager
//
//  Created by Андрей Журавлев on 15.04.2021.
//

import UIKit

protocol ChatRoomsListRouting: BaseRouting {
    func presentChatRoomsListScreen()
    
    func presentChatRoomScreen(model: ChatRoomModel)
}

protocol ChatRoomsListViewModeling: BaseViewModeling {
    var sections: [ChatRoomsSection] { get }
    var items: [ChatRoomModel] { get }
}

fileprivate typealias ChatRoomsDataSource = UITableViewDiffableDataSource<ChatRoomsSection, ChatRoomModel>
fileprivate typealias ChatRoomsSnapshot = NSDiffableDataSourceSnapshot<ChatRoomsSection, ChatRoomModel>

class ChatRoomsListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var dataSource: ChatRoomsDataSource!
    
    var router: ChatRoomsListRouting?
    var viewModel: ChatRoomsListViewModeling! {
        didSet {
            viewModel.didChange = { [weak self] in
                self?.update()
            }
            viewModel.didGetError = { [weak self] (message) in
                self?.showErrorAlert(message: message)
            }
        }
    }
    
    override func viewDidLoad() {
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureUI() {
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        dataSource = ChatRoomsDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, model) -> UITableViewCell? in
            var cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomsCell.typeName)
            
            if cell == nil {
                tableView.register(ChatRoomsCell.self,forCellReuseIdentifier: ChatRoomsCell.typeName)
                cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomsCell.typeName)
            }
            (cell as? ChatRoomsCell)?.configure(model: model)
            return cell
        })
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateTableView()
    }
    
    private func updateTableView() {
        let sections = viewModel.sections
        let items = viewModel.items
        var snapshot = ChatRoomsSnapshot()
        snapshot.appendSections(sections)
        snapshot.appendItems(items, toSection: sections.first)
        dataSource.apply(snapshot)
    }
}

extension ChatRoomsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        router?.presentChatRoomScreen(model: model)
    }
}
