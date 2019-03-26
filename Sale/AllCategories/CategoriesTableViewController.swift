//
//  CategoriesTableViewController.swift
//  Sale
//


import UIKit

class CategoriesTableViewController: UITableViewController {
    
    @IBOutlet var categoryView: UIView!
    @IBOutlet weak var categoryViewTitleLabel: UILabel!
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

        self.parentView = Utilities.splitController!.parent!.view // self.parent!.parent!.view
        
        self.addNewCategoryBarItem()
        
        if (CategoriesDBRules.getAllCategories()?.count)! > 0 {
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            self.selectedCategoryName = CategoriesDBRules.getAllCategories()![0].value(forKeyPath: "name") as? String
        }
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
        rightItemBarButton.tintColor = Utilities.barButtonItemColor
        self.navigationItem.rightBarButtonItem = rightItemBarButton
        
        Utilities.customizePopoverView(customizedView: self.categoryView)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)

        self.categoryView.removeFromSuperview()
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isCategoryViewPresented {
                self.parentView?.addSubview(self.categoryView)
                self.categoryView.center = self.getCategoriesViewCenterPoint()
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

        self.categoryView.center = self.getCategoriesViewCenterPoint()
        self.categoryView.alpha = 0.0
        self.categoryNameTextField.becomeFirstResponder()
        self.categoryView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
            
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.categoryView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.setCategoryViewActionTitles()
        self.isCategoryViewPresented = true
        self.categoryView.alpha = 0.94
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.categoryView)
        
        Utilities.makeViewFlexibleAppearance(view: self.categoryView)
    }
    
    func removeCategoryView() {
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.categoryView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isCategoryViewPresented = false
        })
    }
    
    @IBAction func addNewCategory(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        if self.checkCategoryInfo() {
            if let newCategoryName = self.categoryNameTextField.text  {
                if !CategoriesDBRules.isTheSameCategoryPresents(categoryName: newCategoryName) {
                    if newCategoryName != "" {
                        if self.isCategoryEditing {
                            let originCategoryName = CategoriesDBRules.getAllCategories()![self.swipedRowIndex!].value(forKeyPath: "name") as? String
                            CategoriesDBRules.changeCategory(originCategoryName: originCategoryName!, newCategoryName: newCategoryName)
                        } else {
                            CategoriesDBRules.addNewCategory(categoryName: newCategoryName)
                        }
                        self.removeCategoryView()
                        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
                        if self.isCategoryEditing {
                            self.tableView.selectRow(at: IndexPath(row: self.swipedRowIndex!, section: 0), animated: true, scrollPosition: .none)
                            self.isCategoryEditing = false
                        } else {
                            self.tableView.selectRow(at: IndexPath(row: CategoriesDBRules.getCategoryIndexByName(categoryName: self.selectedCategoryName!) ?? 0, section: 0), animated: true, scrollPosition: .none)
                        }
                    }
                } else {
                    Utilities.showErrorAlertView(alertTitle: "КАТЕГОРИЯ ТОВАРОВ", alertMessage: "Такая категория товаров уже присутствует!")
                }
            }
        }
    }
    
    @IBAction func cancelAddOrRenameCategory(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.categoryView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isCategoryViewPresented = false
            self.isCategoryEditing = false
        })
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
    
    func checkCategoryInfo() -> Bool {
        if self.categoryNameTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "КАТЕГОРИИ", alertMessage: "Отсутствует название категории!")
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCellId", for: indexPath)

        let categoryName = CategoriesDBRules.getAllCategories()![indexPath.row].value(forKeyPath: "name") as? String
        cell.textLabel?.text = categoryName
        cell.detailTextLabel!.text = "Товаров категории: " + String(ProductsDBRules.getAllProductsForCategory(productCategory: CategoriesDBRules.getCategiryByName(categoryName: categoryName!)!)!.count.description)
        
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = CategoriesDBRules.getAllCategories()?[indexPath.row]
        let name = category!.value(forKeyPath: "name") as? String
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let deleteHandler: ((UIAlertAction) -> Void)? = { _ in
                ProductsDBRules.deleteCategoryProducts(productCategory: CategoriesDBRules.getCategiryByName(categoryName: name!)!)
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
