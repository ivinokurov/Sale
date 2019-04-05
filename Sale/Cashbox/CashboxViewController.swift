//
//  MobileCashboxViewController.swift
//  Sale
//


import UIKit

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
    
    var parentView: UIView? = nil
    let searchController = UISearchController(searchResultsController: nil)
    var selectBuildingButton: UIBarButtonItem?
    var isPurchaseViewPresented: Bool = false
    var isPersonViewPresented: Bool = false
    var selectedCategoryIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var getFromScaner: Bool = false
    var selectedProductRow: Int?
    var productToPurchaseBarcode: String?
    var purchaseViewUpperRightCornerOffest: Dictionary<String, CGFloat> = ["x" : 21.0, "y" : 6]
    
    let showPurchaseViewImage = UIImage(named: "ArrowsLeft")
    let hidePurchaseViewImage = UIImage(named: "ArrowsRight")
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    func getPersonViewCenterPoint() -> CGPoint {
        
        let centerX = (self.parentView?.center.x)!
        let centerY = (self.parentView?.center.y)! * 0.5
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    @objc func showPersonView() {

        self.personView.center = self.getPersonViewCenterPoint()
        self.personView.alpha = 0.0
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.personView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.personView.alpha = 0.94
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.personView)
        
        self.currentPersonNameLabel.text = PersonalDBRules.getPersonNameByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)
        self.currentPersonRoleLabel.text = self.getRolePersmissions()
        
        Utilities.makeViewFlexibleAppearance(view: self.personView)
        
        self.dismissPersonViewButton.tintColor = Utilities.accentColor
    }
    
    func getRolePersmissions() -> String {
        
        let personRole = PersonalDBRules.getPersonRoleByLoginAndPassword(personLogin: PersonalDBRules.currentLogin!, personPassword: PersonalDBRules.currentPassword!)!

        switch Int(personRole) {
            case Utilities.personRole.admin.rawValue:
                do {
                    self.currentPersonRoleLabel.textAlignment = .left
                    return "Для вас доступны:\n" +
                        "1. Кассовые операции.\n" + "2. Операции ведения складского учета.\n" + "3. Операции с персоналом.\n" + "4. Формирование отчетов и настроек приложения."
                }
            case Utilities.personRole.merchandiser.rawValue:
                do {
                    self.currentPersonRoleLabel.textAlignment = .left
                    return "Для вас доступны:\n" +
                        "1. Кассовые операции.\n" + "2. Операции ведения складского учета.\n" + "3. Операции с персональной информацией."
                }
            case Utilities.personRole.cashier.rawValue:
                do {
                    self.currentPersonRoleLabel.textAlignment = .left
                    return "Для вас доступны:\n" +
                        "1. Кассовые операции.\n" + "2. Операции с персональной информацией."
                }
            default: return ""
        }
    }
    
    @IBAction func dismissPersonView(_ sender: Any) {
        
        Utilities.decorateButtonTap(buttonToDecorate: self.dismissPersonViewButton)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.personView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isPersonViewPresented = false
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        selectBuildingButton = UIBarButtonItem(image: showPurchaseViewImage, style: .plain, target: self, action: #selector(showOrHidePurchaseView(_:)))
        self.navigationItem.rightBarButtonItem = selectBuildingButton
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.accentColor
        
        self.purchaseContainerView.frame.origin.x = self.view.frame.width
        self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
        
        self.customizeButton(button: self.barCodeButton, buttonColor: Utilities.barCodeButtonColor)
        self.customizeButton(button: self.buyProductButton, buttonColor: Utilities.buyProductButtonColor)
        self.customizeButton(button: self.buyProductsButton, buttonColor: Utilities.self.buyProductsButtonColor)
        self.customizeButton(button: self.deleteProductsButton, buttonColor: Utilities.deleteProductsButtonColor)
        self.customizeSearchBar()
        
        Utilities.customizePopoverView(customizedView: self.purchaseContainerView)
        Utilities.customizePopoverView(customizedView: self.productTypesCollectionView)
        
        self.productTypesCollectionView.dataSource = self
        self.productTypesCollectionView.delegate = self
        
        self.productsTableView.dataSource = self
        self.productsTableView.delegate = self
        
        self.purchaseTableView.dataSource = self
        self.purchaseTableView.delegate = self
        self.purchaseTableView.estimatedRowHeight = 138
        
        self.parentView = Utilities.mainController!.view
        Utilities.customizePopoverView(customizedView: self.personView!)
        self.showPersonView()
        self.isPersonViewPresented = true
        
        self.productsTableView.tableFooterView = UIView()
        self.purchaseTableView.tableFooterView = UIView()
        
    //    if !Utilities.isPersonLogout {
            lib.addDelegate(self)
            lib.connect()
    //    }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if self.isPurchaseViewPresented {
            self.purchaseContainerView.frame.origin.x = self.view.frame.width -  self.purchaseContainerView.frame.width - self.purchaseViewUpperRightCornerOffest["x"]!
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
            self.selectBuildingButton?.image = self.hidePurchaseViewImage
            
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
        button.backgroundColor = buttonColor.withAlphaComponent(0.12)
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
                return ProductsDBRules.filteredProducts!.count
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
            deleteAction.image = UIImage(named: "Delete")
            
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
    }
    
    func calulateAndPrintPurchaseSumm() {
        self.purchaseSummLabel.text = String(format: "ТОВАРОВ НА СУММУ: %0.2f руб.", PurchaseDBRules.getPurchaseTotalPrice())
    }
    
    @objc func showOrHidePurchaseView(_ sender: UIBarButtonItem) -> Void {
        if self.isPurchaseViewPresented == false {
            self.purchaseContainerView.isHidden = false
            self.showPurchaseView()
        } else {
            self.hidePurchaseView()
        }
    }
    
    func showPurchaseView() {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in

            self.purchaseContainerView.frame.origin.x = self.view.frame.width -  self.purchaseContainerView.frame.width - self.purchaseViewUpperRightCornerOffest["x"]!
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
            /*
            if !UIDevice.current.orientation.isLandscape {
                self.purchaseContainerView.frame.size.height = 700
            } else {
                self.purchaseContainerView.frame.size.height = 472
            }
            */
            self.isPurchaseViewPresented = true
        }, completion: { (completed: Bool) -> Void in
            self.selectBuildingButton?.image = self.hidePurchaseViewImage
            self.purchaseContainerView.isHidden = false
        })
    }
    
    func hidePurchaseView() {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.purchaseContainerView.frame.origin.x = self.view.frame.width
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
            
            self.isPurchaseViewPresented = false
        }, completion: { (completed: Bool) -> Void in
            self.selectBuildingButton?.image = self.showPurchaseViewImage
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoriesDBRules.getAllCategories()?.count ?? 0
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
    
    @IBAction func makePurchase(_ sender: Any) {
        
        if PurchaseDBRules.getAllProductsInPurchase()?.count ?? 0 > 0 {
        //    PurchaseDBRules.updatePurchasedProductsCount()
            PurchaseDBRules.deleteAllProductsInPurchase()
            
            let devices = lib.btConnectedDevices
            
            Utilities.showOkAlertView(alertTitle: "ПОКУПКА", alertMessage: "Покупка выполнена!")
            self.calulateAndPrintPurchaseSumm()
            
            self.productsTableView.reloadData()
            self.purchaseTableView.reloadData()
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
                        info += "\(device.name!) \(device.model!) connected\nFW Rev: \(device.firmwareRevision!) HW Rev: \(device.hardwareRevision!)\nSerial: \(device.serialNumber!)\n"
                    }
                    Utilities.showSimpleAlert(controllerToShowFor: self, messageToShow: info)
                } catch {}
                
                self.barCodeButton.isHidden = false
                self.barCodeButton.layer.borderColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1.0).cgColor
            } else {
                self.barCodeButton.isHidden = true
                self.barCodeButton.layer.borderColor = Utilities.accentColor.cgColor
            }
        }
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
    
        if self.isPersonViewPresented {
            self.personView.removeFromSuperview()
        
            coordinator.animate(alongsideTransition: { _ in
                self.parentView?.addSubview(self.personView)
                self.personView.center = self.getPersonViewCenterPoint()
            })
        }
    }
            
}


