//
//  NotesViewController.swift
//  Notey
//
//  Created by Žan Fras on 13/03/2018.
//  Copyright © 2018 Žan Fras. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UITableViewController {
    
    var notes = [Note]()
    
    var selectedCategory: Category? {
        didSet {
            loadNotes()
        }
    }
    
    // Core Data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTable()
    }
    
    //MARK: - TableView Datasource Methods
    /***************************************************************/
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteViewCell
        
        cell.titleLabel.text = notes[indexPath.row].title
        cell.notesLabel.text = notes[indexPath.row].notes
        
        return cell
        
    }
    
    
    //MARK: - TableView Delegate Methods
    /***************************************************************/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Remove note from array and context
        context.delete(notes[indexPath.row])
        notes.remove(at: indexPath.row)
        
        saveNotes()
        
    }
    
    
    //MARK: - Data Manipulation Methods
    /***************************************************************/
    
    // Save to Core Data
    func saveNotes() {
        
        do {
            try context.save()
        } catch {
            print("Error saving data, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    // Load from Core Data
    func loadNotes(with request: NSFetchRequest<Note> = Note.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name!)!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            notes = try context.fetch(request)
        } catch {
            print("Error loading data, \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func configureTable() {
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120.0
        
    }
    
    //MARK: - IBActions
    /***************************************************************/
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var noteTextField = UITextField()
        var noteTextFieldNote = UITextField()
        
        let alert = UIAlertController(title: "Add new Note", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Create new category with context
            let newNote = Note(context: self.context)
            newNote.title = noteTextField.text!
            newNote.notes = noteTextFieldNote.text!
            newNote.parentCategory = self.selectedCategory
            
            self.notes.append(newNote)
            
            self.saveNotes()
            
        }
        
        alert.addTextField { (textField) in
            
            // Create alert textfield
            textField.placeholder = "Note title"
            noteTextField = textField
            
        }
        
        alert.addTextField { (textField) in
            
            // Create alert textfield
            textField.placeholder = "Notes"
            noteTextFieldNote = textField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }

}
