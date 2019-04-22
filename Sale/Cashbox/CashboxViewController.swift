//
//  MobileCashboxViewController.swift
//  Sale
//


import UIKit
import ExternalAccessory

class CashboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, DTDeviceDelegate {

    let lib = DTDevices.sharedDevice() as! DTDevices
    var isScanActive = false
    
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var purchaseTableView: UITableView!
    @IBOutlet weak var purchaseContainerView: UIView!
    @IBOutlet weak var purchaseSummLabel: UILabel!
    @IBOutlet weak var buyProductButton: BuyButton!
    @IBOutlet weak var barCodeButton: BuyButton!
    @IBOutlet weak var buyProductsButton: UIButton!
    @IBOutlet weak var deleteProductsButton: UIButton!
    @IBOutlet weak var productTypesCollectionView: UICollectionView!
    
    @IBOutlet var personView: UIView!
    @IBOutlet weak var currentPersonNameLabel: UILabel!
    @IBOutlet weak var currentPersonRoleLabel: UILabel!
    @IBOutlet weak var dismissPersonViewButton: UIButton!
    
    @IBOutlet var sessionView: UIView!    
    @IBOutlet weak var sessionStateLabel: UILabel!
    @IBOutlet weak var openSessionView: UIView!
    @IBOutlet weak var closeSessionView: UIView!
    @IBOutlet weak var dismissSessionViewButton: UIButton!
    @IBOutlet weak var openSessionImageView: UIImageView!
    @IBOutlet weak var closeSessionImageView: UIImageView!
    
    @IBOutlet var openSessionGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var closeSessionGestureRecognizer: UITapGestureRecognizer!
    
    var parentView: UIView? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var purchaseViewBarButtonItem: UIBarButtonItem?
    var sessionViewBarButtonItem: UIBarButtonItem?
    var isPurchaseViewPresented: Bool = false
    var isSessionViewPresented: Bool = false
    var isPersonViewPresented: Bool = false
    var selectedCategoryIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var getFromScaner: Bool = false
    var selectedProductRow: Int?
    var productToPurchaseBarcode: String?
    var purchaseViewUpperRightCornerOffest: Dictionary<String, CGFloat> = ["x" : 21.0, "y" : 6]
    
    let dtCommand = FPAbstractCommand()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    @IBAction func openSessionGestureAction(_ sender: UITapGestureRecognizer) {
        Utilities.decorateViewTap(viewToDecorate: self.openSessionView)
        self.openSessionView.alpha = 0.8
        self.closeSessionView.alpha = 1.0
        
        if !SessionDBRules.isCurrentSessionOpened()! {
            self.dismissSessionView(UIButton())
            self.actionsInSession(sessionState: true)
            SessionDBRules.openNewSession()
            
            let person = PersonalDBRules.getPersonByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)!
            
            let name = person.value(forKey: "name") as! String
            let role = person.value(forKey: "role") as! Int16
            
            if !SessionDBRules.isPersonPresentsInCurrentSession(personName: name, personRole: role) {
                SessionDBRules.addPersonInCurrentSession(personName: name, personRole: role, personItn: person.value(forKey: "itn") as! String)
            }
        }
        
        self.navigationItem.leftBarButtonItem?.title = self.getSessionStateStr()
        self.openSessionImageView.isUserInteractionEnabled = false
        self.closeSessionImageView.isUserInteractionEnabled = true
    }
    
    @IBAction func closeSessionGestureAction(_ sender: UITapGestureRecognizer) {
        Utilities.decorateViewTap(viewToDecorate: self.closeSessionView)
        self.closeSessionView.alpha = 0.8
        self.openSessionView.alpha = 1.0
        
        if SessionDBRules.isCurrentSessionOpened()! {
            self.dismissSessionView(UIButton())
            self.hidePurchaseView()
            self.actionsInSession(sessionState: false)
            SessionDBRules.closeCurrentSession()
        }
        
        self.navigationItem.leftBarButtonItem?.title = self.getSessionStateStr()
        self.openSessionImageView.isUserInteractionEnabled = true
        self.closeSessionImageView.isUserInteractionEnabled = false
    }
    
    @objc func showPersonView() {
        self.personView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
        self.personView.alpha = 0.0
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.personView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
        })
        
        Utilities.addAlertOverlayView()
        self.parentView?.addSubview(self.personView)
        
        self.currentPersonNameLabel.text = PersonalDBRules.getPersonNameByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)
        self.currentPersonRoleLabel.text = self.getRolePersmissions()
        
        if SessionDBRules.isCurrentSessionOpened() ?? false {
            let person = PersonalDBRules.getPersonByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)!
            
            let name = person.value(forKey: "name") as! String
            let role = person.value(forKey: "role") as! Int16
            
            if !SessionDBRules.isPersonPresentsInCurrentSession(personName: name, personRole: role) {
                SessionDBRules.addPersonInCurrentSession(personName: name, personRole: role, personItn: person.value(forKey: "itn") as! String)
            }
        }
        
        Utilities.makeViewFlexibleAppearance(view: self.personView)
        
        self.dismissPersonViewButton.tintColor = Utilities.accentColor
    }
    
    func getRolePersmissions() -> String {
        
        let personRole = PersonalDBRules.getPersonRoleByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)!

        switch Int(personRole) {
            case Utilities.personRole.admin.rawValue:
                do {
                    self.currentPersonRoleLabel.textAlignment = .left
                    return "Вы - администратор. Для вас доступны:\n\n" +
                        "1. Кассовые операции.\n" + "2. Операции ведения складского учета.\n" + "3. Операции с персоналом.\n" + "4. Формирование отчетов и настроек приложения."
                }
            case Utilities.personRole.merchandiser.rawValue:
                do {
                    self.currentPersonRoleLabel.textAlignment = .left
                    return "Вы - товаровед. Для вас доступны:\n\n" +
                        "1. Кассовые операции.\n" + "2. Операции ведения складского учета.\n" + "3. Операции с персональной информацией."
                }
            case Utilities.personRole.cashier.rawValue:
                do {
                    self.currentPersonRoleLabel.textAlignment = .left
                    return "Вы - кассир. Для вас доступны:\n\n" +
                        "1. Кассовые операции.\n" + "2. Операции с персональной информацией."
                }
            default: return ""
        }
    }
    
    func actionsInSession(sessionState state: Bool) {
        if state {
            self.buyProductButton.isHidden = false
            self.navigationItem.rightBarButtonItem = self.purchaseViewBarButtonItem
            self.navigationItem.rightBarButtonItem!.tintColor = Utilities.accentColor
        } else {
            self.buyProductButton.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @IBAction func dismissPersonView(_ sender: Any) {
        Utilities.decorateButtonTap(buttonToDecorate: self.dismissPersonViewButton)
        Utilities.removeAlertOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.personView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isPersonViewPresented = false
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.mainController!.view
        
        self.sessionViewBarButtonItem = UIBarButtonItem(title: self.getSessionStateStr(),  style: .done, target: self, action: #selector(self.showSessionView(_:)))
        self.navigationItem.leftBarButtonItem = self.sessionViewBarButtonItem
        
        self.purchaseViewBarButtonItem = UIBarButtonItem(image: Images.arrowLeft, style: .plain, target: self, action: #selector(self.showOrHidePurchaseView(_:)))
        self.navigationItem.rightBarButtonItem = self.purchaseViewBarButtonItem
        
        self.purchaseContainerView.frame.origin.x = self.view.frame.width
        self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
        
        self.customizeButton(button: self.barCodeButton, buttonColor: Utilities.barCodeButtonColor)
        self.customizeButton(button: self.buyProductButton, buttonColor: Utilities.buyProductButtonColor)
        self.customizeButton(button: self.buyProductsButton, buttonColor: Utilities.self.buyProductsButtonColor)
        self.customizeButton(button: self.deleteProductsButton, buttonColor: Utilities.deleteProductsButtonColor)
        self.customizeSearchBar()
        
        self.productTypesCollectionView.dataSource = self
        self.productTypesCollectionView.delegate = self
        
        self.productsTableView.dataSource = self
        self.productsTableView.delegate = self
        self.productsTableView.estimatedRowHeight = 140
        
        self.purchaseTableView.dataSource = self
        self.purchaseTableView.delegate = self
        self.purchaseTableView.estimatedRowHeight = 138
        
        Utilities.customizePopoverView(customizedView: self.personView!)
        self.showPersonView()
        self.isPersonViewPresented = true
        
        self.productsTableView.tableFooterView = UIView()
        self.purchaseTableView.tableFooterView = UIView()
        
        if SessionDBRules.currentSession != nil {
            if let state = SessionDBRules.isCurrentSessionOpened() {
                if state {
                    self.openSessionView.alpha = 0.8
                } else {
                    self.closeSessionView.alpha = 0.8
                }
                self.actionsInSession(sessionState: state)
            }
        } else {
            self.closeSessionView.alpha = 0.8
            self.actionsInSession(sessionState: false)
        }
        
        lib.addDelegate(self)
        lib.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Utilities.customizePopoverView(customizedView: self.sessionView)
    //    Utilities.customizePopoverView(customizedView: self.openSessionView)
    //    Utilities.customizePopoverView(customizedView: self.closeSessionView)
        Utilities.customizePopoverView(customizedView: self.purchaseContainerView)
        Utilities.customizePopoverView(customizedView: self.productTypesCollectionView)
        
        if self.isPurchaseViewPresented {
            self.purchaseContainerView.frame.origin.x = self.view.frame.width -  self.purchaseContainerView.frame.width - self.purchaseViewUpperRightCornerOffest["x"]!
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
            self.purchaseViewBarButtonItem?.image = Images.arrowRight
            
            self.purchaseTableView.reloadData()
        }
        
        self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
        
        if let allCategories = CategoriesDBRules.getAllCategories() {
            if allCategories.count > 0 {
                
                self.productTypesCollectionView.reloadData()
                
                if self.selectedCategoryIndexPath.row >= allCategories.count {
                  selectedCategoryIndexPath = IndexPath(row: 0, section: 0)
                }
                
                self.productTypesCollectionView.selectItem(at: self.selectedCategoryIndexPath, animated: true, scrollPosition: .left)
            } else {
                self.productTypesCollectionView.reloadData()
            }
        }
        self.productsTableView.reloadData()
        
        self.productTypesCollectionView.layer.borderColor = Utilities.accentColor.cgColor
        
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.accentColor
        self.navigationItem.leftBarButtonItem?.tintColor = Utilities.accentColor
        self.openSessionImageView.tintColor = Utilities.openSessionColor
        self.closeSessionImageView.tintColor = Utilities.closeSessionColor
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.accentColor], for: .normal)
    }
    
    func customizeSearchBar() {
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        self.searchController.searchBar.tintColor = Utilities.accentColor
        self.searchController.searchBar.barStyle = .default
        
        if let textfield = self.searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.placeholder = "Найти товары для выбранной категории"
            textfield.tintColor = Utilities.accentColor
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
            }
        }
    }
    
    func customizeButton(button: UIButton, buttonColor: UIColor) {
        button.tintColor = buttonColor
        button.layer.borderColor = buttonColor.cgColor
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 40
    }
    
    func searchBarIsEmpty() -> Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if !self.searchBarIsEmpty() {
            if let selectedCategoryName = self.getSelectedCategoryName() {
                let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: selectedCategoryName)
                ProductsDBRules.filteredProducts = ProductsDBRules.filterProductsByName(productName: self.searchController.searchBar.text!.lowercased(), productCategory: selectedCategory!)
            }
        } else {
            self.productsTableView.reloadData()
            return
        }

        self.productsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.productsTableView {
            self.selectedProductRow = indexPath.row
            self.productsTableView.cellForRow(at: indexPath)?.layer.cornerRadius = 4
        } else {

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.productsTableView {
            if !self.searchBarIsEmpty() {
                return ProductsDBRules.filteredProducts?.count ?? 0
            } else {
                if let selectedCategoryName = self.getSelectedCategoryName() {
                    let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: selectedCategoryName)
                    let products = ProductsDBRules.getAllProductsForCategory(productCategory: selectedCategory!)
                    return products?.count ?? 0
                } else {
                    return 0
                }
            }
        } else {
            return PurchaseDBRules.getAllProductsInPurchase()?.count ?? 0
        }
    }
    
    func getSelectedCategoryName() -> String? {
        let index = self.selectedCategoryIndexPath.row
        let allCategories = CategoriesDBRules.getAllCategories()
        if allCategories!.count != 0 {
            return CategoriesDBRules.getAllCategories()![index].value(forKeyPath: "name") as? String
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.productsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCellId", for: indexPath) as! ProductsTableViewCell

            if let name = self.getSelectedCategoryName() {
                cell.initCell(categoryName: name, indexPath: indexPath, isFiltered: !self.searchBarIsEmpty())
            }
            Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCellId", for: indexPath) as! PurchaseTableViewCell
            
            let productCode = PurchaseDBRules.getAllProductsInPurchase()![indexPath.row].value(forKeyPath: "code") as? String

            cell.initCell(productBarcode: productCode!)
            
            if productCode == self.productToPurchaseBarcode {
                self.decorateCellSelectionWhileSelect(cellToDecorate: cell)
            }
            Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {        
        if tableView == self.purchaseTableView {
            let deleteAction = UIContextualAction(style: .normal, title:  "Удалить", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
                
                let deleteHandler: ((UIAlertAction) -> Void)? = { _ in

                    if let productCode = PurchaseDBRules.getAllProductsInPurchase()![indexPath.row].value(forKeyPath: "code") as? String {
                        
                        let productCountInPurchase = PurchaseDBRules.getProductCountInPurchase(productBarcode: productCode)
                        ProductsDBRules.changeProductCount(productBarcode: productCode, productCount: ProductsDBRules.getProductCountByBarcode(productBarcode: productCode)! + productCountInPurchase!)
                    
                        PurchaseDBRules.deleteProductInPurchaseByBarcode(productBarcode: productCode)
                        
                        self.purchaseTableView.beginUpdates()
                        self.purchaseTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                        self.purchaseTableView.endUpdates()
                        
                        self.productsTableView.reloadData()
                        
                        self.calulateAndPrintPurchaseSumm()
                    }
                }
                
                Utilities.showTwoButtonsAlert(controllerInPresented: self, alertTitle: "УДАЛЕНИЕ ТОВАРА", alertMessage: "Удалить этот товар?", okButtonHandler: deleteHandler,  cancelButtonHandler: nil)
                
                success(true)
            })
            deleteAction.backgroundColor = Utilities.deleteActionBackgroundColor
            deleteAction.image = Images.delete
            
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    func findCellIndexToHighlight(productCode: String) -> Int? {
       return PurchaseDBRules.getProductIndexByBarcode(productBarcode: productCode)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
    
    @IBAction func addProductInPurchase(_ sender: Any) {
        
        let selectedCategoryName = self.getSelectedCategoryName()
        if selectedCategoryName == nil {
            return
        }
        let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: selectedCategoryName!)
        
        if !self.isPurchaseViewPresented {
            self.showPurchaseView()
        }
        
        // Покупка товаров из отфильтрованного списка
        if !self.searchBarIsEmpty() && !self.getFromScaner {
            if let index = self.selectedProductRow {
                
                self.productToPurchaseBarcode = ProductsDBRules.filteredProducts?[index].value(forKeyPath: "code") as? String
                
                if PurchaseDBRules.isProductCanBeAddedToPurchase(controller: self, productBarcode:  self.productToPurchaseBarcode!) {
                    if !PurchaseDBRules.isTheSameProductPresentsInPurchase(productBarcode: self.productToPurchaseBarcode!) {
                        PurchaseDBRules.addNewProductInPurchase(productName: ProductsDBRules.getProductNameByBarcode(code: self.productToPurchaseBarcode!)!, productBarcode: self.productToPurchaseBarcode!)
                        self.updateTablesAfterAddProductInPurchase()
                    } else {
                        PurchaseDBRules.addProductInPurchase(productBarcode: self.productToPurchaseBarcode!)
                        self.updateTablesAfterAddProductInPurchase()
                    }
                    DispatchQueue.main.async {
                        self.purchaseTableView.reloadData()
                    }
                }
            } else {
                Utilities.showErrorAlertView(alertTitle: "ОШИБКА", alertMessage: "Товар не выбран!")
                }
            self.calulateAndPrintPurchaseSumm()
            self.getFromScaner = false
            return
       }
        
       // Покупка товаров из нефильтрованного списка
       if self.searchBarIsEmpty() && !self.getFromScaner {
            if let index = self.selectedProductRow {
                self.productToPurchaseBarcode = ProductsDBRules.getAllProductsForCategory(productCategory: selectedCategory!)?[index].value(forKeyPath: "code") as? String
                    if PurchaseDBRules.isProductCanBeAddedToPurchase(controller: self, productBarcode:  self.productToPurchaseBarcode!) {
                        if !PurchaseDBRules.isTheSameProductPresentsInPurchase(productBarcode: self.productToPurchaseBarcode!) {
                            PurchaseDBRules.addNewProductInPurchase(productName: ProductsDBRules.getProductNameByBarcode(code: self.productToPurchaseBarcode!)!, productBarcode: self.productToPurchaseBarcode!)
                            self.updateTablesAfterAddProductInPurchase()
                        } else {
                            PurchaseDBRules.addProductInPurchase(productBarcode: self.productToPurchaseBarcode!)
                            self.updateTablesAfterAddProductInPurchase()
                        }
                        DispatchQueue.main.async {
                            self.purchaseTableView.reloadData()
                        }
                    }
        } else {
            Utilities.showErrorAlertView(alertTitle: "ОШИБКА", alertMessage: "Товар не выбран!")
        }
        self.calulateAndPrintPurchaseSumm()
        self.getFromScaner = false
        return
        }
        
        // Покупка продукта сканером штрих кода
        if self.getFromScaner {
            if ProductsDBRules.isBarcodePresents(productBarcode: self.productToPurchaseBarcode!) {
                if PurchaseDBRules.isProductCanBeAddedToPurchase(controller: self, productBarcode:  self.productToPurchaseBarcode!) {
                    if !PurchaseDBRules.isTheSameProductPresentsInPurchase(productBarcode: self.productToPurchaseBarcode!) {
                        PurchaseDBRules.addNewProductInPurchase(productName: ProductsDBRules.getProductNameByBarcode(code: self.productToPurchaseBarcode!)!, productBarcode: self.productToPurchaseBarcode!)
                        self.updateTablesAfterAddProductInPurchase()
                    } else {
                        PurchaseDBRules.addProductInPurchase(productBarcode: self.productToPurchaseBarcode!)
                        self.updateTablesAfterAddProductInPurchase()
                    }
                    DispatchQueue.main.async {
                        self.purchaseTableView.reloadData()
                    }
                }
            } else {
                Utilities.showErrorAlertView(alertTitle: "ОШИБКА", alertMessage: "Нет товара с таким штрих кодом!")
            }
        }
        self.calulateAndPrintPurchaseSumm()
        self.getFromScaner = false
    }
    
    func updateTablesAfterAddProductInPurchase() {
        ProductsDBRules.decProductCount(productBarcode: self.productToPurchaseBarcode!)
        
        let indexPathToReload = IndexPath(row: self.selectedProductRow!, section: 0)
        
        self.productsTableView.reloadRows(at: [indexPathToReload], with: .none)
        self.productsTableView.selectRow(at: indexPathToReload, animated: false, scrollPosition: .none)
    }
    
    func decorateCellSelectionWhileSelect(cellToDecorate cell: UITableViewCell) {
        cell.backgroundColor = Utilities.accentColor.withAlphaComponent(0.08)
        cell.layer.cornerRadius = 4
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.backgroundColor = UIColor.white
        })
    }
    
    @IBAction func deletePurchase(_ sender: Any) {
        for productInPurchase in PurchaseDBRules.getAllProductsInPurchase()! {
            let productCode = productInPurchase.value(forKey: "code") as! String
            let productCountInPurchase = PurchaseDBRules.getProductCountInPurchase(productBarcode: productCode)
            ProductsDBRules.changeProductCount(productBarcode: productCode, productCount: ProductsDBRules.getProductCountByBarcode(productBarcode: productCode)! + productCountInPurchase!)
        }
        
        self.productsTableView.reloadData()
        
        PurchaseDBRules.deleteAllProductsInPurchase()
        
        self.purchaseTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
        
        self.calulateAndPrintPurchaseSumm()
        
        self.selectedProductRow = nil
    }
    
    func calulateAndPrintPurchaseSumm() {
        self.purchaseSummLabel.text = String(format: "ТОВАРОВ НА СУММУ: %0.2f руб.", PurchaseDBRules.getPurchaseTotalPrice())
    }
    
    @objc func showSessionView(_ sender: UIBarButtonItem) -> Void {
        if self.isSessionViewPresented == false {
            self.sessionView.isHidden = false
            self.showSessionView()
        }
    }
    
    @objc func showOrHidePurchaseView(_ sender: UIBarButtonItem) -> Void {
        if self.isPurchaseViewPresented == false {
            self.purchaseContainerView.isHidden = false
            self.showPurchaseView()
        } else {
            self.hidePurchaseView()
        }
    }
    
    func getSessionStateStr() -> String {
        var sessionState = "СМЕНА ЗАКРЫТА"
        
        if let state = SessionDBRules.isCurrentSessionOpened() {
            if state {
                sessionState = "СМЕНА ОТКРЫТА"
            }
        }
        return sessionState
    }
    
    func showSessionView() {
        self.sessionView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
        self.sessionView.alpha = 0.0
        
        self.dismissSessionViewButton.tintColor = Utilities.accentColor
        self.sessionStateLabel.text = self.getSessionStateStr()
        self.navigationItem.leftBarButtonItem?.title = self.getSessionStateStr()
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.sessionView.alpha = CGFloat(Utilities.alpha)
        }), completion: { (completed: Bool) in
            self.isSessionViewPresented = true
        })
        
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.sessionView)
        
        Utilities.makeViewFlexibleAppearance(view: self.sessionView)
    }
    
    func showPurchaseView() {
        if !UIDevice.current.orientation.isLandscape && !UIDevice.current.orientation.isFlat {
            self.purchaseContainerView.frame.size.height = 728
            self.purchaseTableView.frame.size.height = 646
            self.buyProductsButton.center.y = 441
            self.deleteProductsButton.center.y = 573
            self.purchaseSummLabel.center.y = 714
        } else {
            self.purchaseContainerView.frame.size.height = 472
            self.purchaseTableView.frame.size.height = 390
            self.buyProductsButton.center.y = 185
            self.deleteProductsButton.center.y = 307
            self.purchaseSummLabel.center.y = 458
        }
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in

            self.purchaseContainerView.frame.origin.x = self.view.frame.width -  self.purchaseContainerView.frame.width - self.purchaseViewUpperRightCornerOffest["x"]!
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!

            self.isPurchaseViewPresented = true
        }, completion: { (completed: Bool) -> Void in
            self.purchaseViewBarButtonItem?.image = Images.arrowRight
            self.purchaseContainerView.isHidden = false
        })
    }
    
    func hidePurchaseView() {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.purchaseContainerView.frame.origin.x = self.view.frame.width
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
            
            self.isPurchaseViewPresented = false
        }, completion: { (completed: Bool) -> Void in
            self.purchaseViewBarButtonItem?.image = Images.arrowLeft
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categoriesCount = CategoriesDBRules.getAllCategories()?.count ?? 0
        if categoriesCount == 0 {
            self.productTypesCollectionView.isHidden = true
            return 0
        } else {
            self.productTypesCollectionView.isHidden = false
            return categoriesCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productTypeId", for: indexPath) as! ProductTypeCollectionViewCell
        
        cell.productTypeNameLabel.text = CategoriesDBRules.getAllCategories()![indexPath.row].value(forKeyPath: "name") as? String
        
        self.decorateCollectionViewCell(cellToDecorate: cell)
        Utilities.setCollectionViewCellSelectedColor(cellToSetSelectedColor: cell)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedCategoryIndexPath = indexPath
        if !self.searchBarIsEmpty() {
            if let selectedCategoryName = self.getSelectedCategoryName() {
                let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: selectedCategoryName)
                ProductsDBRules.filteredProducts = ProductsDBRules.filterProductsByName(productName: self.searchController.searchBar.text!.lowercased(), productCategory: selectedCategory!)
            }
        }
        self.selectedProductRow = nil
        self.productsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func decorateCollectionViewCell(cellToDecorate cell: UICollectionViewCell) {
        cell.layer.borderWidth = 0.4
        cell.layer.cornerRadius = 4
        cell.layer.borderColor = Utilities.accentColor.withAlphaComponent(0.4).cgColor
    }
        
    @IBAction func getProductBarCode(_ sender: Any) {
        do {
            var scanMode = SCAN_MODES.MODE_SINGLE_SCAN
            try lib.barcodeGetScanMode(&scanMode)
            
            if scanMode == SCAN_MODES.MODE_MOTION_DETECT {
                self.isScanActive = !self.isScanActive
                if self.isScanActive {
                    try lib.barcodeStartScan()
                } else {
                    try lib.barcodeStopScan()
                }
            } else {
                try lib.barcodeStartScan()
            }
        } catch let error as NSError {
            Utilities.showErrorAlertView(alertTitle: "ОШИБКА", alertMessage: error.localizedDescription)
        }
    }
    
    func barcodeData(_ barcode: String!, type: Int32) {
        self.getFromScaner = true
        self.productToPurchaseBarcode = barcode
        self.addProductInPurchase(self.buyProductsButton)
    }
    
    func magneticCardData(_ track1: String!, track2: String!, track3: String!) {
        let card = lib.msExtractFinancialCard(track1, track2: track2)
        var status = ""
        if card != nil {
            if card!.cardholderName != nil && !(card!.cardholderName.isEmpty) {
                status += "Владелец: \(card!.cardholderName!)\n"
            }
            if card!.accountNumber != nil && !(card!.accountNumber.isEmpty) {
                status += "Номер: \(card!.accountNumber!)"
            }
        }
        Utilities.showOkAlertView(alertTitle: "КАРТА", alertMessage: status)
    }
    
    
    func addSaleForPerson() {
        let person = PersonalDBRules.getPersonByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)
        
        for product in PurchaseDBRules.getAllProductsInPurchase() ?? [] {
            PersonSalesDBRules.addProductInPersonSale(personName: person?.value(forKey: "name") as! String, personRole: person?.value(forKey: "role") as! Int16, productName: product.value(forKey: "name") as! String, productCount: product.value(forKey: "count") as! Float, productBarcode: product.value(forKey: "code") as! String)
        }
    }
    
    func demoPrintCheck() -> Bool {
        let hostName = SettingsDBRules.getTCPDeviceName()
        if hostName == nil || (hostName?.isEmpty)! {
            Utilities.showErrorAlertView(alertTitle: "ПОКУПКА", alertMessage: "Не выбрано устройство контрольно-кассовой техники!")
            return false
        }
        
        let openShift = OpenFiscalReceiptCommand(operatorNumber: "1", operatorPassword: "1", pointOfSaleNumber: "1", operationType: "4")
        openShift.writeCommand()
        
        let closeShift = CloseFiscalReceiptCommand()
        closeShift.writeCommand()
        
        let ofr = OpenFiscalReceiptCommand(operatorNumber: "1", operatorPassword: "1", pointOfSaleNumber: "1", operationType: "0")
        ofr.writeCommand()
        
        for product in PurchaseDBRules.getAllProductsInPurchase()! {
            let name = product.value(forKey: "name") as! String
            let count = product.value(forKey: "count") as! Float
            let code = product.value(forKey: "code") as! String
            let price = ProductsDBRules.getProductPriceByBarcode(productBarcode: code)
            
            let ros = RegistrationOfSaleCommand(productName: name, taxType: "1", productPrice: price!.description, productQuantity: count.description, department: "0")
            ros.writeCommand()
        }
        
        let paid = PaymentCommand(paidMode: "0", paidAmount: String(format: "%0.2f", PurchaseDBRules.getPurchaseTotalPrice()))
        paid.writeCommand()
        
        let cfr = CloseFiscalReceiptCommand()
        cfr.writeCommand()

        return true
    }
    
    @IBAction func makePurchase(_ sender: Any) {
        if PurchaseDBRules.getAllProductsInPurchase()?.count ?? 0 > 0 {
            
            if true /*self.demoPrintCheck()*/ {
                self.addSaleForPerson()
                
                Utilities.showOkAlertView(alertTitle: "ПОКУПКА", alertMessage: "Покупка выполнена!")
                PurchaseDBRules.deleteAllProductsInPurchase()
                
                self.calulateAndPrintPurchaseSumm()
                
                self.productsTableView.reloadData()
                self.purchaseTableView.reloadData()
                
                self.selectedProductRow = nil
            }
            
        } else {
            Utilities.showErrorAlertView(alertTitle: "ПОКУПКА", alertMessage: "Нет товаров для покупки!")
        }
    }
        
    func connectionState(_ state: Int32) {
        do {
            if state == CONN_STATES.CONNECTED.rawValue {
                do {
                    let connected = try lib.getConnectedDevicesInfo()
                    var info: String = ""
                    for device in connected
                    {
                        info += "\(device.name!) \(device.model!)\nFW Rev: \(device.firmwareRevision!) HW Rev: \(device.hardwareRevision!)\nSerial: \(device.serialNumber!)\n"
                    }
                //    Utilities.showOkAlertView(alertTitle: "", alertMessage: info)
                //    Utilities.showSimpleAlert(controllerToShowFor: self, messageToShow: info)
                } catch {}
                
                if SessionDBRules.isCurrentSessionOpened() ?? false {
                    self.barCodeButton.isHidden = false
                    self.barCodeButton.layer.borderColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1.0).cgColor
                }
            } else {
                self.barCodeButton.isHidden = true
                self.barCodeButton.layer.borderColor = Utilities.accentColor.cgColor
            }
        }
    }
    
    @IBAction func dismissSessionView(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissView(viewToDismiss: self.sessionView)
        self.isSessionViewPresented = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)

        if self.isPurchaseViewPresented {
            self.hidePurchaseView()
            self.purchaseContainerView.isHidden = false
            
            coordinator.animate(alongsideTransition: { _ in
                self.showPurchaseView()
            })
        } else {
            self.purchaseContainerView.isHidden = true
        }
        
        if self.isSessionViewPresented {
            self.sessionView.removeFromSuperview()
            
            coordinator.animate(alongsideTransition: { _ in
                self.parentView?.addSubview(self.sessionView)
                self.sessionView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
            })
        }
    
        if self.isPersonViewPresented {
            self.personView.removeFromSuperview()
        
            coordinator.animate(alongsideTransition: { _ in
                self.parentView?.addSubview(self.personView)
                self.personView.center = Utilities.getParentViewCenterPoint(parentView: self.parentView)
            })
        }
    }
            
}


