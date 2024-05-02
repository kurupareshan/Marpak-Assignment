//
//  ViewController.swift
//  ProductApp
//
//  Created by Kuru on 2024-05-02.
//

import UIKit
import Realm
import RealmSwift

class ViewController: UIViewController, SecondViewControllerDelegate {

    // MARK: - PROPERTIES
    
    var viewModel: ProductListViewModel?
    public class var storyboardName: String {
        return "Main"
    }
    var dataForTableView: Results<DetailsViewModel>!
    var dataForCollectionView: Results<DetailsViewModelForGrid>!
    var dragItemOfTableView = DetailsViewModel()
    var dragItemOfCollectionView = DetailsViewModelForGrid()
    //var indexpath = Int()
    // MARK: - OUTLETS
    
    @IBOutlet var productListTableView: UITableView!
    @IBOutlet var productCollectionView: UICollectionView!
    static func create(viewModel: ProductListViewModel) -> ViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
        let viewController = storyboard.instantiateViewController(withIdentifier: String(describing: ViewController.self)) as? ViewController
        viewController!.viewModel = viewModel
        return viewController!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productListTableView.register(UINib(nibName: "ProductListTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductListTableViewCell")
        self.productListTableView.delegate = self
        self.productListTableView.dataSource = self
        fetchUserDataForTableView()
        fetchUserDataForCollectionView()
        
        productCollectionView.register(UINib(nibName: "ProductListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductListCollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        productCollectionView.collectionViewLayout = layout
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        
        productListTableView.dragInteractionEnabled = true
        productListTableView.dragDelegate = self
        productListTableView.dropDelegate = self
        productCollectionView.dropDelegate = self
        productCollectionView.dragDelegate = self
        
    }
    
    
    @IBAction func presentProductAddView(_ sender: Any) {
        let vc = ProductAddViewController.create(viewModel: ProductAddViewModel())
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func didDismissSecondViewController() {
        fetchUserDataForTableView()
    }
    
    func fetchUserDataForTableView() {
        dataForTableView = Datamanager.shared.fetchTasks()
        DispatchQueue.main.async {
            self.productListTableView.reloadData()
        }
    }
    
    func updateUserData(modal: DetailsViewModelForGrid,  name: String) {
        DataManagerForGrid.shared.updateTask(task: modal, name: name)
            fetchUserDataForCollectionView()
    }
    
    func addUserDataForCollectionView(name: String) {
        DispatchQueue.main.async {
            DataManagerForGrid.shared.createTask(name: name)
            self.fetchUserDataForCollectionView()
        }
    }
    
    func addUserTableView(name: String) {
        DispatchQueue.main.async {
            Datamanager.shared.createTask(name: name)
            self.fetchUserDataForTableView()
        }
    }
    
    func fetchUserDataForCollectionView() {
        dataForCollectionView = DataManagerForGrid.shared.fetchTasks()
        DispatchQueue.main.async {
            self.productCollectionView.reloadData()
        }
    }
    
    func deleteItem(modal: DetailsViewModel) {
        DispatchQueue.main.async {
            Datamanager.shared.deleteTask(task: modal)
            self.fetchUserDataForTableView()
        }
    }
    
    func deleteItemOfCollectionView(modal: DetailsViewModelForGrid) {
        DispatchQueue.main.async {
            DataManagerForGrid.shared.deleteTask(task: modal)
            self.fetchUserDataForCollectionView()
        }
    }
    
    
    @IBAction func exportPdf(_ sender: Any) {
        let pdfPath = createPDF()
        sharePDF(pdfPath)
    }
    
    // PDF Documentation

    func createPDF() -> String {
        let pageSize = CGSize(width: 612, height: 792) // US Letter size in points (8.5 x 11 inches)
        let pdfPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/textArrayContent.pdf"
        
        UIGraphicsBeginPDFContextToFile(pdfPath, CGRect.zero, nil)
        UIGraphicsBeginPDFPageWithInfo(CGRect(origin: .zero, size: pageSize), nil)
        
        // Draw content of the text array onto the PDF
        let textFont = UIFont.systemFont(ofSize: 12)
        let textAttributes = [NSAttributedString.Key.font: textFont]
        
        var yPos: CGFloat = 50 // Starting Y position
        for text in dataForCollectionView {
            let attributedText = NSAttributedString(string: text.name, attributes: textAttributes)
            let textRect = CGRect(x: 50, y: yPos, width: pageSize.width - 100, height: 20) // Adjust width and height as needed
            attributedText.draw(in: textRect)
            yPos += 30
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfPath
    }
    
    func sharePDF(_ pdfPath: String) {
        let pdfURL = URL(fileURLWithPath: pdfPath)
        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.dataForTableView.count > 0) {
            return self.dataForTableView.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListTableViewCell", for: indexPath) as! ProductListTableViewCell
        cell.textLabel?.text = dataForTableView[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = dataForTableView[indexPath.row].name
       // self.indexpath = indexPath.row
        dragItemOfTableView = dataForTableView[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataForTableView[indexPath.row]
        let actionSheet = UIAlertController(title: "Delete Data", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteItem(modal: item)
        }))
        present(actionSheet, animated: true)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        for item in coordinator.session.items {
            // Retrieve data from the drag item
            item.itemProvider.loadObject(ofClass: NSString.self) { (provider, error) in
                if let text = provider as? String {
                    // Update collection view data source
                    self.addUserTableView(name: text)
                    self.deleteItemOfCollectionView(modal: self.dragItemOfCollectionView)
                }
            }
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate, UICollectionViewDragDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  self.dataForCollectionView.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductListCollectionViewCell", for: indexPath) as! ProductListCollectionViewCell
        cell.textLabel?.text = self.dataForCollectionView[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // Handle dropped items
        for item in coordinator.session.items {
            // Retrieve data from the drag item
            item.itemProvider.loadObject(ofClass: NSString.self) { (provider, error) in
                if let text = provider as? String {
                    // Update collection view data source
                    self.addUserDataForCollectionView(name: text)
                    self.deleteItem(modal: self.dragItemOfTableView)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let draggedItem = dataForCollectionView[indexPath.item].name
        dragItemOfCollectionView = dataForCollectionView[indexPath.item]
        let itemProvider = NSItemProvider(object: draggedItem as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataForCollectionView[indexPath.row]
        let actionSheet = UIAlertController(title: "Delete Data", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteItemOfCollectionView(modal: item)
        }))
        present(actionSheet, animated: true)
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

