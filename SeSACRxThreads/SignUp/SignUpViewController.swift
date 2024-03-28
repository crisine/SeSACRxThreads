//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let validationButton = UIButton()
    let nextButton = PointButton(title: "다음")
    
    // MARK: Subject들은 이벤트를 보내는 것도/받는 것도 가능하다.
    private let sampleEmail = BehaviorSubject(value: "a@a.com") // Observable.just("a@a.com")
    private let buttonColor = Observable.just(UIColor.systemBlue)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        
        // MARK: 개선전
//        sampleEmail
//            .bind(with: self) { owner, value in
//                owner.emailTextField.text = value
//            }
//            .disposed(by: disposeBag)
        
        // MARK: 개선후
        sampleEmail
            .bind(to: emailTextField.rx.text).disposed(by: disposeBag)
        
        buttonColor
            .bind(to: nextButton.rx.backgroundColor,
                  emailTextField.rx.tintColor,
                  emailTextField.rx.textColor)
            .disposed(by: disposeBag)
        
        buttonColor
            .map { $0.cgColor }
            .bind(to: emailTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
            owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
        }
        .disposed(by: disposeBag)
        
        validationButton.rx.tap
            .bind(with: self) { owner, _ in
                // 이제는 =로 값을 바꾸지 않는다.
                owner.sampleEmail.onNext("b@b.com")
            }
            .disposed(by: disposeBag)
    }
    

    func configure() {
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    

}
