//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PhoneViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let descriptionLabel = UILabel()
    
    let validText = Observable.just("10자 이상 입력해주세요")
    let initialPhoneText = Observable.just("010")
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configureView()
        bind()
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
        view.addSubview(descriptionLabel)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    func configureView() {
        phoneTextField.keyboardType = UIKeyboardType.numberPad
    }

    private func bind() {
        nextButton.rx.tap.bind(with: self) { owner, _ in
            owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
        }.disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty.asObservable()
            .scan("") { oldValue, newValue in
                return newValue.isNumber ? newValue : oldValue
            }
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        
        initialPhoneText.bind(to: phoneTextField.rx.text).disposed(by: disposeBag)
        
        validText.bind(to: descriptionLabel.rx.text).disposed(by: disposeBag)
        
        let validation = phoneTextField.rx.text.orEmpty
            .map { $0.count >= 10 }
        
        validation.bind(to: nextButton.rx.isEnabled,
                        descriptionLabel.rx.isHidden)
        .disposed(by: disposeBag)
        
        validation.bind(with: self) { owner, value in
            let color: UIColor = value ? .systemPink : .lightGray
            owner.nextButton.backgroundColor = color
        }.disposed(by: disposeBag)
    }
}
