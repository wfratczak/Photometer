//
//  MeterDetailsViewController.swift
//  Photometer
//
//  Created by Wojtek Frątczak on 11.11.2016.
//  Copyright © 2016 Wojtek. All rights reserved.
//

import UIKit
import RealmSwift

class MeterDetailsViewController: UIViewController {

    @IBOutlet weak var meterPhotoImageView: UIImageView!
    var meter: Meter!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        if let image = meter.image {
            meterPhotoImageView.image = image
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addPhotoButtonAction(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MeterDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            meterPhotoImageView.image = pickedImage;
            let realm = try! Realm()
            try! realm.write {
                meter.image = pickedImage
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension UIImage {
    func normalizedImage() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
