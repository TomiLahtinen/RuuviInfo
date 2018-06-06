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
    
    static let InfoCellIdentifier = "RuuviInfoCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: [RuuviTag] = [] {
        didSet {
            model.sort { (tag1, tag2) -> Bool in
                return tag1.uuid?.uuidString ?? "" < tag2.uuid?.uuidString ?? ""
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tagDetailSegue", let target = segue.destination as? TagDetailViewController {
            let indexPath = tableView.indexPathForSelectedRow
            target.tag = self.model[indexPath!.row]
        }
    }
}

extension ListPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ListPageViewController.InfoCellIdentifier)
        let tag = model[indexPath.row]
        cell?.textLabel?.text = tag.uuid?.uuidString ?? "Unknown"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alert = UIAlertController(title: "Tag name", message: "Give tag a custom name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default) { action in
            guard let name = alert.textFields?.first?.text,
                  let tag = self.model[indexPath.row] else {
                alert.dismiss(animated: true, completion: nil)
                return
            }
            listViewModel.save(tag: tag, name: name)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Custom tag name"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
extension ListPageViewController: UITableViewDelegate {}
