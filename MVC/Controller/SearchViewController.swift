//
//  SearchViewController.swift
//  Homework4.4
//
//  Created by Zhansuluu Kydyrova on 14/1/23.
//

import UIKit
import RxSwift

class SearchViewController: UIViewController {
    
    @IBOutlet private weak var productsTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var filteredProducts = [ProductModel]() {
        didSet {
            productsTableView.reloadData()
        }
    }
    
    private let disposeBag = DisposeBag()
    private var filteredProductsObservable: Observable<[ProductModel]>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        productsTableView.dataSource = self
        productsTableView.delegate = self
        productsTableView.register(
            UINib(nibName: String(describing: TakeawaysTableViewCell.self),bundle: nil),
            forCellReuseIdentifier: TakeawaysTableViewCell.tableViewCellReuseID
        )
        
        searchBar.delegate = self
    }
    
    private func searchTakeawaysData(text: String) {
        filteredProductsObservable = NetworkLayer.shared.findProductsData(text: text)
        Task {
            guard let filteredData = try await filteredProductsObservable?.toArray().value.first else { return }
            filteredProducts = filteredData
        }
    }
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return filteredProducts.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TakeawaysTableViewCell.tableViewCellReuseID,
            for: indexPath) as? TakeawaysTableViewCell else { fatalError() }
        guard !filteredProducts.isEmpty else { fatalError() }
        let productInfo = filteredProducts[indexPath.row]
        cell.displayInfo(productInfo)
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 380
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {
        filteredProducts.removeAll()
        searchTakeawaysData(text: searchText)
    }
}
