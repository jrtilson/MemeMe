//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Jeff Tilson on 2015-12-07.
//  Copyright © 2015 Jeff Tilson. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    // Set app delegate so we can update the meme array
    var appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    
    // Get our memes from the AppDelegate
    var memes: [Meme] {
        return appDelegate.memes
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a 'new' button to the navigation bar
        let addNewMemeButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: Selector("addNewMeme"))
        navigationItem.rightBarButtonItem = addNewMemeButton
        navigationItem.title = "Sent Memes"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Navigation Bar Item actions
    func addNewMeme() {
        // Get the storyboard and MemeEditorViewController
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let editorVC = storyboard.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        
        presentViewController(editorVC, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return total number of memes
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell")!
        let meme = memes[indexPath.row]

        // Set the name and image
        cell.textLabel?.text = meme.topText
        cell.imageView?.image = meme.memedImage
        
        // Grab the detail label if it exists and put the bottom text in
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = meme.bottomText
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Show the meme detail view controller
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController!.pushViewController(detailController, animated: true)
    }
    
    // Allow cell editing
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Table editing actions
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Allow/handle deletes
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            tableView.beginUpdates()
            
            // Delete the meme from the app delegate
            appDelegate.memes.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }

}
