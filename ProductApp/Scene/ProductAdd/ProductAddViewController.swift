//
//  ProductAddViewController.swift
//  ProductApp
//
//  Created by Kuru on 2024-05-02.
//

import UIKit

protocol SecondViewControllerDelegate {
    func didDismissSecondViewController()
}

class ProductAddViewController: UIViewController {

    // MARK: Properties
    var viewModel: ProductAddViewModel?
    var delegate: SecondViewControllerDelegate?
    public class var storyboardName: String {
        return "Main"
    }
    
    static func create(viewModel: ProductAddViewModel) -> ProductAddViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: ProductAddViewController.self)) as? ProductAddViewController
        viewController!.viewModel = viewModel
        return viewController!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        self.inputData()
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didDismissSecondViewController()
        }
    }
    
    func inputData() {
        let actionSheet = UIAlertController(title: "Enter Your Product Name", message: nil, preferredStyle: .alert)
        
        actionSheet.addTextField { (textField1) in
            textField1.placeholder = "product Name"
        }
        
        // Add actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Handle OK action
            guard let textField1 = actionSheet.textFields?[0].text else {
                return
            }
            self.createData(name: textField1)
        }
        
        // Add actions to action sheet
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(okAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func createData(name: String) {
        Datamanager.shared.createTask(name: name)
       // LocalStorageForList.shared.setAccountDetail(items: )
    }
    
}
