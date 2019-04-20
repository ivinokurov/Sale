//
//  ProductsViewController.swift
//  Sale
//


import UIKit
import CoreData

class ProductsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var productView: UIView!
    
    @IBOutlet weak var productsTableView: UITableView!

    @IBOutlet weak var productViewTitleLabel: UILabel!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productDescTextField: UITextField!
    @IBOutlet weak var productCountTextField: UITextField!
    @IBOutlet weak var productPriceTextField: UITextField!
    @IBOutlet weak var productBarcodeTextField: UITextField!
    @IBOutlet weak var itemsButton: UIButton!
    @IBOutlet weak var kilosButton: UIButton!
    @IBOutlet weak var litersButton: UIButton!
    @IBOutlet weak var addOrEditProductButton: UIButton!
    @IBOutlet weak var cancelProductButton: UIButton!
    
    @IBOutlet weak var productNameUnderView: UIView!    
    @IBOutlet weak var productDescUnderView: UIView!
    @IBOutlet weak var productBarcodeUnderView: UIView!
    @IBOutlet weak var productCountUnderView: UIView!
    @IBOutlet weak var productPriceUnderView: UIView!
    @IBOutlet weak var dismissCategoryButton: UIButton!
    
    var textUnderlineDecorationDic: Dictionary<UITextField, UIView>!
    
    var parentView: UIView? = nil
    var isProductViewPresented: Bool = false
    var isProductEditing: Bool = false
    var swipedRowIndex: Int? = nil
    var selectedProductBarcode: String? = nil
    var keyboardHeight: CGFloat = 0.0
    var selectedProductMeasure: Int = Utilities.measures.items.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.mainController!.view 
        self.productsTableView.estimatedRowHeight = 140
        
        self.addNewProductBarItem()
        
        self.productCountTextField.delegate = self
        self.productPriceTextField.delegate = self
        self.productBarcodeTextField.delegate = self
        
        self.productsTableView.dataSource = self
        self.productsTableView.delegate = self
        
        self.productsTableView.reloadData()

        Utilities.makeLeftViewForTextField(textEdit: self.productPriceTextField, imageName: "Ruble")
        Utilities.makeLeftViewForTextField(textEdit: self.productBarcodeTextField, imageName: "Code")
        self.productPriceTextField.leftView?.tintColor = .red
        
        Utilities.createDismissButton(button: self.dismissCategoryButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil
        )
        
        self.textUnderlineDecorationDic = [self.productNameTextField : self.productNameUnderView, self.productDescTextField : self.productDescUnderView, self.productCountTextField : self.productCountUnderView, self.productPriceTextField : self.productPriceUnderView, self.productBarcodeTextField : self.productBarcodeUnderView]
        
        self.productsTableView.tableFooterView = UIView()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.setProductViewFrame()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let _: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = 0
            self.setProductViewFrame()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Utilities.customizePopoverView(customizedView: self.productView)
        
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.productNameTextField, self.productDescTextField, self.productBarcodeTextField, self.itemsButton, self.kilosButton, self.litersButton, self.addOrEditProductButton, self.cancelProductButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.productNameUnderView, self.productDescUnderView, self.productCountUnderView, self.productPriceUnderView, self.productBarcodeUnderView])
        
        Utilities.makeButtonRounded(button: self.itemsButton)
        Utilities.makeButtonRounded(button: self.kilosButton)
        Utilities.makeButtonRounded(button: self.litersButton)
        
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.accentColor
        
        self.productsTableView.reloadData()
    }

    func setProductViewActionTitles() {
        let titlePrefix = (self.getSelectedCategoryName()?.uppercased())!
        if !self.isProductEditing {
            Utilities.makeViewsActive(viewsToMakeActive: [self.productBarcodeTextField])
            self.productViewTitleLabel.text = titlePrefix +  ". НОВЫЙ ТОВАР"
            self.addOrEditProductButton.setTitle("ДОБАВИТЬ", for: .normal)
        } else {
            Utilities.makeViewsInactive(viewsToMakeInactive: [self.productBarcodeTextField])
            self.productViewTitleLabel.text = titlePrefix +  ". ИЗМЕНЕНИЕ ТОВАРА"
            self.addOrEditProductButton.setTitle("ИЗМЕНИТЬ", for: .normal)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.productPriceTextField || textField == self.productCountTextField {
            let allowedCharacters = CharacterSet(charactersIn: Utilities.floatNumbersOnly)
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        if textField == self.productBarcodeTextField {
            let allowedCharacters = CharacterSet(charactersIn: Utilities.digitsOny)
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return true
    }
    
    @IBAction func setProductMeasure(_ sender: UIButton) {
        self.itemsButton.setImage(nil, for: .normal)
        self.kilosButton.setImage(nil, for: .normal)
        self.litersButton.setImage(nil, for: .normal)
        
        switch sender.tag {
        case Utilities.measures.items.rawValue:
            do {
                self.itemsButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selectedProductMeasure = Utilities.measures.items.rawValue
            }
        case Utilities.measures.kilos.rawValue:
            do {
                self.kilosButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selectedProductMeasure = Utilities.measures.kilos.rawValue
            }
        case Utilities.measures.liters.rawValue:
            do {
                self.litersButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selectedProductMeasure = Utilities.measures.liters.rawValue
            }
        default: break
        }
    }
        
    @IBAction func cancelAddOrEditProduct(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.productView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isProductViewPresented = false
            self.isProductEditing = false
        })
    }
    
    func addNewProductBarItem() {
        let rightItemBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showProductView))
        rightItemBarButton.tintColor = Utilities.accentColor
        self.navigationItem.rightBarButtonItem = rightItemBarButton
    }

    func setProductViewFrame() {
        self.productView.center.x = (self.parentView?.center.x)!
        let productViewY = (UIScreen.main.bounds.height - self.keyboardHeight - self.productView.frame.height) / 2
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        self.productView.frame.origin.y =  productViewY < statusBarHeight ? statusBarHeight : productViewY
    }
    
    func getSelectedCategoryName() -> String? {
        let navController = Utilities.productsSplitController!.viewControllers[0] as! UINavigationController
        let categoriesController = navController.topViewController as! CategoriesTableViewController
        return categoriesController.selectedCategoryName
    }
    
    func updateCategoriesTable() {
        let navController = Utilities.productsSplitController!.viewControllers[0] as! UINavigationController
        let categoriesController = navController.topViewController as! CategoriesTableViewController
        categoriesController.tableView.reloadData()
    }
    
    @objc func showProductView() {
        if self.getSelectedCategoryName() == nil {
            Utilities.showErrorAlertView(alertTitle: "ТОВАРЫ", alertMessage: "Не выбрана категория товара!")
            return
        }
        
        if !self.isProductEditing {
            self.productNameTextField.text = ""
            self.productDescTextField.text = ""
            self.productCountTextField.text = ""
            self.productPriceTextField.text = ""
            self.productBarcodeTextField.text = ""
            self.setProductMeasure(self.itemsButton)
        }
        
        self.productView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        self.setProductViewFrame()
        self.productView.alpha = 0.0
        // self.productNameTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.productView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        self.setProductViewActionTitles()
        self.isProductViewPresented = true
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.productView)
        
        Utilities.makeViewFlexibleAppearance(view: self.productView)
        self.dismissCategoryButton.tintColor = Utilities.accentColor
    }
    
    func removeProductView() {
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.productView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isProductViewPresented = false
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)
        
        self.productView.removeFromSuperview()
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isProductViewPresented {
                self.productView.alpha = CGFloat(Utilities.alpha)
                self.parentView?.addSubview(self.productView)
                self.setProductViewFrame()
            }
        })
    }
    
    @IBAction func addNewProduct(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        if self.checkProductInfo() {
            
            let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: self.getSelectedCategoryName()!)
            
            let newName = self.productNameTextField.text!
            let newDesc = self.productDescTextField.text!
            let newPrice = Float(self.productPriceTextField.text!)!
            let newCount = Float(self.productCountTextField.text!)!
            let newMeasure = Int16(self.selectedProductMeasure)
            let newCode = self.productBarcodeTextField.text!
            
            if !self.isProductEditing {
                if !ProductsDBRules.isTheSameBarcodePresents(productBarcode: newCode) {
                    ProductsDBRules.addNewProduct(productCategory: selectedCategory!, productName: newName, productDesc: newDesc, productCount: newCount, productMeasure: newMeasure, productPrice: newPrice, productBarCode: newCode)
                } else {
                    Utilities.showErrorAlertView(alertTitle: "ТОВАРЫ", alertMessage: "Товар с таким штрих кодом уже присутствует!")
                    return
                }
            } else {
                    let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: self.getSelectedCategoryName()!)
                    let product = ProductsDBRules.getAllProductsForCategory(productCategory: selectedCategory!)?[self.swipedRowIndex!]
                    let originCode = product?.value(forKey: "code") as? String
                    
                    ProductsDBRules.changeProduct(originBarcode: originCode!, productNewName: newName, productNewDesc: newDesc, productNewCount: newCount, productNewMeasure: newMeasure, productNewPrice: newPrice, productNewBarcode: newCode)
                
                    self.setProductMeasure(self.itemsButton)
                    self.updateCategoriesTable()
                }
            
            self.removeProductView()
            self.productsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
            
            if self.isProductEditing {
                self.productsTableView.selectRow(at: IndexPath(row: ProductsDBRules.getCategoryProductIndexByName(productCategory: selectedCategory!, productBarcode: newCode)!, section: 0), animated: true, scrollPosition: .none)
                self.isProductEditing = false
            }
        }
    }
    
    func checkProductInfo() -> Bool {

        if self.productNameTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует название товара!")
            return false
        }
        if self.productCountTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует количество товара!")
            return false
        }
        if self.productPriceTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует цена товара!")
            return false
        }
        if self.productBarcodeTextField.text == "" {
            Utilities.showErrorAlertView(alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует штрих код товара!")
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedCategoryName = self.getSelectedCategoryName() {
            let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: selectedCategoryName)
            if selectedCategory == nil {
                return 0
            } else {
                let products = ProductsDBRules.getAllProductsForCategory(productCategory: selectedCategory!)
                return products?.count ?? 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedProductBarcode = (tableView.cellForRow(at: indexPath) as! ProductsTableViewCell).productBarcodeLabel.text
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCellId", for: indexPath) as! ProductsTableViewCell

        cell.initCell(categoryName: self.getSelectedCategoryName()!, indexPath: indexPath, isFiltered: false)
        
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 154.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let barcode = (tableView.cellForRow(at: indexPath) as! ProductsTableViewCell).productBarcodeLabel.text
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить\nтовар", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let deleteHandler: ((UIAlertAction) -> Void)? = { _ in
                
                ProductsDBRules.deleteProductByBarcode(code: barcode!)
                
                self.productsTableView.beginUpdates()
                self.productsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.productsTableView.endUpdates()
            }
            
            Utilities.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "УДАЛЕНИЕ КАТЕГОРИИ ТОВАРОВ", alertMessage: "Удалить эту категорию?", okButtonHandler: deleteHandler,  cancelButtonHandler: nil)
            
            success(true)
        })
        deleteAction.backgroundColor = Utilities.deleteActionBackgroundColor
        deleteAction.image = UIImage(named: "Delete")
        
        let editAction = UIContextualAction(style: .normal, title:  "Изменить\nтовар", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            self.isProductEditing = true
            self.swipedRowIndex = indexPath.row
            self.showProductView()
            
            let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: self.getSelectedCategoryName()!)
            
            let product = ProductsDBRules.getAllProductsForCategory(productCategory: selectedCategory!)?[indexPath.row]
            self.productNameTextField.text = product?.value(forKey: "name") as? String
            self.productDescTextField.text = product?.value(forKey: "desc") as? String
            self.productCountTextField.text = (product?.value(forKeyPath: "count") as? Float)?.description
            self.productPriceTextField.text = (product?.value(forKeyPath: "price") as? Float)?.description
            self.productBarcodeTextField.text = product?.value(forKey: "code") as? String
            
            let pseudoButton = UIButton()
            pseudoButton.tag = Int(product?.value(forKey: "measure") as! Int16)
            self.setProductMeasure(pseudoButton)
            
            success(true)
        })
        editAction.backgroundColor = Utilities.editActionBackgroundColor
        editAction.image = UIImage(named: "Edit")
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }
    
    @IBAction func checkBarcodeStringLength(_ sender: UITextField) {
        if (self.productBarcodeTextField.text!.count > 13) {
            self.productBarcodeTextField.deleteBackward()
        }
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
    
    @IBAction func dismissProductView(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissView(viewToDismiss: self.productView)
        Utilities.dismissKeyboard(conroller: self)
        self.isProductViewPresented = false
    }
    
}

