//
//  ContentView.swift
//  MyFirstApp
//
//  Created by JH's MacBook Air on 6/28/25.
//

import SwiftUI

// 동물 모델
struct Animal: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let backImageName: String
    let color: Color
}

// 등긁기 앱 메인 뷰
struct ContentView: View {
    @State private var selectedAnimal: Animal?
    @State private var isShowingBackScratching = false
    
    // 동물 데이터
    let animals = [
        Animal(name: "강아지", imageName: "dog", backImageName: "dog_back", color: .orange),
        Animal(name: "고양이", imageName: "cat", backImageName: "cat_back", color: .purple),
        Animal(name: "판다", imageName: "panda", backImageName: "panda_back", color: .black),
        Animal(name: "곰", imageName: "bear", backImageName: "bear_back", color: .brown)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라데이션
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isShowingBackScratching, let animal = selectedAnimal {
                    // 등긁기 화면
                    BackScratchingScreen(
                        animal: animal,
                        onBack: {
                            isShowingBackScratching = false
                            selectedAnimal = nil
                        }
                    )
                } else {
                    // 메인 화면 (동물 선택)
                    MainScreen(
                        animals: animals,
                        onAnimalSelected: { animal in
                            selectedAnimal = animal
                            isShowingBackScratching = true
                        }
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// 메인 화면 (동물 선택)
struct MainScreen: View {
    let animals: [Animal]
    let onAnimalSelected: (Animal) -> Void
    
    // 동물별 배경색 매핑
    private func backgroundColor(for animal: Animal) -> Color {
        switch animal.name {
        case "판다": return Color(red: 1.0, green: 0.97, blue: 0.85) // 연노랑
        case "곰": return Color(red: 1.0, green: 0.97, blue: 0.85)   // 연노랑
        case "강아지": return Color(red: 1.0, green: 0.97, blue: 0.85) // 연노랑
        case "고양이": return Color(red: 1.0, green: 0.97, blue: 0.85) // 연노랑
        default: return Color(.systemGray6)
        }
    }
    
    var body: some View {
        VStack {
            // 앱 제목 (상단 고정)
            VStack(spacing: 10) {
                Text("🐾 등긁기 앱 🐾")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("동물 친구들의 등을 긁어주세요!")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            Spacer()
            // 동물 선택 그리드 (2x2, 지정 순서)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                // 순서: 판다, 곰, 강아지, 고양이
                ForEach(["판다", "곰", "강아지", "고양이"], id: \.self) { name in
                    if let animal = animals.first(where: { $0.name == name }) {
                        AnimalCard(animal: animal, backgroundColor: backgroundColor(for: animal)) {
                            print("동물 선택됨: \(animal.name)")
                            onAnimalSelected(animal)
                        }
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
            // 하단 안내 텍스트
            VStack(spacing: 10) {
                Text("💡 팁")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("동물을 선택하면 등긁기 화면으로 이동합니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 30)
        }
        .frame(maxHeight: .infinity)
    }
}

// 등긁기 화면
struct BackScratchingScreen: View {
    let animal: Animal
    let onBack: () -> Void
    @State private var herePosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: 450)
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("여기가 가려워...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .offset(y: 80)
            
            Spacer()
            // 동물 이미지 영역 (배경색 적용)
            ZStack {
                // 배경색 (연노랑 예시)
                Color(red: 1.0, green: 0.97, blue: 0.85)
                    .ignoresSafeArea()
                
                // 동물 이미지 (화면에 꽉 차게)
                if let uiImage = UIImage(named: animal.backImageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(y: 40) // ← 여기서 y값을 늘릴수록 더 아래로 이동
                } else {
                    // 이미지가 없을 때
                    VStack(spacing: 20) {
                        Image(systemName: "questionmark")
                            .font(.system(size: 100))
                            .foregroundColor(.blue)
                        Text("이미지 없음")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                // here asset + "여기!" 텍스트 (드래그 가능)
                ZStack {
                    if let hereImage = UIImage(named: "here") {
                        Image(uiImage: hereImage)
                            .resizable()
                            .frame(width: 90, height: 90)
                    }
                    Text("여기!")
                        .font(.custom("Chalkboard SE", size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .offset(y: 15)
                }
                .frame(width: 90, height: 90, alignment: .center)
                .position(herePosition)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            herePosition = CGPoint(
                                x: value.startLocation.x + value.translation.width,
                                y: value.startLocation.y + value.translation.height - 40
                            )
                        }
                )
            }
            .frame(height: 400)
            Spacer()
            // 하단 버튼
            HStack(spacing: 30) {
                Button("뒤로") {
                    onBack()
                }
                .font(.title2)
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            Spacer(minLength: 10)
        }
        .frame(maxHeight: .infinity)
        .background(Color(red: 1.0, green: 0.97, blue: 0.85))
    }
}

// 동물 카드 뷰
struct AnimalCard: View {
    let animal: Animal
    var backgroundColor: Color = Color(.systemGray6)
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 6) {
            // 동물 뒷모습 이미지 또는 기본 아이콘
            ZStack {
                if let uiImage = UIImage(named: animal.backImageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    // 기본 동물 아이콘
                    ZStack {
                        Circle()
                            .fill(animal.color.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: getAnimalIcon(for: animal.name))
                            .font(.system(size: 40))
                            .foregroundColor(animal.color)
                    }
                    
                    // 디버깅용 텍스트 (개발 중에만 표시)
                    Text("이미지 없음")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .offset(y: 50)
                }
            }
            
            // 동물 이름
            Text(animal.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // 설명 텍스트
            Text("등긁기 시작")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .shadow(color: animal.color.opacity(0.15), radius: isPressed ? 2 : 8, x: 0, y: isPressed ? 1 : 4)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // 햅틱 피드백
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private func getAnimalIcon(for name: String) -> String {
        switch name {
        case "강아지": return "dog"
        case "고양이": return "cat"
        case "판다": return "pawprint"
        case "곰": return "bear"
        default: return "questionmark"
        }
    }
}

#Preview {
    ContentView()
}
