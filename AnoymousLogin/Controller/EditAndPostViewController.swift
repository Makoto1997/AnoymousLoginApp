//
//  EditAndPostViewController.swift
//  AnoymousLogin
//
//  Created by 田中誠 on 2020/08/27.
//  Copyright © 2020 田中誠. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class EditAndPostViewController: UIViewController,UITextViewDelegate {
    
    var passedImage = UIImage()
    var userName = String()
    var userImageString = String()
    var userImageData = Data()
    var userImage = UIImage()
    
    let screenSize = UIScreen.main.bounds.size

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        //キーボード
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditAndPostViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditAndPostViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //アプリ内に保存されているデータを呼び出してパーツに反映させていく
        if UserDefaults.standard.object(forKey: "userName") != nil {
            
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        if UserDefaults.standard.object(forKey: "userImage") != nil {
            
            userImageData = UserDefaults.standard.object(forKey: "userImage") as! Data
            
            userImage = UIImage(data: userImageData)!
            
        }
        
        userProfileImageView.image = userImage
        userNameLabel.text = userName
        contentImageView.image = passedImage
        
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification){
        
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        commentTextView.frame.origin.y = screenSize.height - keyboardHeight - commentTextView.frame.height
        sendButton.frame.origin.y = screenSize.height - keyboardHeight - sendButton.frame.height
        
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification){
           
           commentTextView.frame.origin.y = screenSize.height - commentTextView.frame.height
        
            sendButton.frame.origin.y = screenSize.height - sendButton.frame.height
           
           guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
               let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else{return}
           
           UIView.animate(withDuration: duration) {
               
               let transform = CGAffineTransform(translationX: 0, y: 0)
               self.view.transform = transform
               
           }
       }
       
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           
           commentTextView.resignFirstResponder()
           
       }
       
       func commentTextViewShouldReturn(_ commentTextView: UITextView) -> Bool {
           
           commentTextView.resignFirstResponder()
           return true
           
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    @IBAction func postAction(_ sender: Any) {
        
        //DBのchildを決めていきます。
        
        let timeLineDB = Database.database().reference().child("timeLine").childByAutoId()
        
        let storage = Storage.storage().reference(forURL: "gs://anonymouslogin-17eac.appspot.com")
        
        let key = timeLineDB.child("Users").childByAutoId().key
        let key2 = timeLineDB.child("Contents").childByAutoId().key
        
        let imageRef = storage.child("Users").child("\(String(describing: key!)).jpg")
        let imageRef2 = storage.child("Contents").child("\(String(describing: key2!)).jpg")
        
        var userProfileImageData:Data = Data()
        var contentImageData:Data = Data()
        
        if userProfileImageView.image != nil{
            
            userProfileImageData = (userProfileImageView.image?.jpegData(compressionQuality: 0.01))!
            
        }
        
        if contentImageView.image != nil{
            
            contentImageData = (contentImageView.image?.jpegData(compressionQuality: 0.01))!
            
        }
        
        let uploadTask = imageRef.putData(userProfileImageData, metadata: nil){
            (metaData,error) in
            
            if error != nil{
                
                print(error)
                return
                
            }
            
            let uploadTask2 = imageRef2.putData(contentImageData, metadata: nil){
                (metaData,error) in
            
                if error != nil{
                
                    print(error)
                    return
                
                }
                
                imageRef.downloadURL { (url, error) in
                    
                    if url != nil{
                        imageRef2.downloadURL { (url2, error) in
                            
                            if url2 != nil{
                                
                                //キーバリュー型型で送信するものを準備する
                                let timeLineInfo = ["userName":self.userName as Any,"userProfileImage":url?.absoluteString as Any,"contents":url2?.absoluteString as Any,"comment":self.commentTextView.text as Any,"postDate":ServerValue.timestamp()] as[String:Any]
                                timeLineDB.updateChildValues(timeLineInfo)
                                
                                self.navigationController?.popViewController(animated: true)
                                
                            }
                            
                        }
                    }
                    
                }
                
            }
            
        }
        
        uploadTask.resume()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
