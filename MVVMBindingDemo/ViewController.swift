//
//  ViewController.swift
//  MVVMBindingDemo
//
//  Created by ruiwatanabe on 2022/07/10.
//

import UIKit

//Observable
class Observable<T> {
    var value: T? {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T?) {
        self.value = value
    }
    
    private var listener: ((T?) -> Void)?
    
    func bind(_ listener:@escaping (T?) -> Void) {
        listener(value)
        self.listener = listener
    }
}

//Model
struct User: Codable {
    let name: String
}

//ViewModel
struct UserListViewModel {
    var users: Observable<[UserTableViewCellModel]> = Observable([])
}

struct UserTableViewCellModel {
    let name: String
}
//

class ViewController: UIViewController, UITableViewDataSource {
    
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var viewModel = UserListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        viewModel.users.bind {[weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    func fetch() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let userModel = try jsonDecoder.decode([User].self, from: data)
                self.viewModel.users.value = userModel.compactMap({
                    UserTableViewCellModel(name: $0.name)
                })
            } catch {
                
            }
        }
        
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.users.value?[indexPath.row].name
        return cell
    }
    

}

