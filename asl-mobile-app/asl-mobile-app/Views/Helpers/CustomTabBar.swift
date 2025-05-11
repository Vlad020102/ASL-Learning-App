import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            TabBarButton(systemIconName: "person.fill", title: "Profile", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            Spacer()

            ZStack {
                Circle()
                    .foregroundColor(Color.yellow)
                    .frame(width: 70, height: 70)
                    .shadow(radius: 4)

                Button(action: {
                    selectedTab = 1
                }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.black)
                }
            }
            .offset(y: -20)

            Spacer()

            TabBarButton(systemIconName: "book.fill", title: "Quizzes", isSelected: selectedTab == 2) {
                selectedTab = 2
            }

            TabBarButton(systemIconName: "book.pages", title: "Wiki", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 25)
        .background(Color("accent3").edgesIgnoringSafeArea(.bottom))
        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
        .shadow(radius: 2)
    }
}

struct TabBarButton: View {
    var systemIconName: String
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemIconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .yellow : .gray)
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .yellow : .gray)
            }
        }
    }
}
