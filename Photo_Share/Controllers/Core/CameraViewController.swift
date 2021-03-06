//
//  CameraViewController.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    
    private var output = AVCapturePhotoOutput()
    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    private let cameraView = UIView()
    
    private let cameraButton: UIButton = {
        
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.backgroundColor = nil
        return button
    }()
        
    private let photoPickerButton: UIButton = {
       let button = UIButton()
       button.tintColor = .label
        button.setImage(UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)), for: .normal)
       return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Take Photo"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        view.addSubview(cameraView)
        view.addSubview(cameraButton)
        view.addSubview(photoPickerButton)
        
        checkCameraPermission()
        cameraButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        photoPickerButton.addTarget(self, action: #selector(didTapPickPhoto), for: .touchUpInside)
    }
    
  
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        if let session = captureSession, !session.isRunning {
            session.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.frame = view.bounds
        previewLayer.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        
        let buttonSize: CGFloat = view.width/5
        cameraButton.frame = CGRect(x: (view.width-buttonSize)/2, y: view.safeAreaInsets.top + view.width + 100, width: buttonSize, height: buttonSize)
        cameraButton.layer.cornerRadius = buttonSize/2
        
        photoPickerButton.frame = CGRect(x: (cameraButton.left - (buttonSize/1.5))/2, y: cameraButton.top + ((buttonSize/1.5)/2), width: buttonSize/1.5, height: buttonSize/1.5)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }
    
    @objc func didTapClose() {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {
               [weak self] granted in guard granted else {
                    return
                }
            DispatchQueue.main.async {
                self?.setUpCamera()
            }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    @objc func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc func didTapPickPhoto() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    private func setUpCamera() {
        let captureSession = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if  captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch {
                print(error)
            }
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            // Layer
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            
            view.layer.addSublayer(previewLayer)
            captureSession.startRunning()
        }
    }
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        showEditPhoto(image: image)
    }
    
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        guard let image = UIImage(data: data) else {
            return
        }
        
        captureSession?.stopRunning()
        showEditPhoto(image: image)
        
    }
    
    private func showEditPhoto(image: UIImage) {
        guard let resizedImage = image.sd_resizedImage(with: CGSize(width: 640, height: 640), scaleMode: .aspectFill) else {
            return
        }
        
        let vc = PostEditViewController(image: resizedImage)
        navigationController?.pushViewController(vc, animated: false)
    }
}
