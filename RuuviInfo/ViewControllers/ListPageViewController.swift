//
//  ListPageViewController.swift
//  RuuviInfo
//
//  Created by Tomi Lahtinen on 31/05/2018.
//  Copyright © 2018 Tomi Lahtinen. All rights reserved.
//

import Foundation
import UIKit

class ListPageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: [RuuviTag] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    fileprivate lazy var listViewModel: RuuviTagListViewModelProtocol = {
        return RuuviTagListViewModel(
            didUpdateTags: { tags in
                self.model = tags
            },
            didUpdateTag: { tag in
                if let index = self.model.index(of: tag) {
                    self.model.remove(at: index)
                }
                self.model.append(tag)
            }
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listViewModel.startScanningTags()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listViewModel.stopScanningTags()
    }
}

extension ListPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.cellForRow(at: indexPath)!
    }
    
}
extension ListPageViewController: UITableViewDelegate {}
