//
//  ViewController.swift
//  DoIt
//
//  Created by Francisco Rosa on 14/03/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        
        if let navBarColour = UIColor(hexString: "dddddd") {
            navBar.backgroundColor = navBarColour
            
            navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
            
            tableView.backgroundColor = navBarColour
        }
    }
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            if let categoryColour = UIColor(hexString: category.cellColor) {
                cell.backgroundColor = categoryColour
                cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
                
                cell.layer.cornerRadius = 30
            }
        }
        
        return cell
    }
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
        
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories(category: Category){
        do {
            try realm.write{
                realm.add(category)
            }
        }catch {
            print("Error saving data \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            }catch {
                print("Erro deleting context \(error)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Edit Data From Swipe
    override func editModel(at indexPath: IndexPath) {
    
        if let categoryForEdition = self.categoryArray?[indexPath.row] {

            var textField = UITextField()

            let alert = UIAlertController(title: "Edit Category", message: "", preferredStyle: .alert)

            let action = UIAlertAction(title: "Edit Category", style: .default) { (action) in

                do {
                    try self.realm.write{
                        categoryForEdition.name = textField.text!
                    }
                }catch {
                    print("Error editing category \(error)")
                }
                
                self.tableView.reloadData()
            }

            alert.addTextField { (alertTextField) in
                alertTextField.text = categoryForEdition.name

                textField = alertTextField
            }

            alert.addAction(action)

            present(alert, animated: true, completion: nil)
            
        }
            
    
    }
    
    
    
    //MARK: - Add New Categories

    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.cellColor = UIColor(randomFlatColorOf:.light).hexValue()
            
            self.saveCategories(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
}

