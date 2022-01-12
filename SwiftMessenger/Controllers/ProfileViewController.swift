//
//  ProfileViewController.swift
//  SwiftMessenger
//
//  Created by max on 15.12.2021.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import FirebaseStorage
import SDWebImage



final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var data = [ProfileViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileTableViewCell.self,
                           forCellReuseIdentifier: ProfileTableViewCell.identifier)
        
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "Name: \(UserDefaults.standard.value(forKey: "name") as? String ?? "No name")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .info,
                                     title: "E-mail: \(UserDefaults.standard.value(forKey: "email") as? String ?? "No e-mail")",
                                     handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout, title: "Log out", handler: {[weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: "Log Out", message: "Do you really want to log out?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                UserDefaults.standard.setValue(nil, forKey: "email")
                UserDefaults.standard.setValue(nil, forKey: "name")
                // Log out facebook
                
                FacebookLogin.LoginManager().logOut()
                // Google log out
                GIDSignIn.sharedInstance().signOut()
                
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: true)
                } catch {
                    print ("Failed to logout")
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            strongSelf.present(alert, animated: true)
        }))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableHeaderView = createTableHeader()

        
    }
    
    func createTableHeader() -> UIView? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width - 150) / 2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width / 2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print (error.localizedDescription)
            }
        })
        return headerView
    }
    
//    func downloadImage(imageView: UIImageView, url: URL) {
//        imageView.sd_setImage(with: url, completed: nil)
//        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
//            guard let data = data, error == nil else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                let image = UIImage(data: data)
//                imageView.image = image
//            }
//        }).resume()
//    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}


class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    public func setUp(with viewModel: ProfileViewModel) {
        self.textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }
}
