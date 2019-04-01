//
//  SettingsTableViewController.swift
//  Sale
//


import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var colorsView: UIView!
    @IBOutlet var accentColorButtons: [UIButton]!
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet var orgInfoView: UIView!
    @IBOutlet weak var orgNameTextField: UITextField!
    @IBOutlet weak var orgNameUnderView: UIView!
    @IBOutlet weak var pointNameTextField: UITextField!
    @IBOutlet weak var pointNameUnderView: UIView!
    @IBOutlet weak var pointAddressTextField: UITextField!
    @IBOutlet weak var pointAddressUnderView: UIView!
    @IBOutlet weak var itnTextField: UITextField!
    @IBOutlet weak var itnUnderView: UIView!
    @IBOutlet weak var kppTextField: UITextField!
    @IBOutlet weak var kppUnderView: UIView!
    @IBOutlet var taxTypeButtons: [UIButton]!
    @IBOutlet weak var saveOrgInfoButton: UIButton!
    @IBOutlet weak var cancelOrgInfoButton: UIButton!
    
    var isColorsViewPresented: Bool = false
    var isOrgInfoViewPresented: Bool = false
    var parentView: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.parentView = Utilities.mainController!.view
        Utilities.customizePopoverView(customizedView: self.colorsView)
        Utilities.customizePopoverView(customizedView: self.orgInfoView)
        
        for button in self.accentColorButtons {
            Utilities.makeButtonRounded(button: button)
            button.backgroundColor = Utilities.colors[accentColorButtons.firstIndex(of: button)!]
            button.layer.borderColor = button.backgroundColor?.cgColor
            button.tintColor = .white
        }
        
        let colorIndex = SettingsDBRules.getAccentColorIndex()!
        self.accentColorButtons[Int(colorIndex)].setImage(UIImage(named: "Check"), for: .normal)
        self.dismissButton.tintColor = Utilities.accentColor
        
        self.createDismissButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    //    self.changeAccentColorForOrgInfoView()
    }
    
    func changeAccentColorForOrgInfoView() {
        Utilities.setAccentColorForSomeViews(viewsToSetAccentColor: [self.orgNameTextField, self.pointNameTextField, self.pointAddressTextField, self.itnTextField, self.kppTextField, self.saveOrgInfoButton, self.cancelOrgInfoButton])
        Utilities.setBkgColorForSomeViews(viewsToSetAccentColor: [self.orgNameUnderView, self.pointNameUnderView, self.pointAddressUnderView, self.itnUnderView, self.kppUnderView])
        
        for taxTypeButton in self.taxTypeButtons {
            Utilities.makeButtonRounded(button: taxTypeButton)
        }
    }
    
    @IBAction func setTaxType(_ sender: UIButton) {
        
        for taxTypeButton in self.taxTypeButtons {
            taxTypeButton.setImage(nil, for: .normal)
        }
        
        sender.setImage(UIImage(named: "Check"), for: .normal)
    }
    
    @IBAction func cancelSaveOrgInfo(_ sender: UIButton) {
        Utilities.decorateButtonTap(buttonToDecorate: sender)
        Utilities.dismissKeyboard(conroller: self)
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.orgInfoView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isOrgInfoViewPresented = false
        })
    }
    
    func createDismissButton() {
        self.dismissButton.setImage(UIImage(named: "Cross")?.withAlignmentRectInsets(UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4)), for: .normal)
        Utilities.makeButtonRounded(button: self.dismissButton)
        self.dismissButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    @IBAction func dismissColorsView(_ sender: UIButton) {
        Utilities.removeOverlayView()
        
        UIView.animate(withDuration: Utilities.animationDuration, delay: 0.0, options: .curveEaseOut, animations: ({
            self.colorsView.alpha = 0.0
        }), completion: { (completed: Bool) in
            self.isColorsViewPresented = false
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            Utilities.setCellSelectedColor(cellToSetSelectedColor: cell)
            
            if indexPath.row == 0 && indexPath.section == 0 {
                self.showOrgInfoView()
                return
            }
            
            if indexPath.row == 0 && indexPath.section == 1 {
                self.showCategoryView()
                return
            }
        }
    }
    
    func getColorsViewCenterPoint() -> CGPoint {
        
        let centerX = (self.parentView?.center.x)!
        let centerY = (self.parentView?.center.y)!
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    func showCategoryView() {
        
        self.colorsView.center = self.getColorsViewCenterPoint()
        self.colorsView.alpha = 0.0
        self.colorsView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.colorsView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.isColorsViewPresented = true
        self.colorsView.alpha = 0.94
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.colorsView)
        
        Utilities.makeViewFlexibleAppearance(view: self.colorsView)
    }
    
    func showOrgInfoView() {
        
        self.orgInfoView.center = self.getColorsViewCenterPoint()
        self.orgInfoView.alpha = 0.0
        self.orgInfoView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        
        UIView.animate(withDuration: Utilities.animationDuration, animations: ({
            self.orgInfoView.alpha = 1.0
        }), completion: { (completed: Bool) in
        })
        
        self.changeAccentColorForOrgInfoView()
        
        self.isOrgInfoViewPresented = true
        Utilities.addOverlayView()
        self.parentView?.addSubview(self.orgInfoView)
        
        Utilities.makeViewFlexibleAppearance(view: self.orgInfoView)
    }
    
    @IBAction func setAccentColor(_ sender: UIButton) {
        
        for button in self.accentColorButtons {
            button.setImage(nil, for: .normal)
        }
        
        sender.setImage(UIImage(named: "Check"), for: .normal)
        
        let colorIndex = Int16(self.accentColorButtons.firstIndex(of: sender)!)
        
        SettingsDBRules.changeAccentColorIndex(colorIndex: colorIndex)
        Utilities.accentColor = Utilities.colors[Int(colorIndex)]!
        
        self.dismissButton.tintColor = Utilities.accentColor
        
        self.tableView.reloadData()
        
        Utilities.mainController!.tabBar.tintColor = Utilities.accentColor
        
        self.dismissColorsView(sender)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size , with: coordinator)
        
        self.colorsView.removeFromSuperview()
        
        coordinator.animate(alongsideTransition: { _ in
            if self.isColorsViewPresented {
                self.parentView?.addSubview(self.colorsView)
                self.colorsView.center = self.getColorsViewCenterPoint()
            }
        })
    }

}
