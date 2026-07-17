//
//  HomeVC.swift
//  ExamDemo
//
//  Created by Ankit on 16/07/26.
//

import UIKit

class HomeVC: UIViewController {
    var vm = HomeViewModel(apiClient: APIClient())

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            let nib = UINib(nibName: "UserCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "userCell")
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        handleEvent()
        Task{
           await vm.getUserData()
        }
    }

    func handleEvent(){
        vm.eventHandler = { [weak self] event in
            switch event {
            case .loading(let isLoading):
                if isLoading {
                       self?.loader.startAnimating()
                   } else {
                       self?.loader.stopAnimating()
                   }
            case .dataLoaded:
                self?.tableView.reloadData()
            case .error(let error):
                var alert: UIAlertController
                alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                break;
            }
        }
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.userData?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        cell.userName.text = vm.userData?[indexPath.row].name
        return cell
    }
}
