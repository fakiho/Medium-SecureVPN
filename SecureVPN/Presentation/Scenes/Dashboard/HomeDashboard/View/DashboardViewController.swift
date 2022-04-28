//
//  ViewController.swift
//  VPN Guard
//
//  Created by Ali Fakih on 3/5/20.
//  Copyright © 2020 beApp. All rights reserved.
//

import UIKit
import Lottie
import GoogleMobileAds
import SCLAlertView
import AppTrackingTransparency

class DashboardViewController: UIViewController, StoryboardInstantiable, Alertable, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var bannerView: GADBannerView! {
        didSet {
            bannerView.isHidden = true
            bannerView.adUnitID = "ca-app-pub-1944147142676857/1695479999"
            bannerView.rootViewController = self
        }
    }

    @IBOutlet weak var currentIPTitleLabel: UILabel! {
        didSet {
            currentIPTitleLabel.font = Fonts.semiBoldFont
            currentIPTitleLabel.textColor = Colors.black
        }
    }
    
    @IBOutlet weak var currentIPLabel: UILabel! {
        didSet {
            currentIPLabel.font = Fonts.mediumFont
            currentIPLabel.textColor = Colors.black
        }
    }
    
    @IBAction func showServerTestAction(_ sender: Any) {
        self.viewModel.showServer()
    }
    
    @IBOutlet weak var flagImageView: UIImageView! {
        didSet {
            flagImageView.clipsToBounds = true
            flagImageView.layer.cornerRadius = flagImageView.layer.bounds.height / 2
            
        }
    }
    
    @IBOutlet weak var vpnTitleLabel: UILabel! {
        didSet {
            vpnTitleLabel.text = ""
            vpnTitleLabel.textColor = Colors.black
            vpnTitleLabel.font = Fonts.mediumFont
        }
    }
    
    @IBOutlet weak var serverListContainer: UIView! {
        didSet {
            self.serverListContainer.layer.cornerRadius = 20
            self.serverListContainer.clipsToBounds = true
        }
    }
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    private var isShowingListServer = false
    
    @IBOutlet weak var listVPNContainer: UIView!
    @IBOutlet weak var circleBorderContainer: UIImageView!
    @IBOutlet weak var proStatusImageView: UIImageView!
    
    lazy var interstitial: GADInterstitial = {
           return GADInterstitial(adUnitID: AdsConfiguration().interstitialKey)
    }()

    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            titleLabel.font = Fonts.blackFont
        }
    }
    
    @IBOutlet weak var connectContainer: UIView!
    @IBOutlet weak var subscribeContainer: SubscribeDashboardAlertView! {
        didSet {
            subscribeContainer.isHidden = true
        }
    }
    
    @IBOutlet weak var connectButton: UIButton!
    @IBAction func dis_ConnectAction(_ sender: UIButton) {
        if (!self.isShowingListServer) {
            self.viewModel.connectDisconnect()
        }
    }
    
    @IBOutlet weak var connectStatusButton: UIButton! {
        didSet {
            connectStatusButton.titleLabel?.font = Fonts.boldFont
        }
    }

    @IBAction func dis_ConnectStatusAction(_ sender: UIButton) {
        if (!self.isShowingListServer) {
            self.viewModel.connectDisconnect()
        }
    }
    
    private(set) var viewModel: DashboardViewModel!
    
    private var dashboardFactory: DashboardViewControllerFactory!
    
    lazy var animationView: AnimationView = {
        return AnimationView()
    }()
        
    private var serverListViewController: UIViewController?
    
    let worldAnimation = Animation.named("globeLoading")
    
    let connectedVPNAnimation = Animation.named("connectedVPN")
    
    final class func create(viewModel: DashboardViewModel, dashboardFactory: DashboardViewControllerFactory) -> DashboardViewController {
        let view = DashboardViewController.instantiateViewController()
        view.viewModel = viewModel
        view.dashboardFactory = dashboardFactory
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestPremission()
        
        view.backgroundColor = Colors.backgroundColor
        setupAnimation()
        startAnimating()
        connectContainer.bringSubviewToFront(connectButton)
        connectContainer.bringSubviewToFront(connectStatusButton)
        bind(viewModel)
        viewModel.viewDidLoad()
        subscribeContainer.isHidden = true
        bannerView.isHidden = true
        subscribeContainer.subscribeActionMonthly = { [weak self] in
            guard let self = self else { return }
            self.viewModel.onPurchaseModelClick()
        }
        
        interstitial.delegate = self
        listVPNContainer.addShadow(location: .bottom)
        bannerView.load(GADRequest())
    }
    
    private func bind(_ viewModel: DashboardViewModel) {
        viewModel.loadingType.observe(on: self, observerBlock: { [weak self] in self?.handleLoading($0)})
        viewModel.activityType.observe(on: self, observerBlock: { [weak self] in self?.handleActivity($0)})
        viewModel.status.observe(on: self, observerBlock: { [weak self] in self?.handleConnectionStatus($0)})
        viewModel.route.observe(on: self, observerBlock: { [weak self] in self?.handleRouting($0)})
        viewModel.premiumStatus.observe(on: self, observerBlock: { [weak self] in self?.handlePurchaseStatus($0)})
        viewModel.vpnAccount.observe(on: self, observerBlock: {[weak self] in self?.handleVPNSelection($0)})
        viewModel.currentIP.observe(on: self, observerBlock: {[weak self] in self?.handleIPUpdates($0)})
        viewModel.loadRequestAd.observe(on: self, observerBlock: {[weak self] in if $0 { self?.interstitial.load(GADRequest())}})
        viewModel.serverList.observe(on: self, observerBlock: {[weak self] in self?.handleServerList($0)})
        
    }
    
    private func handleServerList(_ servers: [Server]) {
        let vpnAccount = Configuration.loadFromDefaults()
        if !vpnAccount.server.isEmpty {
            self.viewModel.vpnAccount.value = Configuration(
                server: vpnAccount.server,
                country: vpnAccount.country,
                pro: vpnAccount.pro,
                account: vpnAccount.account!,
                password: vpnAccount.password,
                description: vpnAccount.description,
                remoteID: vpnAccount.remoteID,
                localID: vpnAccount.localID,
                certificate:vpnAccount.certificate, top:vpnAccount.top, adjustToken:vpnAccount.adjustToken)
            downloadImage(from: URL(string: "\(AppConfiguration().flagApi)\(vpnAccount.country)")!)
            self.vpnTitleLabel.text = vpnAccount.description
        }
        else if let server = servers.first {
            self.viewModel.vpnAccount.value = Configuration(
                server: server.server,
                country: server.country,
                pro: server.pro,
                account: server.account,
                password: server.password,
                description: server.serverDescription,
                remoteID: server.remoteId,
                localID: server.localId,
                certificate:server.certificate, top: server.top, adjustToken: server.adjustToken)
            downloadImage(from: URL(string: "\(AppConfiguration().flagApi)\(server.country)")!)
            self.vpnTitleLabel.text = server.serverDescription
        }
    }
    
    private func handleIPUpdates(_ newIP: String) {
        self.currentIPLabel.text = newIP
    }
    
    private func handleVPNSelection(_ vpnAccount: VPNAccount?) {
        if vpnAccount != nil {
            downloadImage(from: URL(string: "\(AppConfiguration().flagApi)\(vpnAccount!.country)")!)
            self.vpnTitleLabel.text = vpnAccount?.description
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async { [weak self] in
                self?.flagImageView.image = UIImage(data: data)
            }
        }
    }
    
    private func handlePurchaseStatus(_ status: Bool?) {
        guard let status = status else { return }
        UIView.animate(withDuration: 0.4, delay: 0, options: .transitionCurlUp, animations: {
            self.proStatusImageView.image = status ? Images.statusPro : Images.statusNotPro
            self.bannerView.isHidden = status
        })
    }
    
    private func handleLoading(_ loadingType: DashboardViewModelLoading) {
        animationView.animation = nil
        switch loadingType {
        case .none:
            circleBorderContainer.tintColor = Colors.redColor
            connectButton.tintColor = Colors.redColor
            connectButton.setBackgroundImage(Images.disconnectedVPN, for: .normal)
        case .fullScreen:
            break
        case .connecting:
            startAnimating(animation: worldAnimation, loop: .loop)
            circleBorderContainer.image = nil
            connectButton.setBackgroundImage(nil, for: .normal)
        case .connected:
            connectButton.setBackgroundImage(nil, for: .normal)
            circleBorderContainer.image = Images.circle
            connectButton.setBackgroundImage(Images.connectedVPN, for: .normal)
            circleBorderContainer.tintColor = Colors.greenColor
            connectButton.tintColor = Colors.greenColor
        case .disconnected:
            circleBorderContainer.image = Images.circle
            circleBorderContainer.tintColor = Colors.redColor
            connectButton.tintColor = Colors.redColor
            connectButton.setBackgroundImage(Images.disconnectedVPN, for: .normal)
        case .disconnecting:
            circleBorderContainer.image = nil
            connectButton.setBackgroundImage(nil, for: .normal)
            startAnimating(animation: worldAnimation, loop: .loop)
        }
    }
    
    private func handleActivity(_ activityType: DashboardViewModelActivity) {
        animationView.animation = nil
        switch activityType {
        case .none:
            self.loaderView.isHidden = true
        case .loading:
            self.loaderView.isHidden = false
        }
    }
    
    private func handleConnectionStatus(_ status: NetworkVPNStatus) {
        UIView.animate(withDuration: 1) {
            self.connectStatusButton.setTitle("\(status.rawValue)", for: .normal)
        }
    }
    
    private func handleRouting(_ route: DashboardViewModelRoute) {
        switch route {
        case .initial, .none:
            break
            
        case .inAppPurchaseView:
            let vc = dashboardFactory.makeInAppPurchaseViewController(dismissable: true, delegate: self)
            self.present(vc, animated: true, completion: nil)
            
        case .purchased:
            showAlert(title: "Success", message: "Thank you for your subscribe!")
        case .showAds:
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            }
            
        case .showServers(let delegate):
            guard let view = view else { return }
            if self.viewModel.serverList.value.count > 0 && !isShowingListServer {
                let vc = serverListViewController ?? dashboardFactory.makeServerListViewController(delegate: delegate, servers: self.viewModel.serverList.value)
                add(child: vc, container: serverListContainer)
                vc.view.frame = view.bounds
                serverListViewController = vc
                serverListContainer.isHidden = false
                
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
                    self.heightConstraint.constant = self.isShowingListServer ? 0 : 400
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
                self.isShowingListServer = true
                //self.subscribeContainer.isHidden = true
            }
            
        case .closeServers:
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.heightConstraint.constant = self.isShowingListServer ? 0 : 400
                self.view.layoutIfNeeded()

            }, completion: nil)
            self.serverListViewController?.remove()
            self.serverListViewController = nil
            self.isShowingListServer = false     
            //self.subscribeContainer.isHidden = false
        case .showPurchaseDeeplink:
            let vc = dashboardFactory.makeInAppPurchaseViewController(dismissable: true, delegate: self)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
        case .showUpdate:
            break
            //showWhatsNew()
        }
    }
    
    private func showWhatsNew() {
        SCLAlertView().showNotice("What's New?", subTitle: "Shake your phone to report a bug")
    }
    
    private func setupAnimation() {
        animationView.contentMode = .scaleAspectFit
        connectContainer.addSubview(animationView)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: connectContainer.layoutMarginsGuide.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: connectContainer.layoutMarginsGuide.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: connectContainer.layoutMarginsGuide.trailingAnchor),
            
            animationView.bottomAnchor.constraint(equalTo: connectContainer.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    private func startAnimating(animation: Animation? = Animation.named("guard_button"), loop: LottieLoopMode = .loop, _ completion: (() -> Void)? = nil) {
        animationView.animation = animation
        
        animationView.play(fromProgress: 0,
                           toProgress: 1,
                           loopMode: loop,
                           completion: { finished in
                            if finished {
                                print("Animation Finished")
                                completion?()
                            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.viewDidAppear()
    }
    
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            }
        }
    }
}

extension DashboardViewController: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        viewModel.didReceiveAd()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        viewModel.didFailToReceiveAd()
        print(error)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        viewModel.didDismissScreenAd()
    }
}

extension DashboardViewController: PurchaseDelegate {
    func didFinishPurchase() {
        self.viewModel.purchaseStatusDidChange()
    }
}

protocol DashboardViewControllerFactory {
    func makeInAppPurchaseViewController(dismissable: Bool, delegate: PurchaseDelegate) -> UIViewController
    func makeServerListViewController(delegate: ServerListViewModelDelegate, servers: [Server]) -> UIViewController
}

protocol PurchaseDelegate: AnyObject {
    func didFinishPurchase()
}

extension DashboardViewController {
    func requestPremission() {
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (authStatus) in
                switch authStatus {
                    
                case .notDetermined:
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                case .denied:
                    print("Denied")
                case .authorized:
                    print("Authorized")
                @unknown default:
                    break
                }
            }
        }
    }
}
