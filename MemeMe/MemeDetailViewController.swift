//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Jeff Tilson on 2015-12-10.
//  Copyright © 2015 Jeff Tilson. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    var meme: Meme!
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        // Add a 'edit' button to the navigation bar
        let editMemeButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: Selector("editMeme"))
        navigationItem.rightBarButtonItem = editMemeButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true;
        
        // Set image view image
        memeImageView.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.hidden = false;
    }
    
    // MARK: - Edit Meme
    func editMeme() {
        // Get the storyboard and MemeEditorViewController
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let editorVC = storyboard.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        
        // Set the optional meme to edit in the edit VC
        editorVC.editMeme = meme
        
        // Show the editor
        presentViewController(editorVC, animated: true, completion: {
            // Pop back to the list view so we don't dismiss the editor to the old meme
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
}