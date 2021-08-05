//
//  DetailViewController.swift
//  ImageBook
//
//  Created by Abdussamed on 5.08.2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var selectedID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedID == nil {
            
            saveBtn.isHidden = false
            
            let imageRecogniser = UITapGestureRecognizer(target: self, action: #selector(clickToImage))
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(imageRecogniser)
        }
        
        else{
            
            saveBtn.isHidden = true
            getData()
        }
        
        let recogniser = UITapGestureRecognizer(target: self, action: #selector(tapToScreen))
        
        view.addGestureRecognizer(recogniser)

        
    }
    
    private func getData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageBook")
        fetchRequest.predicate = NSPredicate(format: "id = %@", (selectedID?.uuidString)!)
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let result = try context.fetch(fetchRequest)
            
            for i in result as! [NSManagedObject] {
                
                if let name = i.value(forKey: "name") as? String {
                    nameField.text = name
                }
                
                if let location = i.value(forKey: "location") as? String {
                    locationField.text = location
                }
                
                if let year = i.value(forKey: "year") as? Int {
                    yearField.text = String(year)
                }
                
                if let image = i.value(forKey: "image") as? Data {
                    imageView.image = UIImage(data: image)
                }
            }
        }
        catch{
            print("error")
        }
        
        
    }
    
    @IBAction func saveBtnOnClick(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newImageBook = NSEntityDescription.insertNewObject(forEntityName: "ImageBook", into: context)
        
        newImageBook.setValue(nameField.text!, forKey: "name")
        newImageBook.setValue(locationField.text!, forKey: "location")
        if let year = Int(yearField.text!) {
            newImageBook.setValue(year, forKey: "year")
        }
        
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        newImageBook.setValue(imageData, forKey: "image")
        
        newImageBook.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
        } catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tapToScreen(){
        view.endEditing(true)
    }
    
    @objc func clickToImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}
