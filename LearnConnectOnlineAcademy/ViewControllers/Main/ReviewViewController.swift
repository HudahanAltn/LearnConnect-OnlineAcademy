//
//  ReviewViewController.swift
//  LearnConnectOnlineAcademy
//
//  Created by Hüdahan Altun on 26.11.2024.
//

import UIKit

class ReviewViewController: UIViewController {
    private struct Constants {
        static let starsCount: Int = 5
    }
    
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var coursePoint: UILabel!
    @IBOutlet weak var courseReviewCountLabel: UILabel!
    @IBOutlet weak var courseReviewLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTextViewCountLabel: UILabel!
    
    private var selectedRate: Int = 0
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    var textViewsHelper = UITextViewHelper()

    var commentCheck:Bool = false
    
    private lazy var sendReviewButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Değerlendirme Yap", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(sendReviewButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var starsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelectRate))
        stackView.addGestureRecognizer(tapGesture)
        
        return stackView
    }()
    
    var course:Item?
    var reviewVM = ReviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createStars()
        setupUI()
        
        setUpCourseDetails(course:course!)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.turnBackToPage))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = false
        if UserViewModel.currentUser() == nil{
            self.navigationItem.title = "Learn Connect"
            self.navigationItem.hidesBackButton = true
            self.view.alpha = 0.0
        }else{
            self.navigationItem.hidesBackButton = false
            self.view.alpha = 1.0
        }
        
    }
    func setUpCourseDetails(course:Item){
        coursePoint.text = "0.0"
        courseReviewCountLabel.text = "0 Değerlendirme"
        StorageManager().downloadImage(imageUrl: course.imageLink){
            image in
            DispatchQueue.main.async {
                self.courseImageView.image = image
                
            }
        }
        courseNameLabel.text = course.name
        
    }
    
    private func saveReviewToFirebase(){
        let review = Review()
        review.id = UUID().uuidString
        review.itemID = course?.id
        review.ownerId = UserViewModel.currentUser()?.email
        review.point = "\(selectedRate)"
        review.comment = commentTextView.text!

        self.reviewVM.saveReviewToFirestore(review)
    }
    
    
}

//MARK: - UI
extension ReviewViewController{
    private func createStars() {
        for index in 1...Constants.starsCount {
            let star = makeStarIcon()
            star.tag = index
            starsContainer.addArrangedSubview(star)
        }
    }
    
    private func makeStarIcon() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "star_unfill"), highlightedImage: UIImage(named: "star_fill"))
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    private func setupUI() {
        commentTextView.delegate = self
        
        commentTextView.keyboardType = .default
        commentTextView.returnKeyType = .default
        commentTextView.autocorrectionType = .no
        commentTextView.autocapitalizationType = .none
        commentTextView.backgroundColor = .systemGray2
        
        view.addSubview(starsContainer)
        view.addSubview(sendReviewButton)
        
        starsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starsContainer.topAnchor.constraint(equalTo: self.commentTextViewCountLabel.bottomAnchor,constant: 20),
            starsContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            starsContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            starsContainer.heightAnchor.constraint(equalToConstant: 40)
        ])

        sendReviewButton.translatesAutoresizingMaskIntoConstraints = false

        if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
            NSLayoutConstraint.activate([
                sendReviewButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(tabBarHeight + 20)),
                sendReviewButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                sendReviewButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                sendReviewButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            print("TabBar yüksekliği alınamadı!")
        }
        
    }
}
//MARK: - TextViewProtocol
extension ReviewViewController:UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        commentCheck = commentTextView.text.count > 2
        textView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textViewsHelper.checkCharacterTypeInNameTextView(textView: textView, range: range, string: text) && (commentTextView.text.count <= 200 || commentTextView.text.count > 2){
            commentTextViewCountLabel.text = "\(commentTextView.text.count + 1)/200"
            return true
        }else{
            dismissKeyboard()
            return false
        }
    }
    
}

//MARK: - OBJC
extension ReviewViewController{
    
    @objc private func didSelectRate(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: starsContainer)
        let starWidth = starsContainer.bounds.width / CGFloat(Constants.starsCount)
        let rate = Int(location.x / starWidth) + 1
        
        if rate != self.selectedRate {
            feedbackGenerator.selectionChanged()
            self.selectedRate = rate
        }
        
        starsContainer.arrangedSubviews.forEach { subview in
            guard let starImageView = subview as? UIImageView else {
                return
            }
            starImageView.isHighlighted = starImageView.tag <= rate
        }
    }
    
    @objc private func sendReviewButtonPressed() {
        
        if selectedRate != 0 && commentCheck{
            if Connectivity.isInternetAvailable(){
                saveReviewToFirebase()
                Alert.createAlertWithPop(title: "Başarılı", message: "Kurs değerlendirmesi eklendi.", view: self)
            }else{
                Alert.createAlert(title: Alert.noConnectionTitle, message: Alert.noConnectionMessage, view: self)
            }
        }else{
            Alert.createAlert(title: "Bilgilendirme", message: "Değerlendirme Yapabilmek için ilgili alanları doldurmanız gerekmektedir", view: self)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func turnBackToPage(){
        self.navigationController?.popViewController(animated: true)
    }
}
