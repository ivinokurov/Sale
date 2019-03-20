//
//  CategoriesTableViewController.swift
//  Sale
//


import UIKit

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet weak var categoryViewTitleLabel: UILabel!
    @IBOutlet var categoryView: UIView!
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var addOrRenameCategoryButton: UIButton!
    @IBOutlet weak var cancelCategoryButton: UIButton!
    
    var parentView: UIView? = nil
    var isCategoryEditing: Bool = false
    var isCategoryViewPresented: Bool = false
    var swipedRowIndex: Int? = nil
    var selectedCategoryName: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.parentView = Utilities.splitController!.view // self.parent!.parent!.view
        
        self.addNewCategoryBarItem()
        
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        self.selectedCategoryName = CategoriesDBRules.getAllCategories()![0].value(forKeyPath: "name") as? String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setCategoryViewActionTitles() {
        if !self.isCategoryEditing {
            self.categoryViewTitleLabel.text = "НОВАЯ КАТЕГОРИЯ ТОВАРОВ"
            self.addOrRenameCategoryButton.setTitle("ДОБАВИТЬ", for: .normal)
        } else {
            self.categoryViewTitleLabel.text = "ИЗМЕНЕНИЕ КАТЕГОРИИ ТОВАРОВ"
            self.addOrRenameCategoryButton.setTitle("ИЗМЕНИТЬ", for: .normal)
        }
    }
    
    func addNewCategoryBarItem() {
        let rightItemBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCategoryView))
        rightItemBarButton.tintColor = Utilities.accentColor
        self.navigationItem.rightBarButtonItem = rightItemBarButton
        
        self.customizeCategoryView()
    }
    
    func customizeCategoryView() {
        self.categoryView.layer.cornerRadius = 4
        self.categoryView.layer.borderColor = Utilities.accentColor.cgColor
        self.categoryView.layer.borderWidth = 0.4
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)
        
        self.categoryView.removeFromSuperview()
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isCategoryViewPresented {
                self.categoryView.alpha = 0.94
                self.parentView?.addSubview(self.categoryView)
                self.categoryView.center = self.getCategoriesViewCenterPoint()
                self.categoryNameTextField.becomeFirstResponder()
            }
        })
    }
    
    func getCategoriesViewCenterPoint() -> CGPoint {
        let centerX = (self.parentView?.center.x)!
        let centerY = (self.parentView?.center.y)! * 0.5
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    @objc func showCategoryView() {
        
        if !self.isCategoryEditing {
            self.categoryNameTextField.text = ""
        }
        
        self.categoryView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        self.categoryView.center = self.getCategoriesViewCenterPoint()
        self.categoryView.alpha = 0.0
        self.categoryNameTextField.becomeFirstResponder()
            
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.categoryView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.setCategoryViewActionTitles()
        self.isCategoryViewPresented = true
        self.categoryView.alpha = 0.94
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.categoryView)
    }
    
    func removeCategoryView() {
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.categoryView.alpha = 0.0
        }), completion: { (completed: Bool) in
            Utilities.removeOverlayView()
            self.categoryView.removeFromSuperview()
            self.isCategoryViewPresented = false
        })
    }
    
    @IBAction func addNewCategory(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        if let newCategoryName = self.categoryNameTextField.text  {
            if !CategoriesDBRules.isTheSameCategoryPresents(categoryName: newCategoryName) {
                if newCategoryName != "" {
                    if self.isCategoryEditing {
                        let originCategoryName = CategoriesDBRules.getAllCategories()![self.swipedRowIndex!].value(forKeyPath: "name") as? String
                        CategoriesDBRules.changeCategory(originCategoryName: originCategoryName!, newCategoryName: newCategoryName)
                        self.isCategoryEditing = false
                    } else {
                        CategoriesDBRules.addNewCategory(categoryName: newCategoryName)
                    }
                    self.removeCategoryView()
                    self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                }
            } else {
                Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "КАТЕГОРИЯ ТОВАРОВ", alertMessage: "Такая категория товаров уже присутствует", alertButtonHandler: nil)
            }
        }
    }
    
    @IBAction func cancelAddOrRenameCategory(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        self.isCategoryEditing = false
        self.removeCategoryView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoriesDBRules.getAllCategories()?.count ?? 0
    }
    
    func reloadProducts() {
        let navController = Utilities.splitController!.viewControllers[1] as! UINavigationController
        let categoriesController = navController.topViewController as! ProductsViewController
        categoriesController.productsTableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCategoryName = CategoriesDBRules.getAllCategories()![indexPath.row].value(forKeyPath: "name") as? String
        
        self.reloadProducts()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCellId", for: indexPath)

        cell.textLabel?.text = CategoriesDBRules.getAllCategories()![indexPath.row].value(forKeyPath: "name") as? String
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = CategoriesDBRules.getAllCategories()?[indexPath.row]
        let name = category!.value(forKeyPath: "name") as? String
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let deleteHandler: ((UIAlertAction) -> Void)? = { _ in
                CategoriesDBRules.deleteCategory(categoryName: name!)
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.tableView.endUpdates()
                
                self.reloadProducts()
            }
            
            Utilities.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "УДАЛЕНИЕ КАТЕГОРИИ ТОВАРОВ", alertMessage: "Удалить эту категорию?", okButtonHandler: deleteHandler,  cancelButtonHandler: nil)
            
            success(true)
        })
        deleteAction.backgroundColor = Utilities.deleteActionBackgroundColor
        
        let editAction = UIContextualAction(style: .normal, title:  "Изменить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            self.isCategoryEditing = true
            self.swipedRowIndex = indexPath.row
            self.showCategoryView()
            self.categoryNameTextField.text = name
            success(true)
        })
        editAction.backgroundColor = Utilities.editActionBackgroundColor
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
}
