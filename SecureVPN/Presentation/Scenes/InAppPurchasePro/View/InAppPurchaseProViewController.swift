//
//  InAppPurchaseProViewController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 4/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import Lottie
import StoreKit

class InAppPurchaseProViewController: UIViewController, StoryboardInstantiable, Alertable, UIControllerLoadable
{
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var weeklyView: UIView! {
        didSet {
            weeklyView.layer.cornerRadius = 5
            weeklyView.layer.borderWidth = 0
            weeklyView.layer.borderColor = UIColor.purple.cgColor
        }
    }
    @IBOutlet weak var weeklyButton: UIButton!
    @IBOutlet weak var weeklyLabel: UILabel!

    @IBOutlet weak var monthlyView: UIView! {
        didSet {
            monthlyView.layer.cornerRadius = 5
            monthlyView.layer.borderWidth = 0
            monthlyView.layer.borderColor = UIColor.purple.cgColor
        }
    }
    @IBOutlet weak var monthlyButton: UIButton!
    @IBOutlet weak var monthlyLabel: UILabel!

    @IBOutlet weak var yearlyView: UIView! {
        didSet {
            yearlyView.layer.cornerRadius = 5
            yearlyView.layer.borderWidth = 0
            yearlyView.layer.borderColor = UIColor.purple.cgColor
        }
    }
    @IBOutlet weak var yearlyButton: UIButton!
    @IBOutlet weak var yearlyLabel: UILabel!

    @IBOutlet weak var bestDealLabel: UILabel! {
        didSet {
            bestDealLabel.layer.masksToBounds = true
            bestDealLabel.layer.cornerRadius = 5
        }
    }

    @IBAction func dismissBUttonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private var isDismissable: Bool = false
    
    @available(iOS 10.0, *)
    @IBAction func termsAction(_ sender: Any) {
        if let url = URL(string: AppConfiguration().termsAndConditions) {
            UIApplication.shared.open(url)
        }
    }
    
    @available(iOS 10.0, *)
    @IBAction func privacyAction(_ sender: Any) {
        if let url = URL(string: AppConfiguration().privacyPolicyURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBOutlet weak var restoreButtonTest: UIButton! {
        didSet {
            restoreButtonTest.titleLabel?.font = Fonts.subtitleRegularFont
            restoreButtonTest.setTitleColor(Colors.blueColor, for: .normal)
            restoreButtonTest.addTarget(self, action: #selector(restore), for: .touchUpInside)
        }
    }
    
    @objc func restore() {
        showAlert(title: "Restoring Purchase", message: "Make sure you are signed in with the apple account you previously purchased from.", style: .alert, completion: nil) { _ in
            self.viewModel.restore()
        }
    }
    
    @IBOutlet weak var animationContainer: UIView!
    lazy var animationView: AnimationView = {
        return AnimationView()
    }()
    let guardAnimation = Animation.named("purchaseAnimation")
    private var viewModel: InAppPurchaseViewModel!
    private var inAppPurchaseViewControllersFactory: InAppPurchaseViewControllersFactory!
    var subscriptionViewArray = [SubscriptionPeriodView]()
    
    class func create(viewModel: InAppPurchaseViewModel, inAppPurchaseViewControllersFactory: InAppPurchaseViewControllersFactory, isDismissable: Bool) -> InAppPurchaseProViewController {
        let view = InAppPurchaseProViewController.instantiateViewController()
        view.viewModel = viewModel
        view.inAppPurchaseViewControllersFactory = inAppPurchaseViewControllersFactory
        view.isDismissable = isDismissable
        return view
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    private var products: [SKProduct] = []
    private var subscriptionType: PurchaseType = .none
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.white
        setupAnimation()
        startAnimating(loop: .playOnce)
        bind(viewModel)
        viewModel.viewDidLoad()
        dismissButton.isHidden = !isDismissable
    }
    
    private func bind(_ viewModel: InAppPurchaseViewModel) {
        viewModel.route.observe(on: self, observerBlock: {[weak self] in self?.handleRoute($0)})
        viewModel.products.observe(on: self, observerBlock: {[weak self] in self?.handleProducts($0)})
        viewModel.loadingType.observe(on: self, observerBlock: {[weak self] in self?.handleLoading($0)})
        viewModel.error.observe(on: self, observerBlock: {[weak self] in self?.handleError($0)})
    }
    
    private func handleError(_ error: String) {
        if !error.isEmpty {
            showAlert(title: "Warning!", message: error)
        }
    }
    
    private func handleRoute(_ route: InAppPurchaseViewModelRoute) {
        switch route {
        case .initial:
            break
            
        case .back:
            //self.dismiss(animated: true, completion: nil)
            let dashboard = inAppPurchaseViewControllersFactory.makeDashboardViewController()
            dashboard.modalPresentationStyle = .fullScreen
            self.present(dashboard, animated: true, completion: nil)

        }
    }
    
    private func handleProducts(_ products: [SKProduct])
    {
        self.subscriptionViewArray.removeAll()
        for subview in self.stackView.arrangedSubviews
        {
            subview.removeFromSuperview()
        }
        self.products.removeAll()
        self.products = products
        let deeplinkURL = UserDefaults.standard.object(forKey: "deeplinkURL") as? String
        var productList = [String]()
        if (deeplinkURL != nil)
        {
            let deeplink = URL(string: deeplinkURL!)
            if let queryParam = deeplink?.queryDictionary
            {
                //handleParam here
                if let products = queryParam["inappProducts"] as? String
                {
                    productList = products.components(separatedBy: "-")
                }
            }
        }
        if self.products.count > 0 && productList.count > 0
        {
            for period in productList
            {
                let filteredProducts = self.products.filter { $0.productIdentifier.contains(period) }
                let product = filteredProducts.first
                let view = SubscriptionPeriodView.instanceFromNib()
                view.setContent(product: product!)
                view.buttonAction = { [weak self] in
                    print("button tapped")
                    self?.didUnSelectAll()
                    view.didSelect()
                    self!.didSelect(product!)
                }
                view.widthAnchor.constraint(equalToConstant: 89).isActive = true
                view.heightAnchor.constraint(equalToConstant: 100).isActive = true
                self.subscriptionViewArray.append(view)
                self.stackView.addArrangedSubview(view)
            }
        }
        else if self.products.count > 0
        {
            for product in self.products
            {
                let view = SubscriptionPeriodView.instanceFromNib()
                view.setContent(product: product)
                view.buttonAction = { [weak self] in
                    print("button tapped")
                    self?.didUnSelectAll()
                    view.didSelect()
                    self!.didSelect(product)
                }
                view.widthAnchor.constraint(equalToConstant: 89).isActive = true
                view.heightAnchor.constraint(equalToConstant: 100).isActive = true
                self.subscriptionViewArray.append(view)
                self.stackView.addArrangedSubview(view)
            }
        }
    }
    
    private func handleLoading(_ loading: InAppPurchaseViewModelLoading) {
        switch loading {
        case .none:
            print("None")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.stopActivityIndicator()
            }
            break
        case .purchased:
            /*showAlert(title: "Purchases", message: self.viewModel.message.value, style: .alert, completion: nil) { _ in
                self.dismiss(animated: true, completion: nil)
            }*/
            break
        case .purchasing:
            self.startActivityIndicator()
            break
        case .fetchingProducts:
            self.startActivityIndicator()
            break
        case .restored:
            //showAlert(title: "Purchases", message: self.viewModel.message.value, style: .alert, completion: nil) { _ in }
            break
        case .restoring:
            /*showAlert(title: "Purchases", message: self.viewModel.message.value, style: .alert, completion: nil) { _ in
                self.dismiss(animated: true, completion: nil)
            }*/
            break
        }
    }
      
    private func setupAnimation() {
        animationView.contentMode = .scaleAspectFit
        animationContainer.addSubview(animationView)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: animationContainer.layoutMarginsGuide.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: animationContainer.layoutMarginsGuide.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: animationContainer.layoutMarginsGuide.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: animationContainer.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func startAnimating(animation: Animation? = Animation.named("purchaseAnimation"), loop: LottieLoopMode = .loop, _ completion: (() -> Void)? = nil) {
        animationView.animation = animation
        
        animationView.play(fromProgress: 0,
                           toProgress: 1,
                           loopMode: loop,
                           completion: { finished in
                            if finished {
                                print("Animation Finished")
                                completion?()
                            } else {
                                print("Playing")
                            }
        })
    }
    
    /*@IBOutlet weak var productSection: UISegmentedControl! {
        didSet {
            productSection.removeAllSegments()
            
            if #available(iOS 13, *) {
                let titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.mainPurpleColor]
                
                let unselectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.lightGray]
                
                productSection.setTitleTextAttributes(unselectedTitleTextAttributes, for: .normal)
                productSection.setTitleTextAttributes(titleTextAttributes, for: .selected)
            } else {
                productSection.layer.cornerRadius = 10
                let titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.white]
                
                let unselectedTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.lightGray]
                
                productSection.setTitleTextAttributes(unselectedTitleTextAttributes, for: .normal)
                productSection.setTitleTextAttributes(titleTextAttributes, for: .selected)
            }
        }
    }*/
    
    /*@IBAction func productSectionAction(_ sender: UISegmentedControl) {
       didSelectProductFrom(sender)
    }*/
    
    @IBAction func productSectionAction(_ sender: UIButton)
    {
        didSelectProductFrom(sender)
    }
    
    private func didSelect(_ product: SKProduct)
    {
        subscribeButton.isEnabled = true
        if product.productIdentifier.contains("weekly")
        {
            subscriptionType = .week
        }
        else if product.productIdentifier.contains("monthly")
        {
            subscriptionType = .month
        }
        else if product.productIdentifier.contains("yearly")
        {
            subscriptionType = .year
        }
    }
    
    private func didUnSelectAll()
    {
        for view in subscriptionViewArray
        {
            view.didUnselect()
        }
    }
    
    private func didSelectProductFrom(_ sender: UIButton)
    {
        subscribeButton.isEnabled = true
        switch sender.tag
        {
        case 0:
            subscriptionType = .week
            weeklyView.backgroundColor = UIColor.white
            monthlyView.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
            yearlyView.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
            weeklyView.layer.borderWidth = 3
            monthlyView.layer.borderWidth = 0
            yearlyView.layer.borderWidth = 0
        case 1:
            subscriptionType = .month
            weeklyView.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
            monthlyView.backgroundColor = UIColor.white
            yearlyView.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
            weeklyView.layer.borderWidth = 0
            monthlyView.layer.borderWidth = 3
            yearlyView.layer.borderWidth = 0
        case 2:
            subscriptionType = .year
            weeklyView.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
            monthlyView.backgroundColor = UIColor.init(red: 199.0/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1.0)
            yearlyView.backgroundColor = UIColor.white
            weeklyView.layer.borderWidth = 0
            monthlyView.layer.borderWidth = 0
            yearlyView.layer.borderWidth = 3
        default:
            break
        }
    }

    /*private func didSelectProductFrom(_ sender: UISegmentedControl) {
        subscribeButton.isEnabled = true
        var title: String = ""
        switch sender.titleForSegment(at: sender.selectedSegmentIndex) {
        case "1 Day":
           title = "Subscribe (\(products[sender.selectedSegmentIndex].localizedPrice)/day)"           
        case "1 Week":
           title = "Subscribe (\(products[sender.selectedSegmentIndex].localizedPrice)/week)"
           subscriptionType = .week
        case "1 Month":
           title = "Subscribe (\(products[sender.selectedSegmentIndex].localizedPrice)/month)"
           subscriptionType = .month
        case "1 Year":
           title = "Subscribe (\(products[sender.selectedSegmentIndex].localizedPrice)/year)"
           subscriptionType = .year
        default:
           break
        }
        self.subscribeButton.setTitle(title, for: .normal)
    }*/
 
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = Fonts.titleMediumFont
            titleLabel.textColor = Colors.black
        }
    }
    
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = Fonts.subtitleRegularFont
            subtitleLabel.textColor = Colors.darkGray
        }
    }
    
    @IBOutlet weak var featuresButton: UIButton! {
        didSet {
            featuresButton.titleLabel?.font = Fonts.subtitleRegularFont
            featuresButton.setTitleColor(Colors.blueColor, for: .normal)
        }
    }
    
    @IBAction func featuresAction(_ sender: UIButton) {
    }
    
    @IBOutlet weak var warningLabel: UILabel! {
        didSet {
            warningLabel.font = Fonts.subtitleRegularFont
            warningLabel.textColor = Colors.darkGray
        }
    }
    
    @IBOutlet weak var subscribeButton: UIButton! {
        didSet {
            //subscribeButton.titleLabel?.font = Fonts.boldFont
            //subscribeButton.backgroundColor = Colors.systemPurple
            //subscribeButton.setTitle("Subscribe", for: .normal)
            subscribeButton.isEnabled = true
            //subscribeButton.setTitleColor(Colors.white, for: .normal)
            subscribeButton.addTarget(self, action: #selector(subscribe), for: .touchUpInside)
        }
    }
    
    @objc
    private func subscribe()
    {
        viewModel.userDidPurchase(with: subscriptionType)
    }
}
private extension SKProduct {
    
    static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
    
    var localizedPrice: String {
        if self.price == 0.00 {
            return "Free"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale
            
            guard let formattedPrice = formatter.string(from: self.price) else { return "--" }
            return formattedPrice
        }
    }
}

protocol InAppPurchaseViewControllersFactory
{
    func makeDashboardViewController() -> UIViewController
}

private extension URL {
    var queryDictionary: [String: Any]? {
        guard let query = self.query else { return nil }
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
            .components(separatedBy: "=")[1]
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
}

