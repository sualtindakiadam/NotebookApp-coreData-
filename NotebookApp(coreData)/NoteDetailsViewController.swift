//
//  NoteDetailsViewController.swift
//  NotebookApp(coreData)
//
//  Created by Semih Kalaycı on 12.08.2021.
//

import UIKit
import CoreData


class NoteDetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate { //UIImagePickerControllerDelegate,UINavigationControllerDelegate resim seçme işlemleri için eklenir
    
    
    @IBOutlet weak var noteImageIV: UIImageView!
    @IBOutlet weak var noteTitleTF: UITextField!
    @IBOutlet weak var noteYearTF: UITextField!
    @IBOutlet weak var noteTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    var chosenNote = ""
    var chosenNoteID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenNote != ""{
            
            saveBtn.isHidden = true
            
            // Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            let stringUUID = chosenNoteID?.uuidString //UUID formatını stringe çevirir
            
            fetchrequest.predicate = NSPredicate(format: "id = %@", stringUUID!)
            fetchrequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchrequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject]{
                        if let noteTitle = result.value(forKey: "noteTitle") as? String{
                            noteTitleTF.text = noteTitle
                            
                        }
                        if let noteYear = result.value(forKey: "noteYear") as? Int{
                            noteYearTF.text = String(noteYear)
                            
                        }
                        if let note = result.value(forKey: "note") as? String{
                            noteTF.text = note
                            
                        }
                        if let noteImage = result.value(forKey: "noteImage") as? Data{
                            
                            noteImageIV.image = UIImage(data : noteImage)
                            
                        }

                        
                    }
                    
                }
            }catch{
                print("Error data getirme")
            }
            
            
        }
        else{
            saveBtn.isHidden = false
            saveBtn.isEnabled = false
        }

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        noteImageIV.isUserInteractionEnabled = true
        let noteImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        noteImageIV.addGestureRecognizer(noteImageTapRecognizer)
        
        
        
        
    }
    
    @IBAction func noteSaveBtnClicked(_ sender: Any) {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        
        newNote.setValue(UUID(), forKey: "id")
        newNote.setValue(noteTitleTF.text, forKey: "noteTitle")
        newNote.setValue(noteTF.text, forKey: "note")
        if Int(noteYearTF.text!) != nil{
            newNote.setValue(Int32(noteYearTF.text!), forKey: "noteYear")
        }
        
        let imageData = noteImageIV.image?.jpegData(compressionQuality: 0.5)
        
        newNote.setValue(imageData, forKey: "noteImage")
        
        do{
            try context.save()
            print("save success")
        }catch{
            print("sace error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){// resim seçme
        
        let picker = UIImagePickerController()//resim video vs şeyleri alabilmek için
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        noteImageIV.image=info[.originalImage] as? UIImage //genelde originalImage yada editedImage kullanılır. Editlenmiş fotoyu kullanmak istemiyorsa originaşImage seç
        saveBtn.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
