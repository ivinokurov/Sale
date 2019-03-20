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
    
    var parentView: UIView? = nil
    var isProductViewPresented: Bool = false
    var isProductEditing: Bool = false
    var swipedRowIndex: Int? = nil
    var selcctedProductMeasure: Int = Utilities.measures.items.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.splitController?.view
        
        Utilities.makeButtonRounded(button: self.itemsButton)
        Utilities.makeButtonRounded(button: self.kilosButton)
        Utilities.makeButtonRounded(button: self.litersButton)
        
        self.addNewProductBarItem()
        
        self.productPriceTextField.delegate = self
        self.productBarcodeTextField.delegate = self
        
        self.productsTableView.dataSource = self
        self.productsTableView.delegate = self
        
        self.productsTableView.reloadData()

        Utilities.makeLeftViewForTextField(textEdit: self.productPriceTextField, imageName: "Ruble")
        Utilities.makeLeftViewForTextField(textEdit: self.productBarcodeTextField, imageName: "Code")
    }

    func setProductViewActionTitles() {
        if !self.isProductEditing {
            self.productViewTitleLabel.text = "НОВЫЙ ТОВАР"
            self.addOrEditProductButton.setTitle("ДОБАВИТЬ", for: .normal)
        } else {
            self.productViewTitleLabel.text = "ИЗМЕНЕНИЕ ТОВАРА"
            self.addOrEditProductButton.setTitle("ИЗМЕНИТЬ", for: .normal)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.productPriceTextField || textField == self.productCountTextField {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        if textField == self.productBarcodeTextField {
            let allowedCharacters = CharacterSet(charactersIn:"0123456789")
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
                self.selcctedProductMeasure = Utilities.measures.items.rawValue
            }
        case Utilities.measures.kilos.rawValue:
            do {
                self.kilosButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selcctedProductMeasure = Utilities.measures.kilos.rawValue
            }
        case Utilities.measures.liters.rawValue:
            do {
                self.litersButton.setImage(UIImage(named: "Check"), for: .normal)
                self.selcctedProductMeasure = Utilities.measures.liters.rawValue
            }
        default: break
        }
    }
        
    @IBAction func cancelAddOrRenameProduct(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.productView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isProductViewPresented = false
            self.isProductEditing = false
            Utilities.removeOverlayView()
        })
    }
    
    func addNewProductBarItem() {
        let rightItemBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showProductView))
        rightItemBarButton.tintColor = Utilities.accentColor
        self.navigationItem.rightBarButtonItem = rightItemBarButton
        self.customizeProductView()
    }
    
    func customizeProductView() {
        self.productView.layer.cornerRadius = 4
        self.productView.layer.borderColor = Utilities.accentColor.cgColor
        self.productView.layer.borderWidth = 0.4
    }

    func setProductViewFrame() {
        let centerX = (self.parentView?.center.x)!
        let centerY = (self.parentView?.center.y)!
        
        self.productView.center.x = centerX
        self.productView.center.y = centerY - (centerY / 2 - 2 * ((self.navigationController?.navigationBar.frame.height)!))
    }
    
    func getSelectedCategoryName() -> String? {
        let navController = Utilities.splitController!.viewControllers[0] as! UINavigationController
        let categoriesController = navController.topViewController as! CategoriesTableViewController
        return categoriesController.selectedCategoryName
    }
    
    @objc func showProductView() {
        if self.getSelectedCategoryName() == nil {
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "ТОВАРЫ", alertMessage: "Не выбрана категория товара", alertButtonHandler: nil)
            return
        }
        
        if !self.isProductEditing {
            self.productNameTextField.text = ""
            self.productDescTextField.text = ""
            self.productCountTextField.text = ""
            self.productPriceTextField.text = ""
            self.productBarcodeTextField.text = ""
        }
        
        self.productView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        self.setProductViewFrame()
        self.productView.alpha = 0.0
        self.productNameTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.productView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.setProductViewActionTitles()
        self.isProductViewPresented = true
        self.productView.alpha = CGFloat(Utilities.alpha)
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.productView)
    }
    
    func removeProductView() {
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.productView.alpha = 0.0
        }), completion: { (completed: Bool) in
            Utilities.removeOverlayView()
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
            let newDesc = self.productDescTextField.text == "" ? "Без описания" : self.productDescTextField.text!
            let newPrice = Float(self.productPriceTextField.text!)!
            let newCount = Float(self.productCountTextField.text!)!
            let newMeasure = Int16(self.selcctedProductMeasure)
            let newCode = self.productBarcodeTextField.text!
            
            if !self.isProductEditing {
                if !ProductsDBRules.isTheSameBarcodePresents(productBarcode: newCode) {
                    ProductsDBRules.addNewProduct(productCategory: selectedCategory!, productName: newName, productDesc: newDesc, productCount: newCount, productMeasure: newMeasure, productPrice: newPrice, productBarCode: newCode)
                } else {
                    Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "ТОВАРЫ", alertMessage: "Товар с таким штрих кодом уже присутствует", alertButtonHandler: nil)
                    return
                }
            } else {
                    let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: self.getSelectedCategoryName()!)
                    let product = ProductsDBRules.getCategoryProducts(productCategory: selectedCategory!)?[self.swipedRowIndex!]
                    let originCode = product?.value(forKey: "code") as? String
                    
                    ProductsDBRules.changeProduct(originBarcode: originCode!, productNewName: newName, productNewDesc: newDesc, productNewCount: newCount, productNewMeasure: newMeasure, productNewPrice: newPrice, productNewBarcode: newCode)
                }
            self.removeProductView()
            self.productsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
        }
    }
    
    func checkProductInfo() -> Bool {

        if self.productNameTextField.text == "" {
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует название товара", alertButtonHandler: nil)
            return false
        }
        
        if self.productCountTextField.text == "" {
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует количество товара", alertButtonHandler: nil)
            return false
        }
        
        if self.productPriceTextField.text == "" {
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует цена товара", alertButtonHandler: nil)
            return false
        }
        
        if self.productBarcodeTextField.text == "" {
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "ТОВАРЫ", alertMessage: "Отсутствует штрих код товара", alertButtonHandler: nil)
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
                let products = ProductsDBRules.getCategoryProducts(productCategory: selectedCategory!)
                return products?.count ?? 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCellId", for: indexPath) as! ProductsTableViewCell
        
        cell.initCell(categoryName: self.getSelectedCategoryName()!, indexPath: indexPath, isFiltered: false)
        
        Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let code = (tableView.cellForRow(at: indexPath) as! ProductsTableViewCell).productBarcodeLabel.text
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let deleteHandler: ((UIAlertAction) -> Void)? = { _ in
                
                ProductsDBRules.deleteProductByBarcode(code: code!)
                
                self.productsTableView.beginUpdates()
                self.productsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.productsTableView.endUpdates()
            }
            
            Utilities.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "УДАЛЕНИЕ КАТЕГОРИИ ТОВАРОВ", alertMessage: "Удалить эту категорию?", okButtonHandler: deleteHandler,  cancelButtonHandler: nil)
            
            success(true)
        })
        deleteAction.backgroundColor = Utilities.deleteActionBackgroundColor
        
        let editAction = UIContextualAction(style: .normal, title:  "Изменить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            self.isProductEditing = true
            self.swipedRowIndex = indexPath.row
            self.showProductView()
            
            let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: self.getSelectedCategoryName()!)
            
            let product = ProductsDBRules.getCategoryProducts(productCategory: selectedCategory!)?[indexPath.row]
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
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
    }

}

