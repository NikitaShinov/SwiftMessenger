//
//  RegisterViewController.swift
//  SwiftMessenger
//
//  Created by max on 15.12.2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill.badge.plus")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Enter your e-mail"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Enter your password"
        field.isSecureTextEntry = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Enter your first name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Enter your last name"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfileImage))
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfileImage() {
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        imageView.frame = CGRect(x: (scrollView.width - size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width / 2
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 30,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        
        registerButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 20,
                                   width: scrollView.width - 60,
                                   height: 52)
    }
    
    @objc private func registerButtonTapped() {
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        
        guard let email = emailField.text,
              let password = passwordField.text,
              let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              !email.isEmpty,
              email.contains("@"),
              !password.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty,
              password.count >= 5 else {
            aletUserLoginError()
            return
        }
        
        // Firebase login
        spinner.show(in: view)
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard !exists else {
                strongSelf.aletUserLoginError(message: "User already exists")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print ("Error creating User")
                    return
                }
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                    lastName: lastName,
                                                                    emailAddress: email))
                
                strongSelf.navigationController?.dismiss(animated: true)
            })
        })
    }
    
    func aletUserLoginError(message: String = "Please enter correct information") {
        let alert = UIAlertController(title: "Ooops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Profile"
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self]_ in
                                                        self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self]_ in
                                                        self?.presentPhotoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoLibrary() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
