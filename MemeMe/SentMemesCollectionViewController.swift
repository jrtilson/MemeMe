//
//  SentMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Jeff Tilson on 2015-12-07.
//  Copyright © 2015 Jeff Tilson. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // Get our memes from the AppDelegate
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
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
        collectionView?.reloadData()
        setupFlowLayout(view.frame.size)
    }
    
    // Handle device size change (orientation change)
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        // This will be called even if another view controller is the only one on screen. Make sure this collection view is loaded
        if isViewLoaded() {
            setupFlowLayout(size)
        }
    }
    
    // MARK: - Navigation Bar Item actions
    func addNewMeme() {
        // Get the storyboard and MemeEditorViewController
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let editorVC = storyboard.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        
        presentViewController(editorVC, animated: true, completion: nil)
    }

    // MARK: - UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return total number of memes
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath)
        let meme = memes[indexPath.row]
        
        let imageView = UIImageView(image: meme.memedImage)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        cell.backgroundView = imageView
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Show the meme detail view controller
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController!.pushViewController(detailController, animated: true)
    }
    
    // MARK: - Helpers
    func setupFlowLayout(size: CGSize) {
        
        // Found some hints for this here: https://discussions.udacity.com/t/mememe-collectionview-flow-layout/39382

        // Minimum space
        let space: CGFloat = 1.0
    
        var columns: CGFloat
        
        // If width is greater than height, we're in some version of landscape mode
        if size.width >= size.height {
            columns = 5.0
        } else {
            // Portrait-like mode
            columns = 3.0
        }
        
        // Set up the height/width
        let dimension = (size.width - ((columns - 1) * space)) / columns

        // Set flowlayout values
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)

    }
}
