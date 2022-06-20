//
//  UploadDigitalTicketViewController.swift
//  fanatick
//
//  Created by Yashesh on 03/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxCocoa
import RxSwift
import MobileCoreServices

class UploadDigitalTicketViewController: TableViewController {
    
    let viewModel = AddTicketInfoViewModel()
    let header = DigitalTicketHeaderCell()
    let buttonFinish = Button()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        DigitalTicketCell.registerCell(tableView: tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.tableHeaderView = header
        tableView.tableFooterView = UIView.init(frame: .zero)
        header.setNeedsLayout()
        header.layoutIfNeeded()

        view.addSubview(buttonFinish)
        
        constrain(tableView, buttonFinish) { (tableView, buttonFinish) in
            tableView.top == tableView.superview!.safeAreaLayoutGuide.top
            tableView.leading == tableView.superview!.leading
            tableView.trailing == tableView.superview!.trailing
            tableView.bottom == tableView.superview!.safeAreaLayoutGuide.bottom - 100
            
            buttonFinish.leading == buttonFinish.superview!.leading + K.Dimen.smallMargin
            buttonFinish.trailing == buttonFinish.superview!.trailing - K.Dimen.smallMargin
            buttonFinish.height == K.Dimen.button
            buttonFinish.bottom == buttonFinish.superview!.safeAreaLayoutGuide.bottom - 30
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        hasCloseButton = true
        navigationController?.navigationBar.isTranslucent = true
        title = LocalizedString("upload_digital_tickets", story: .ticketinfo)
        buttonFinish.setTitle(LocalizedString("finish", story: .ticketinfo), for: UIControl.State.normal)
        buttonFinish.defaultYellowStyling(cornerRadius: K.Dimen.button / 2, borderColor: .fanatickLightGrey)
    }
    
    override func addObservables() {
        super.addObservables()
        
        viewModel.isValid
            .bind(to: buttonFinish.rx.isEnabled)
            .disposed(by: disposeBag)
        
        buttonFinish
            .rx
            .tap
            .bind(to: viewModel.listTicketAction)
            .disposed(by: disposeBag)
        
        viewModel.error
            .filter{ $0 != nil }
            .subscribe(onNext: { [weak self] (error) in
                self?.handleError(error: error!.runtimeError)
            }).disposed(by: disposeBag)
        
        viewModel
            .success
            .subscribe(onNext: { [weak self] _ in
                
                NotificationCenter.default.post(name: Notification.Name.ReloadListing, object: nil)
                
                self?.presentingViewController?
                    .presentingViewController?
                    .presentingViewController?
                    .presentingViewController?.dismiss(animated: true, completion: nil)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.ticketIndexPath.subscribe(onNext:{ [weak self] (indexPath) in
            
            if indexPath == nil {return}
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let photoAction = UIAlertAction(title: LocalizedString("photo_and_video_library",
                                                                   story: .ticketinfo),
                                            style: .default
                ,
                                            handler: { (_) in
                                                self?.choosePhotoButtonTapped()
            })
            photoAction.setValue(UIColor.fanatickBlack, forKey: "titleTextColor")
            photoAction.setValue(UIImage.init(named: "icon_photo")?.withRenderingMode(.alwaysOriginal), forKey: "image")
            photoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(photoAction)
            
            let documentAction = UIAlertAction(title: LocalizedString("document",
                                                                   story: .ticketinfo),
                                            style: .default
                ,
                                            handler: { (_) in
                                                self?.openDocumentPickerViewcontroller()
                                                            })
            documentAction.setValue(UIColor.fanatickBlack, forKey: "titleTextColor")
            documentAction.setValue(UIImage.init(named: "icon_document")?.withRenderingMode(.alwaysOriginal), forKey: "image")
            documentAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            alert.addAction(documentAction)
            
            alert.addAction(
                UIAlertAction(title: LocalizedString("cancel"),
                              style: .cancel,
                              handler: nil)
            )
            self?.navigationController?.present(alert,
                                                animated: true,
                                                completion: nil)
        }).disposed(by: disposeBag)
        
        viewModel.reloadTable.subscribe(onNext: { [weak self] indexPath in
            guard let indexPath = indexPath else { return }
            self?.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }).disposed(by: disposeBag)
    }
    
    @objc func choosePhotoButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func openDocumentPickerViewcontroller() {
        let documentProvider = UIDocumentPickerViewController(documentTypes: ["public.image",String(kUTTypePDF)], in: .import)
        documentProvider.delegate = self
        present(documentProvider, animated: true, completion: nil)
    }
    
    override func dismissButtonTapped() {
        super.dismissButtonTapped()
        ActivityIndicator.shared.stop()
    }
}

extension UploadDigitalTicketViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ticketListing.value?.tickets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = DigitalTicketCell.dequeueCell(tableView: tableView) {
            cell.load(viewModel: viewModel, indexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
}

extension UploadDigitalTicketViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let fileToUpload = UploadFile(type: .image, image: pickedImage, sourceUrl: nil)
            uploadFiletoAWSS3Bucket(fileToUpload: fileToUpload)
            
        }
    }
    
    fileprivate func uploadFiletoAWSS3Bucket(fileToUpload: UploadFile) {
        
        AWSImageUploader.rx.uploadFile(folder: .ticket, file: fileToUpload)
            .do(onCompleted: {
                ActivityIndicator.shared.stop()
            }, onSubscribed: {
                ActivityIndicator.shared.start()
            }).subscribe(onNext: { [weak self] (result) in
                if let error = result.error {
                    self?.handleError(error: error.runtimeError)
                } else if let value = result.value  {
                    self?.viewModel.uploadAction.accept((self?.viewModel.ticketIndexPath.value ?? nil, value))
                    self?.viewModel.isValid.accept(self?.viewModel.validDigitalTicketUploaded() ?? false)
                    self?.viewModel.reloadTable.accept(self?.viewModel.ticketIndexPath.value ?? nil)
                }
            }).disposed(by: disposeBag)
    }
}

extension UploadDigitalTicketViewController : UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if urls.count == 0 { return }
        let pathExtensionFromUrl = urls[0].pathExtension.lowercased()
        
        guard let pathExtension = K.PathExtension(rawValue: pathExtensionFromUrl) else {
            return
        }
        
        let sourceUrl = urls[0]
        var fileToUpload: UploadFile!
        
        switch pathExtension {
        case .PDF:
            fileToUpload = UploadFile(type: .pdf, image: nil, sourceUrl: sourceUrl)
        case .PNG:
            fileToUpload = UploadFile(type: .image, image: nil, sourceUrl: sourceUrl)
        }
        uploadFiletoAWSS3Bucket(fileToUpload: fileToUpload)
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
