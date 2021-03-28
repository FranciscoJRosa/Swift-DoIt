//
//  ToDoListViewController.swift
//  DoIt
//
//  Created by Francisco Rosa on 14/03/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    
    //MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.cellColor {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist")
            }
            
            if let navBarColour = UIColor(hexString: colourHex) {
                tableView.backgroundColor = navBarColour
                
                navBar.backgroundColor = navBarColour
                
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
                
                searchBar.barTintColor = navBarColour.lighten(byPercentage: CGFloat(0.20))
                
                let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
                
                textFieldInsideSearchBar?.textColor = ContrastColorOf(navBarColour, returnFlat: true)
                
                if let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView {
                    glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                    glassIconView.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                }
                
                let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
                UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, for: .normal)
            }
        }
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: self.selectedCategory!.cellColor)?.darken(byPercentage: (CGFloat(indexPath.row) + 1) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                cell.layer.cornerRadius = 30
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            }catch {
                print("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let taskForDeletion = self.todoItems?[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(taskForDeletion)
                }
            }catch {
                print("Error deleting context \(error)")
            }
            
            tableView.reloadData()
        }
    }
    
    //MARK: - Edit Data From Swipe
    override func editModel(at indexPath: IndexPath) {
    
        if let taskForEditing = self.todoItems?[indexPath.row] {

            var textField = UITextField()

            let alert = UIAlertController(title: "Edit Task", message: "", preferredStyle: .alert)

            let action = UIAlertAction(title: "Edit Task", style: .default) { (action) in

                do {
                    try self.realm.write{
                        taskForEditing.title = textField.text!
                    }
                }catch {
                    print("Error editing task \(error)")
                }
                
                self.tableView.reloadData()
            }

            alert.addTextField { (alertTextField) in
                alertTextField.text = taskForEditing.title

                textField = alertTextField
            }

            alert.addAction(action)

            present(alert, animated: true, completion: nil)
            
        }
            
    
    }
    
    
    //MARK: - Add New Items

    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch {
                    print("Error saving item \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task"
            
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Model Manipulation Methods
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
 
    
}


//MARK: - Search Bar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

