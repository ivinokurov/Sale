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
    @IBOutlet weak var categoryNameUnderView: UIView!
    @IBOutlet weak var dismissCategoryButton: UIButton!
    
    var textUnderlineDecorationDic: Dictionary<UITextField, UIView>!
    
    var parentView: UIView? = nil
    var isCategoryEditing: Bool = false
    var swipedRowIndex: Int? = nil
    var selectedCategoryName: String? = nil
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.parentView = Utilities.mainController!.view
        
        self.addNewCategoryBarItem()
        
        if (CategoriesDBRules.getAllCategories()?.count)! > 0 {
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            self.selectedCategoryName = CategoriesDBRules.getAllCategories()![0].value(forKeyPath: "name") as? String
        }
        
        Utilities.createDismissButton(button: self.dismissCategoryButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil
        )
        
        self.textUnderlineDecorationDic = [self.categoryNameTextField : self.categoryNameUnderView]
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Utilities.customizePopoverView(customizedView: self.categoryView)
        
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.categoryNameTextField, self.addOrRenameCategoryButton, self.cancelCategoryButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.categoryNameUnderView])
        
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.accentColor

        self.tableView.reloadData()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.setCategoryViewFrame()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = 0
            self.setCategoryViewFrame()
        }
    }
    
    func setCategoryViewFrame() {
        self.categoryView.center.x = self.parentView!.center.x
        self.categoryView.frame.origin.y = (UIScreen.main.bounds.height - self.keyboardHeight - self.categoryView.frame.height) / 2
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
    }
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size , with: coordinator)

        self.categoryView.removeFromSuperview()
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isCategoryViewPresented {
                self.parentView?.addSubview(self.categoryView)
                self.setCategoryViewFrame()
            }
        })
    }
    */
    @objc func showCategoryView() {
        if !self.isCategoryEditing {
            self.categoryNameTextField.text = ""
        }

        self.categoryView.alpha = 0.0
        
        self.categoryView.autoresizingMask =  [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.categoryView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        self.setCategoryViewActionTitles()
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.categoryView)
        
        self.setCategoryViewFrame()
        
        Utilities.makeViewFlexibleAppearance(view: self.categoryView)
        self.dismissCategoryButton.tintColor = Utilities.accentColor
    }
    
    func removeCategoryView() {
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.categoryView.alpha = 0.0
        }), completion: { (completed: Bool) in
        })
    }
    
    @IBAction func addNewCategory(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        if self.checkCategoryInfo() {
            if let newCategoryName = self.categoryNameTextField.text  {
                if !CategoriesDBRules.isTheSameCategoryPresents(categoryName: newCategoryName) {
                    if newCategoryName != Utilities.blankString {
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
                        }
                    }
                } else {
                    if !self.isCategoryEditing {
                        InfoAlertView().showInfoAlertView(infoTypeImageName: Utilities.infoViewImageNames.error.rawValue, parentView: Utilities.mainController!.view, messageToShow: "Такая категория товаров уже присутствует!")
                    } else {
                        self.removeCategoryView()
                        self.isCategoryEditing = false
                    }
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
            self.isCategoryEditing = false
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoriesDBRules.getAllCategories()?.count ?? 0
    }
    
    func updateProductsTable() {
        let navController = Utilities.productsSplitController!.viewControllers[1] as! UINavigationController
        let categoriesController = navController.topViewController as! ProductsViewController
        categoriesController.productsTableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCategoryName = CategoriesDBRules.getAllCategories()![indexPath.row].value(forKeyPath: "name") as? String
        self.updateProductsTable()
    }
    
    func checkCategoryInfo() -> Bool {
        if self.categoryNameTextField.text == Utilities.blankString {
            InfoAlertView().showInfoAlertView(infoTypeImageName: Utilities.infoViewImageNames.error.rawValue, parentView: Utilities.mainController!.view, messageToShow: "Отсутствует название категории!")
            return false
        } else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCellId", for: indexPath)

        let categoryName = CategoriesDBRules.getAllCategories()![indexPath.row].value(forKeyPath: "name") as? String
        cell.textLabel?.text = categoryName
        
        let category = CategoriesDBRules.getCategiryByName(categoryName: categoryName!)!
        
        cell.detailTextLabel!.text = "Товаров: " + String(ProductsDBRules.getAllProductsForCategory(productCategory: category)!.count.description) // + " на сумму " + ProductsDBRules.getCategoryProductsTotalPrice(productCategory: category).description + " руб."
        
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
        
        if self.selectedCategoryName != nil && self.selectedCategoryName == categoryName {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let category = CategoriesDBRules.getAllCategories()?[indexPath.row]
        let name = category!.value(forKeyPath: "name") as? String
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let deleteCategory: (() -> ()) = {
                ProductsDBRules.deleteCategoryProducts(productCategory: CategoriesDBRules.getCategiryByName(categoryName: name!)!)
                CategoriesDBRules.deleteCategory(categoryName: name!)
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.tableView.endUpdates()
                
                self.updateProductsTable()
            }
            
            let deleteCategoryAlert = DeleteAlertView()
            deleteCategoryAlert.showDeleteAlertView(parentView: self.parentView!, messageToShow: "Удалить эту категорию?", deleteHandler: deleteCategory)
            
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
    
    @IBAction func addUnderView(_ sender: UITextField) {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.textUnderlineDecorationDic.first(where: { $0.key == sender })?.value.backgroundColor = Utilities.accentColor
        }), completion: { (completed: Bool) in
        })
    }
    
    @IBAction func removeUnderView(_ sender: UITextField) {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.textUnderlineDecorationDic.first(where: { $0.key == sender })?.value.backgroundColor = Utilities.inactiveColor
        }), completion: { (completed: Bool) in
        })
    }
    
    @IBAction func dismissCategoryView(_ sender: UIButton) {
        Utilities.decorateDismissButtonTap(buttonToDecorate: sender, viewToDismiss: self.categoryView)
        Utilities.dismissKeyboard(conroller: self)
    }
    
}
