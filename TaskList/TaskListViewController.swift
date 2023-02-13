//
//  ViewController.swift
//  TaskList
//
//  Created by Даниил Хантуров on 03.05.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var taskList: [Task] = [] 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        getData()
        
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(red: 21/255,
                                                   green: 101/255,
                                                   blue: 192/255,
                                                   alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert()
    }
    
    private func save(task: String) {
        StorageManager.shared.save(task) { task in
            self.taskList.append(task)
            self.tableView.insertRows(
                at: [IndexPath(row: self.taskList.count - 1, section: 0)],
                with: .automatic)
        }
    }
    
    private func getData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let tasks):
                self.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        content.textProperties.color = .gray
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    
    //Edit Task
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    //Delete task
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        
        if editingStyle == .delete {
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(task)
        }
    }
   
}

//MARK: - Alert Controller
extension TaskListViewController {
    
    private func showAlert(task: Task? = nil, and completion: (() -> Void)? = nil) {
        let title = task != nil ? "Update new task" : "New task"
        
        let alert = AlertController(title: title,
                                      message: "What do want to do",
                                      preferredStyle: .alert)
        
        alert.action(task: task) { taskName in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task, newName: taskName)
                completion()
            } else {
                self.save(task: taskName)
            }
            
        }
        
        present(alert, animated: true)
    }
}

