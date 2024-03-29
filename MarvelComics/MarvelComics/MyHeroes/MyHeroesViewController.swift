//
//  MyHeroesViewController.swift
//  MarvelComics
//
//  Created by vikas on 14/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MyHeroesViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var fetchedResultsController: NSFetchedResultsController<MyHero>?
    lazy var noMyHeroesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .gray
        label.text = "No favorite heroes yet"
        return label
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: -5, right: 0);
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.groupTableViewBackground]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: - Set up functions
    
    fileprivate func setUpFetchedResultsController() {
        let myHeroFetchRequest: NSFetchRequest<MyHero> = MyHero.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        myHeroFetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: myHeroFetchRequest, managedObjectContext: CoreDataStack.sharedInstance.viewContext, sectionNameKeyPath: nil, cacheName: "myHeros")
        
        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        fetchedResultsController?.delegate = self
    }
    
    // MARK: - Core Data Functions
    
    func deleteMyHero(at indexPath: IndexPath) {
        CoreDataStack.sharedInstance.performViewTask { (viewContext) in
            if let myHeroToDelete = self.fetchedResultsController?.object(at: indexPath) {
                viewContext.delete(myHeroToDelete)
                try? viewContext.save()
            }
        }
    }
    
    // MARK: - Navigations
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HeroDetailViewController {
            if let indexPath = tableView.indexPathForSelectedRow, let myHeroAtIndexPath = fetchedResultsController?.object(at: indexPath) {
                vc.setHero(with: myHeroAtIndexPath)
            }
        }
    }
}
