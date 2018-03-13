//
//  CategoryViewController.swift
//  Notey
//
//  Created by Žan Fras on 13/03/2018.
//  Copyright © 2018 Žan Fras. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categories = [Category]()
    
    // Core Data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load categories
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    /***************************************************************/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
        
    }

    
    //MARK: - TableView Delegate Methods
    /***************************************************************/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Remove category from array and context
        context.delete(categories[indexPath.row])
        categories.remove(at: indexPath.row)
        
        saveCategories()
        
    }
    
    
    //MARK: - Data Manipulation Methods
    /***************************************************************/
    
    // Save to Core Data
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving data, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    // Load from Core Data
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading data, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - IBActions
    /***************************************************************/
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var categoryTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Create new category with context
            let newCategory = Category(context: self.context)
            newCategory.name = categoryTextField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
            
        }
        
        alert.addTextField { (textField) in
            
            // Create alert textfield
            textField.placeholder = "Create new Category"
            categoryTextField = textField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

}

//MARK: - SearchBar Methods
/***************************************************************/

extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadCategories(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            loadCategories()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
    
}
