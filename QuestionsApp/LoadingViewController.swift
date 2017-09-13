import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var retryView: UIView!
    
    @IBAction func retryCheckServerHealth(_ sender: UIButton) {
        checkServerHealth()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkServerHealth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func checkServerHealth(){
        showActivityIndicator()
        APIClient.shared.getServerHealth(onSuccess: {response in            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "questionsListNavigationController")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.window!.rootViewController = vc
        }, onError: {[weak self] error in
            self?.showRetryView()
        })
    }
    
    func showActivityIndicator(){
        activityIndicator.isHidden = false
        retryView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func showRetryView() {
        activityIndicator.isHidden = true
        retryView.isHidden = false
    }
}
