//
//  ViewController.swift
//  coreDataCloudKit
//
//  Created by Cecilia Soares on 14/10/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var dataManager = DataManeger()
   
    @IBOutlet weak var table: UITableView!
    
    
    var items:[NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        
        
//        deleteAllData("Person")
//        items.removeAll()
        self.loadData()
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            let textField = alert.textFields![0]
            let name = textField.text ?? "ana"
            self.saveName(with: name)
            self.loadData()
            
        }
        alert.addAction(submitButton)
        self.present(alert, animated: true, completion: nil)
    }
    func saveName(with name: String) {
        let managedContext = dataManager.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let movie = NSManagedObject(entity: entity, insertInto: managedContext)
        
        movie.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func loadData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let context = dataManager.persistentContainer.viewContext
        do{
            let results = try context.fetch(fetchRequest)
            items  = results as! [NSManagedObject]
//            items.append(contentsOf: name)
            
        }catch{
            fatalError("Error is retriving titles items")
        }
        table.reloadData()
    }
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        let context = self.dataManager.persistentContainer.viewContext
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
        //        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath)
        
        if self.items[indexPath.row].value(forKey: "name") != nil {
            let persona = self.items[indexPath.row].value(forKey: "name") as? String
            cell.textLabel?.text = persona
        }
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let personToRemove = self.items[indexPath.row]
            let context = self.dataManager.persistentContainer.viewContext
            context.delete(personToRemove)
            do{
                try context.save()
            }  catch let error {
                print("Delete data error :", error)
            }
            self.loadData()
            
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

