//
//  SwipeTableViewController.swift
//  DoIt
//
//  Created by Francisco Rosa on 16/03/2021.
//

import UIKit
import SwipeCellKit


class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    
    //MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .right {
            let action =  SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
                
                self.updateModel(at: indexPath)
            }
            
            action.image = UIImage(named: "delete-icon")
            
            return [action]
            
        } else if orientation == .left {
            
            let action =  SwipeAction(style: .default, title: "Edit") { (action, indexPath) in

                self.editModel(at: indexPath)
            }

            action.image = UIImage(named: "edit-icon")

            return [action]
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions? {
        var options = SwipeOptions()
        
        options.expansionStyle = orientation == .left ? .selection : .destructive
        
        
        return options
    }
    
    
    func updateModel(at indexPath: IndexPath){
        
    }
    
    func editModel(at indexPath: IndexPath){
        
    }
    
    

}
