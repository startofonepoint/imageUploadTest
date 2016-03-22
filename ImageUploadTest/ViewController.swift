//
//  ViewController.swift
//  ImageUploadTest
//
//  Created by lostin1 on 2016. 3. 7..
//  Copyright © 2016년 lostin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {

    @IBOutlet var imageView: UIImageView!
    var picker:UIImagePickerController? = UIImagePickerController()
    var responseData:NSMutableData = NSMutableData()
    @IBAction func uploadPhoto(sender: AnyObject) {
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertActionStyle.Default, handler:{(alert:UIAlertAction) in
            self.openGallary()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler:{(alert:UIAlertAction) in
            return
        })
        
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        picker?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openGallary() {
        picker!.sourceType =  UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.uploadImage(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("picker cancel")
    }

    func uploadImage(image:UIImage) {
        //let configulation = NSURLSessionConfiguration.defaultSessionConfiguration()
        var request = NSMutableURLRequest(URL: NSURL(string: "http://172.30.1.8:3000/upload")!)
        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        // dataTaskWithRequest를 이용한 로직. 이로직을 사용하면 정상적으로 업로드 된다. 

        let boundary = NSUUID().UUIDString
        
        request.HTTPMethod = "POST"
        //HTTP헤더의 Content-type을 설정한다.
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //image를 NSData로 변환한다.
        let imageData:NSData = UIImageJPEGRepresentation(image, 1.0)!
        //image를 base64String으로 인코딩한다.
        //var base64Image = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        //파라미터를 셋팅한다.
        //var params = ["image":["content_type":"image/jpeg", "filename":"test.jpg", "filedata":base64Image]]
        //filePathKey parameter는 서버에 설정된 field 프로퍼티의 값이 설정되어야 정상업로드가 가능하다.
        request.HTTPBody = createBodyWithParameters("userPhoto", imageDataKey: imageData, boundary: boundary)
        
        imageView.image = image
        imageView.contentMode = UIViewContentMode.ScaleAspectFit

        
        if imageData.length > 0 {
            let task = session.dataTaskWithRequest(request)
            task.resume()
        }
 /*
        //uploadTaskWithRequest를 이용한로직. file에서 직접 올리는 방법이 아닌 이미지 화일로 업로드를 시도해본다.
        //image를 NSData로 변환한다.
        let boundary = NSUUID().UUIDString
        request.HTTPMethod = "POST"
        let imageData:NSData = UIImageJPEGRepresentation(image, 1.0)!
        let bodyData = createBodyWithParameters("userPhoto", imageDataKey: imageData, boundary: boundary)
        let task = session.uploadTaskWithRequest(request, fromData: bodyData)
        task.resume();
 */
    }
    
    
    func createBodyWithParameters(filePathKey: String?, imageDataKey:NSData, boundary:String)->NSData
    {
        let body = NSMutableData()
    
        let filename = "user-profile.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("session \(session) occurred error \(error?.localizedDescription)")
        }
        else {
            print("session \(session) upload completed, response: \(NSString(data:responseData, encoding:NSUTF8StringEncoding))")
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        var uploadProgress: Double = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        print("session \(session) uploaded \(uploadProgress * 100)%.")
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        print("session \(session), receive response \(response)")
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        responseData.appendData(data)
    }
}

