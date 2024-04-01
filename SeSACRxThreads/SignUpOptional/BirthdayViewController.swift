//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    let monthLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    let dayLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    let year = PublishSubject<Int>() // BehaviorSubject(value: 2024) // 값을 전달도 받고 보내기도 해야해서 Observable에서 교체
    let month = PublishSubject<Int>() // BehaviorSubject(value: 03) // Behavior -> 초기값 있음 / Publish -> 없음
    let day = PublishSubject<Int>() // 비어있는 Instance를 Pubiush 하는 역할을 함
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        test()
        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
    }
    
    private func test() {
        // MARK: onNext로 전달하기보다 시작하자마자 초기값이 필요한 경우 BehaviorSubject를 사용한다.
        let publish = BehaviorSubject(value: 100)
        
        // 이벤트를 보내는것도 가능하고
        // MARK: 구독 전이라서 이벤트를 발생시켜봤자 못 받고
        publish.onNext(1)
        
        // MARK: 그러나 BehaviorSubject인 경우 여기서부터 출력이 된다.
        // MARK: 이유는 BehaviorSubject의 경우 구독하기 직전에 마지막으로 발생한 이벤트를 들고 있을 수 있기 때문이다.
        publish.onNext(2)
        
        // 이벤트를 받아서 처리도 가능하다
        // MARK: 이제 여기서 어떤식으로 처리할건지 알려주니까 이 이후의 이벤트만 받아진다
        publish.subscribe { value in
            print("publish - \(value)")
        } onError: { error in
            print("error")
        } onCompleted: {
            print("completed")
        } onDisposed: {
            print("disposed")
        }
        .disposed(by: disposeBag)
        
        // MARK: 이제 이 이벤트들은 받아지고
        publish.onNext(3)
        publish.onNext(4)

        // MARK: 얘 때문에 구독이 해지되어 이후의 이벤트들은 받아지지 않는다.
        publish.onCompleted()
        
        publish.onNext(5)
        publish.onNext(6)
    }
    
    private func bind() {
        
        year
            .map { "\($0)년" }
            .observe(on: MainScheduler.instance)        // Main 스레드에서 동작하도록 강제
            .subscribe(with: self) { owner, value in    // 강한 참조 방지를 위한 owner
                owner.yearLabel.text = "\(value)"
            }
            .disposed(by: disposeBag)
        
        month
            .map { "\($0)월" }                           // UI업데이트가 아닌 부분은 Back으로
            .observe(on: MainScheduler.instance)        // UI업데이트 파트는 Main에서
            .subscribe(with: self) { owner, value in
                owner.monthLabel.text = "\(value)"
            }
            .disposed(by: disposeBag)
        
        day
            .map { "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        day.onNext(20)
        
        // MARK: 코드 순서가 중요한데, 각 Year/Month/Day 레이블의 구독이 먼저 발생하지 않고
        // MARK: datepicker의 구독이 먼저 발생 후 레이블 구독이 나중에 발생하면,
        // MARK: 날짜 이벤트가 구독과 동시에 먼저 방출되더라도 그걸 받을 레이블 옵저버가 없어서 초기값이 안 나온다.
        birthDayPicker.rx.date
            .bind(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                
                owner.year.onNext(component.year!)
                owner.month.onNext(component.month!)
                owner.day.onNext(component.day!)
            }
            .disposed(by: disposeBag)
        
        let validation = birthDayPicker.rx.date.map { date in
                    let calendar = Calendar.current
                    let currentDate = Date()
            
                    let validAge = calendar.date(byAdding: .year, value: -17, to: currentDate)!
                    return date <= validAge
        }

        
        validation.bind(with: self) { owner, value in
            let color: UIColor = value ? .systemBlue : .lightGray
            owner.nextButton.backgroundColor = color

            let infoLabelText: String = value ? "가입 가능한 나이입니다." : "만 17세 이상만 가입 가능합니다"
            owner.infoLabel.text = infoLabelText

            let infoLabelTextColor: UIColor = value ? .systemBlue : .systemRed
            owner.infoLabel.textColor = infoLabelTextColor
        }
        .disposed(by: disposeBag)

        nextButton.rx.tap
        .bind(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate

            // SampleViewController 구현 후 연결
        }
        .disposed(by: disposeBag)
    }
    
    @objc func nextButtonClicked() {
        print("가입완료")
    }

    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
