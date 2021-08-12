//
//  ViewController.swift
//  NotebookApp(coreData)
//
//  Created by Semih Kalaycı on 12.08.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var notesTV: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedNote = ""
    var selectedNoteId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesTV.delegate = self
        notesTV.dataSource =  self

        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addBtnClicked))
        
                
        getData()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func  getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            
           let results = try context.fetch(fetchRequest)
            if results.count>0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "noteTitle") as? String{
                        
                        self.nameArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                        
                    }
                    
                    self.notesTV.reloadData()// kaydettikten sonra tabloyu güncelle
                    print("yazdı")
                }
                
            }

            
            
        }catch{
            print("Error getData ")
        }
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }


    @objc func addBtnClicked() {
        selectedNote = ""
        performSegue(withIdentifier: "noteDetailVC", sender: nil)
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "noteDetailVC"{
            let destinationVC = segue.destination as! NoteDetailsViewController
            destinationVC.chosenNote = selectedNote
            destinationVC.chosenNoteID = selectedNoteId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = nameArray[indexPath.row]
        selectedNoteId = idArray[indexPath.row]
        performSegue(withIdentifier: "noteDetailVC", sender: nil)
    }


    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { // comit editingStyle arıyoruz
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idArray[indexPath.row].uuidString )
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                
                                self.notesTV.reloadData()
                                
                                do{
                                    try context.save()
                                    
                                }catch{
                                    print("delete error")
                                    
                                }
                                
                                break // yazarsan direkt looptan çıkarsın örnek olsn diye var özellikle burda gerek yok 
                                
                            }
                            
                        }
                        
                        
                    }
                    
                }
                
                
                
                
            }catch{
                
            }
           
            
            
        }
        
    }

}

