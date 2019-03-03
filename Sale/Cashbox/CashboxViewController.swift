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
    var navigationBarHeight: CGFloat?
    
    var filteredProductImages: [String] = []
    var filteredProductNames: [String] = []
    var filteredProductPrices: [Double] = []
    var filteredProductBarcodes: [String] = []
    
    var purchasedProductImages: [String] = []
    var purchasedProductNames: [String] = []
    var purchasedProductPrices: [Double] = []
    
    let showPurchaseViewImage = UIImage(named: "ArrowsLeft")
    let hidePurchaseViewImage = UIImage(named: "ArrowsRight")
    
    var selectedProductRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectBuildingButton = UIBarButtonItem(image: showPurchaseViewImage, style: .plain, target: self, action: #selector(showOrHidePurchaseView(_:)))
        self.navigationItem.rightBarButtonItem = selectBuildingButton
        self.navigationItem.rightBarButtonItem?.tintColor = .red
        
        self.navigationBarHeight = self.searchController.searchBar.frame.height
        
        self.purchaseContainerView.frame.origin.x = self.view.frame.width
        self.purchaseContainerView.frame.origin.y = self.navigationBarHeight!
        
        self.customizeButton(button: self.barCodeButton, buttonColor: UIColor.blue)
        self.customizeButton(button: self.buyProductButton, buttonColor: UIColor(red: 0/255, green: 143/255, blue: 0/255, alpha: 1.0))
        self.customizeButton(button: self.buyProductsButton, buttonColor: UIColor(red: 0/255, green: 84/255, blue: 147/255, alpha: 1.0))
        self.customizeButton(button: self.deleteProductsButton, buttonColor: UIColor.red)
        self.customizeSearchBar()
        self.customizePurchaseView()
        
        self.productsTableView.dataSource = self
        self.productsTableView.delegate = self
        
        self.purchaseTableView.dataSource = self
        self.purchaseTableView.delegate = self
        
        self.productTypesCollectionView.dataSource = self
        self.productTypesCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func customizeSearchBar() {
        self.navigationItem.titleView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        self.searchController.searchBar.tintColor = UIColor.red
        if let textfield = self.searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.placeholder = "Найти продукты по названию"
            textfield.tintColor = UIColor.red
        }
    }
    
    func customizePurchaseView() {
        self.purchaseContainerView.layer.borderColor = UIColor.red.cgColor
        self.purchaseContainerView.layer.borderWidth = 0.4
        self.purchaseContainerView.layer.cornerRadius = 4
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
            self.filteredProductNames = Utilities.productNames.filter({(name: String) -> Bool in
                name.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil
            })
        } else {
            return
        }
        self.filteredProductImages.removeAll()
        self.filteredProductPrices.removeAll()
        self.filteredProductBarcodes.removeAll()
        for name in self.filteredProductNames {
            let index = Utilities.productNames.firstIndex(of: name)
            
            self.filteredProductImages.append(Utilities.productImages[index!])
            self.filteredProductPrices.append(Utilities.productPrices[index!])
            self.filteredProductBarcodes.append(Utilities.barcodes[index!])
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
    
    /*
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.productsTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.productsTableView {
            if !self.searchBarIsEmpty() {
                return self.filteredProductNames.count
            } else {
                return Utilities.productCount
            }
        } else {
            return self.purchasedProductNames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.productsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCellId", for: indexPath) as! ProductsTableViewCell
            
            if !self.searchBarIsEmpty() {
                cell.productImageView.image = UIImage(named: self.filteredProductImages[indexPath.row])
                cell.productNameLabel.text = self.filteredProductNames[indexPath.row]
                cell.productPriceLabel.text = String(self.filteredProductPrices[indexPath.row]) + " руб/кг"
                cell.productBarcodeLabel.text = "Код: " + self.filteredProductBarcodes[indexPath.row]
            } else {
                cell.productImageView.image = UIImage(named: Utilities.productImages[indexPath.row])
                cell.productNameLabel.text = Utilities.productNames[indexPath.row]
                cell.productPriceLabel.text = String(Utilities.productPrices[indexPath.row]) + " руб/кг"
                cell.productBarcodeLabel.text = "Код: " + Utilities.barcodes[indexPath.row]
            }
            
            self.setCellSelectedColor(cellToSetSelectedColor: cell)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCellId", for: indexPath) as! PurchaseTableViewCell
            
            cell.purchaseImageView.image = UIImage(named: self.purchasedProductImages[indexPath.row])
            cell.purchaseNameLabel.text = self.purchasedProductNames[indexPath.row]

            let productCount = Utilities.productsCount[self.purchasedProductNames[indexPath.row]]!
            let productPrice = self.purchasedProductPrices[indexPath.row]
            
            cell.purchasePriceLabel.text = String(format: "%d кг × %.2f руб/кг = %.2f руб", productCount, productPrice, Double(productCount) * productPrice)
            
            self.setCellSelectedColor(cellToSetSelectedColor: cell)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.productsTableView {
            return 100.0
        } else {
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == self.productsTableView {
            let deleteAction = UIContextualAction(style: .normal, title:  "УДАЛИТЬ\nПРОДУКТ", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
                
                Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Удаление продукта", alertMessage: "В демо версии не реализовано", alertButtonHandler: nil)
                
                success(true)
            })
            deleteAction.backgroundColor = UIColor.red.withAlphaComponent(0.4)
            
            let editAction = UIContextualAction(style: .normal, title:  "ИЗМЕНИТЬ\nПРОДУКТ", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
                
                Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Изменение продукта", alertMessage: "В демо версии не реализовано", alertButtonHandler: nil)

                success(true)
            })
            editAction.backgroundColor = UIColor.green.withAlphaComponent(0.4)
            return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        } else {
            let deleteAction = UIContextualAction(style: .normal, title:  "УДАЛИТЬ\nПРОДУКТ", handler: { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
                
                let index = indexPath.row
                
                Utilities.productsCount[self.purchasedProductNames[index]] = 0
                
                self.purchasedProductImages.remove(at: index)
                self.purchasedProductNames.remove(at: index)
                self.purchasedProductPrices.remove(at: index)
                
                self.purchaseTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
                
                self.calulateAndPrintPurchaseSumm()
                
                success(true)
            })
            deleteAction.backgroundColor = UIColor.red.withAlphaComponent(0.4)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
    
    func setCellSelectedColor(cellToSetSelectedColor cell: UITableViewCell) {
        let bgkColorView = UIView()
        bgkColorView.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        cell.selectedBackgroundView = bgkColorView
    }
    
    @IBAction func purchaseProduct(_ sender: Any) {
        if let index = self.selectedProductRow {
            if !self.searchBarIsEmpty() {
                
                Utilities.productsCount[self.filteredProductNames[index]] = Utilities.productsCount[self.filteredProductNames[index]]! + 1
                
                if !self.purchasedProductNames.contains(self.filteredProductNames[index]) {
                    self.purchasedProductImages.append(self.filteredProductImages[index])
                    self.purchasedProductNames.append(self.filteredProductNames[index])
                    self.purchasedProductPrices.append(self.filteredProductPrices[index])
                    
                    self.purchaseTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
                } else {
                    let purchasedIndex = self.purchasedProductNames.firstIndex(of: self.filteredProductNames[index])
                    self.purchaseTableView.reloadRows(at: [IndexPath(row: purchasedIndex!, section: 0)], with: .fade)
                }
                
            } else {
                
                Utilities.productsCount[Utilities.productNames[index]] = Utilities.productsCount[Utilities.productNames[index]]! + 1
                
                if !self.purchasedProductNames.contains(Utilities.productNames[index]) {
                    self.purchasedProductImages.append(Utilities.productImages[index])
                    self.purchasedProductNames.append(Utilities.productNames[index])
                    self.purchasedProductPrices.append(Utilities.productPrices[index])
                    
                    self.purchaseTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
                } else {
                    let purchasedIndex = self.purchasedProductNames.firstIndex(of: Utilities.productNames[index])
                    self.purchaseTableView.reloadRows(at: [IndexPath(row: purchasedIndex!, section: 0)], with: .fade)
                    self.decorateCellSelectionWhileSelect(cellToDecorate: self.purchaseTableView.cellForRow(at: IndexPath(row: purchasedIndex!, section: 0))!)
                }
            }
            self.calulateAndPrintPurchaseSumm()
        } else {
            Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Ошибка!", alertMessage: "Продукт не выбран", alertButtonHandler: nil)
        }
    }
    
    func decorateCellSelectionWhileSelect(cellToDecorate cell: UITableViewCell) {
        cell.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        cell.layer.cornerRadius = 4
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.backgroundColor = UIColor.white
        })
    }
    
    @IBAction func deletePurchase(_ sender: Any) {
        self.purchasedProductImages.removeAll()
        self.purchasedProductNames.removeAll()
        self.purchasedProductPrices.removeAll()
        
        for name in Utilities.productNames {
            Utilities.productsCount[name] = 0
        }
        
        self.purchaseTableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
        self.calulateAndPrintPurchaseSumm()
    //    self.selectedProductRow = nil
    }
    
    func calulateAndPrintPurchaseSumm() {
        var purchaseCommonPrice = 0.0
        
        for name in self.purchasedProductNames {
            let index = Utilities.productNames.firstIndex(of: name)
            purchaseCommonPrice += Double(Utilities.productsCount[name]!) * Utilities.productPrices[index!]
        }
        
        if purchaseCommonPrice != 0.0 {
            self.purchaseSummLabel.text = String(format: "ПОКУПКА НА СУММУ: %0.2f руб", purchaseCommonPrice)
        } else {
            self.purchaseSummLabel.text = "ПОКУПКА НА СУММУ:"
        }
    }
    
    @objc func showOrHidePurchaseView(_ sender: UIBarButtonItem) -> Void {
        if self.isPurchaseViewShowed == false {
            self.showPurchaseView()
        } else {
            self.hidePurchaseView()
        }
    }
    
    func showPurchaseView() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.purchaseContainerView.frame.origin.x =  self.view.frame.width -  self.purchaseContainerView.frame.width - 36 // (self.navigationController?.navigationBar.frame.height)!
            self.purchaseContainerView.frame.origin.y = self.navigationBarHeight! // (self.navigationController?.navigationBar.frame.height)!
        }, completion: { (completed: Bool) -> Void in
            self.selectBuildingButton?.image = self.hidePurchaseViewImage
            self.isPurchaseViewShowed = true
        })
    }
    
    func hidePurchaseView() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: { () -> Void in
            self.purchaseContainerView.frame.origin.x = self.view.frame.width
            self.purchaseContainerView.frame.origin.y = self.navigationBarHeight! //(self.navigationController?.navigationBar.frame.height)!
        }, completion: { (completed: Bool) -> Void in
            self.selectBuildingButton?.image = self.showPurchaseViewImage
            self.isPurchaseViewShowed = false
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Utilities.productCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productTypeId", for: indexPath) as! ProductTypeCollectionViewCell
        
        let fullProductName = Utilities.productNames[indexPath.row]
        cell.productTypeNameLabel.text = String(fullProductName[fullProductName.startIndex..<fullProductName.firstIndex(of: ".")!])
        
        self.decorateCollectionViewCell(cellToDecorate: cell)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.decorateCollectionViewCellWhileSelect(cellToDecorate: cell!)
        
        Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Выбор категории продуктов", alertMessage: "В демо версии не реализовано", alertButtonHandler: nil)
    }
    
    func decorateCollectionViewCell(cellToDecorate cell: UICollectionViewCell) {
        cell.layer.borderWidth = 0.4
        cell.layer.cornerRadius = 4
        cell.layer.borderColor = UIColor.red.withAlphaComponent(0.4).cgColor
    }
    
    func decorateCollectionViewCellWhileSelect(cellToDecorate cell: UICollectionViewCell) {
        cell.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.backgroundColor = UIColor.white
        })
    }
        
    @IBAction func getProductBarCode(_ sender: Any) {
        self.onScanDown()
    }
    
    func onScanDown()
    {
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
        Utilities.showOneButtonAlert(controllerInPresented: self, alertTitle: "Штрикод получен!", alertMessage: barcode, alertButtonHandler: nil)
    }
}
