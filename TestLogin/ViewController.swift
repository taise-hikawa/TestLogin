import UIKit
import Firebase
import GoogleSignIn
import FirebaseFirestore

class ViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle!
    let db = Firestore.firestore()
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        logOutButton.addTarget(self, action: #selector(self.tapLogOutButton(_:)), for: .touchUpInside)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                //ログインの状態
                print(Auth.auth().currentUser!)
                print(user?.uid ?? "nodata")
                self.logOutButton.isHidden = false
                self.googleSignInButton.isHidden = true
                self.db.collection("users").document(user!.uid).getDocument{(document,error) in
                    if let document = document{
                        self.userNameLabel.text = document.data()!["name"] as? String
                    }else{
                        print(error!)
                    }
                }
            } else {
                //ログアウトの状態
                print("nouser")
                self.logOutButton.isHidden = true
                self.googleSignInButton.isHidden = false
                self.userImage.image = UIImage(named: "noimage")
                self.userNameLabel.text = "no user"
            }
        }
    }
    
    @objc func tapLogOutButton(_ sender: UIButton){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

