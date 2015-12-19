//
//  ViewController.swift
//  MemeMe
//
//  Created by Jeff Tilson on 2015-10-29.
//  Copyright © 2015 Jeff Tilson. All rights reserved.
//

import UIKit
import AVFoundation;

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Default text values
    let defaultTop: String = "TOP"
    let defaultBottom: String = "BOTTOM"

    // MARK: - Outlets
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var imageToolbar: UIToolbar!
    
    @IBOutlet weak var shareToolbar: UIToolbar!
    
    // Memed image
    var memedImage: UIImage?
    
    // Edit meme
    var editMeme: Meme?

    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up the text fields
        prepareTextField(topTextField, defaultText: defaultTop)
        prepareTextField(bottomTextField, defaultText: defaultBottom)
        
        // Check if we've been asked to edit an existing meme
        if let editMeme = editMeme {
            topTextField.text = editMeme.topText
            bottomTextField.text = editMeme.bottomText
            selectedImageView.image = editMeme.originalImage
        } else {
            // Disable the share button (when creating a new meme)
            shareButton.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        // Disable the camera button if not available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Override here to hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func keyboardWillShow(notification: NSNotification) {
        if (bottomTextField.isFirstResponder()) {
            // From: https://discussions.udacity.com/t/better-way-to-shift-the-view-for-keyboardwillshow-and-keyboardwillhide/36558
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (bottomTextField.isFirstResponder()) {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    @IBAction func pinchImage(sender: UIPinchGestureRecognizer) {
        selectedImageView.transform = CGAffineTransformScale(selectedImageView.transform, sender.scale, sender.scale)
        sender.scale = 1
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the original image
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageView.image = originalImage
        }
        
        // Enable the share/cancel buttons now that we have an image
        shareButton.enabled = true
        cancelButton.enabled = true
        
        // Dismiss
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UITextField
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text == defaultTop || textField.text == defaultBottom) {
            textField.text = ""
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Force text to uppercase
        if let text = textField.text {
            textField.text = (text as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
            return false
        }

        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard on return
        textField.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Enable the cancel button since we've changed the text
        cancelButton.enabled = true
    }
    
    // MARK: - Actions
    @IBAction func selectFromAlbum(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectFromCamera(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sharePressed(sender: UIBarButtonItem) {
        // Generate the memed image
        memedImage = generateMemedImage()
        
        // Set up and display the activity view controller
        let activityViewController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        
        // Add a completion handler to fire after the meme has been shared
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            
            // Make sure it completed
            if (completed == true) {
                // Save the image
                self.save()
            } else {
                // Not completed, display an error message
                if let _ = activityError {
                    let alertController = UIAlertController(title: "Uh oh!", message: "Something went wrong sharing your meme!", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Bummer", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        // Return to the Sent Memes list
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Notifications
    func subscribeToKeyboardNotifications() {
        // Subscribe to both keyboardWillShow and keyboardWillHide notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        // Remove keyboard show/hide notification subscriptions
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Meme functions
    func save() {        
        // Create a new meme model
        let newMeme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: selectedImageView.image, memedImage: memedImage);
    
        // Save the meme model in the AppDelegate array
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(newMeme)
        
        // Dismiss the editor
        dismissViewControllerAnimated(true, completion: nil)       
    }
    
    func generateMemedImage() -> UIImage {
        
        // Get the origin and dimensions of the image after is has been scaled/fit
        let imageRect = AVMakeRectWithAspectRatioInsideRect(selectedImageView.image!.size, selectedImageView.bounds);
        
        // Get toolbar heights to help calculate the size of the meme image
        let imageToolbarHeight = imageToolbar.frame.size.height
        let shareToolbarHeight = shareToolbar.frame.size.height
        
        // Create the size object (height and width of the image/text - the total height of toolbars
        let memeSize = CGSizeMake(imageRect.width, (view.frame.size.height - (imageToolbarHeight + shareToolbarHeight)))
        
        // Create a rectangle obejct to draw the memed image at specific coords x = 0, (y = -toolbarHeight)
        let memeRect = CGRectMake(-(imageRect.origin.x), (view.frame.origin.y
            - shareToolbarHeight), view.bounds.size.width,view.bounds.size.height)
        
        
        // Get the image context with the size (height, width) from memeSize
        UIGraphicsBeginImageContextWithOptions(memeSize, true, 0.0)
        
        // Draw that view at the rects coords
        view.drawViewHierarchyInRect(memeRect,
            afterScreenUpdates: true)
        
        // Create the image fron the graphics context
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return memedImage
    }
    
    // MARK: - Helpers
    func prepareTextField(textField: UITextField, defaultText: String) {
        super.viewDidLoad()
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -4
        ]
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.autocapitalizationType = .AllCharacters
        textField.textAlignment = .Center
    }
}

