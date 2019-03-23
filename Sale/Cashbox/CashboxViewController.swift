//
//  MobileCashboxViewController.swift
//  Sale
//


import UIKit

class CashboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource,  DTDeviceDelegate {

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
    
    let searchController = UISearchController(searchResultsController: nil)
    var selectBuildingButton: UIBarButtonItem?
    var isPurchaseViewShowed: Bool = false
    var selectedCategoryIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var getFromScaner: Bool = false
    var selectedProductRow: Int?
    var productToPurchaseBarcode: String?
    var purchaseViewUpperRightCornerOffest: Dictionary<String, CGFloat> = ["x" : 21.0, "y" : 8.8]
    
    let showPurchaseViewImage = UIImage(named: "ArrowsLeft")
    let hidePurchaseViewImage = UIImage(named: "ArrowsRight")
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectBuildingButton = UIBarButtonItem(image: showPurchaseViewImage, style: .plain, target: self, action: #selector(showOrHidePurchaseView(_:)))
        self.navigationItem.rightBarButtonItem = selectBuildingButton
        self.navigationItem.rightBarButtonItem?.tintColor = Utilities.barButtonItemColor
        
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
        
        lib.addDelegate(self)
        lib.connect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isPurchaseViewShowed {

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
    //    self.productsTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .automatic)
    }
    
    func customizeSearchBar() {
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        self.searchController.searchBar.tintColor = Utilities.barButtonItemColor
        self.searchController.searchBar.barStyle = .default
        
        if let textfield = self.searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.placeholder = "Найти продукты по названию"
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
                    
                        PurchaseDBRules.deleteProductInPurchaseByBarcode(productBarcode: productCode)
                        
                        self.purchaseTableView.beginUpdates()
                        self.purchaseTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                        self.purchaseTableView.endUpdates()
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
        return 138.0
    }
    
    @IBAction func addProductInPurchase(_ sender: Any) {
        if let index = self.selectedProductRow {
            let selectedCategoryName = self.getSelectedCategoryName()
            let selectedCategory = CategoriesDBRules.getCategiryByName(categoryName: selectedCategoryName!)
            if !self.searchBarIsEmpty() && !self.getFromScaner {
                
               self.productToPurchaseBarcode = ProductsDBRules.filteredProducts?[index].value(forKeyPath: "code") as? String
                if !PurchaseDBRules.isTheSameProductPresentsInPurchase(productBarcode: self.productToPurchaseBarcode!) {
                    PurchaseDBRules.addNewProductInPurchase(productName: ProductsDBRules.getProductNameByBarcode(code: self.productToPurchaseBarcode!)!, productBarcode: self.productToPurchaseBarcode!)
                } else {
                    PurchaseDBRules.addProductInPurchase(productBarcode: self.productToPurchaseBarcode!)
                }
                DispatchQueue.main.async {
                    self.purchaseTableView.reloadData()
                }
            } else {
                self.productToPurchaseBarcode = ProductsDBRules.getAllProductsForCategory(productCategory: selectedCategory!)?[index].value(forKeyPath: "code") as? String
                if PurchaseDBRules.isProductCanBeAddedToPurchase(controller: self, productBarcode:  self.productToPurchaseBarcode!) {
                    if !PurchaseDBRules.isTheSameProductPresentsInPurchase(productBarcode: self.productToPurchaseBarcode!) {
                        PurchaseDBRules.addNewProductInPurchase(productName: ProductsDBRules.getProductNameByBarcode(code: self.productToPurchaseBarcode!)!, productBarcode: self.productToPurchaseBarcode!)
                    } else {
                        PurchaseDBRules.addProductInPurchase(productBarcode: self.productToPurchaseBarcode!)
                    }
                    DispatchQueue.main.async {
                        self.purchaseTableView.reloadData()
                    }
                }
            }
        } else {
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Ошибка!", alertMessage: "Продукт не выбран!", alertButtonHandler: nil)
        }
        
        self.calulateAndPrintPurchaseSumm()
        
        self.getFromScaner = false
    }
    
    func decorateCellSelectionWhileSelect(cellToDecorate cell: UITableViewCell) {
        cell.backgroundColor = Utilities.accentColor.withAlphaComponent(0.02)
        cell.layer.cornerRadius = 4
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.backgroundColor = UIColor.white
        })
    }
    
    @IBAction func deletePurchase(_ sender: Any) {
        PurchaseDBRules.deleteAllProductsInPurchase()
        
        self.purchaseTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
        self.calulateAndPrintPurchaseSumm()
    }
    
    func calulateAndPrintPurchaseSumm() {
        self.purchaseSummLabel.text = String(format: "ПОКУПКА НА СУММУ: %0.2f руб", PurchaseDBRules.getPurchaseTotalPrice())
    }
    
    @objc func showOrHidePurchaseView(_ sender: UIBarButtonItem) -> Void {
        if self.isPurchaseViewShowed == false {
            self.showPurchaseView()
        } else {
            self.hidePurchaseView()
        }
    }
    
    func showPurchaseView() {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in

            self.purchaseContainerView.frame.origin.x = self.view.frame.width -  self.purchaseContainerView.frame.width - self.purchaseViewUpperRightCornerOffest["x"]!
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
            
            self.isPurchaseViewShowed = true
        }, completion: { (completed: Bool) -> Void in
            self.selectBuildingButton?.image = self.hidePurchaseViewImage
            self.purchaseContainerView.isHidden = false
        })
    }
    
    func hidePurchaseView() {
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.purchaseContainerView.frame.origin.x = self.view.frame.width
            self.purchaseContainerView.frame.origin.y = self.purchaseViewUpperRightCornerOffest["y"]!
            
            self.isPurchaseViewShowed = false
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
    
    func decorateCollectionViewCellWhileSelect(cellToDecorate cell: UICollectionViewCell) {
    //    cell.backgroundColor = Utilities.accentColor.withAlphaComponent(0.2)
    //    UIView.animate(withDuration: 0.4, animations: { () -> Void in
    //        cell.backgroundColor = UIColor.white
    //    })
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
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Ошибка сканирования!", alertMessage: error.localizedDescription, alertButtonHandler: nil)
        }
    }
    
    func barcodeData(_ barcode: String!, type: Int32) {
        if !PurchaseDBRules.isTheSameProductPresentsInPurchase(productBarcode: barcode) {
            PurchaseDBRules.addProductInPurchase(productBarcode: barcode)
        }
        self.getFromScaner = true
        self.addProductInPurchase(self.buyProductsButton)
    
        self.productsTableView.selectRow(at: IndexPath(row: self.selectedProductRow!, section: 0), animated: true, scrollPosition: .none)
    }
    
    
    @IBAction func makePurchase(_ sender: Any) {
        PurchaseDBRules.updatePurchasedProductsCount()
        PurchaseDBRules.deleteAllProductsInPurchase()
        
        Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "ПОКУПКА", alertMessage: "Покупка выполнена!", alertButtonHandler: nil)
        self.productsTableView.reloadData()
        self.purchaseTableView.reloadData()
    }
    
    func connectionState(_ state: Int32) {
        do {
            if state == CONN_STATES.CONNECTED.rawValue {
                self.barCodeButton.isEnabled = true
                self.barCodeButton.layer.borderColor = UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1.0).cgColor
            } else {
                self.barCodeButton.isEnabled = false
                self.barCodeButton.layer.borderColor = Utilities.accentColor.cgColor
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size , with: coordinator)

        if self.isPurchaseViewShowed {
            self.hidePurchaseView()
            self.purchaseContainerView.isHidden = false
            
            coordinator.animate(alongsideTransition: { _ in
                self.showPurchaseView()
            })
        } else {
            self.purchaseContainerView.isHidden = true
        }
    }

}
