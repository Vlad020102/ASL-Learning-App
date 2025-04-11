import SwiftUI
import AVKit

class QuizViewModel: ObservableObject {
    @Published var quizes: QuizData = .init(bubblesQuizes: [], matchingQuizes: [], alphabetQuizes: [])
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadQuizes() {
        isLoading = true
        NetworkService.shared.getQuiz() { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.quizes = response.quizes
                case .failure(let error):
                    self?.errorMessage = "Failed to load quizzes: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct QuizCatalogueView: View {
    @StateObject var viewModel = QuizViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                AppColors.background.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage, retryAction: {
                            AuthManager.shared.removeToken()
                        })
                    } else {
                        quizList
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .foregroundStyle(AppColors.textSecondary)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Quizzes")
                            .font(.headline)
                    
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .accentColor(AppColors.card) // Sets navigation link and button colors
            .onAppear {
                viewModel.loadQuizes()
            }
        }
    }
    
    private var quizList: some View {
        List {
            ForEach(viewModel.quizes.bubblesQuizes, id: \.id) { quiz in
                quizCardView(for: .bubbles(quiz))
            }
            .listRowBackground(AppColors.background)
            
            ForEach(viewModel.quizes.matchingQuizes, id: \.id) { quiz in
                quizCardView(for: .matching(quiz))
            }
            .listRowBackground(AppColors.background)
            
            ForEach(viewModel.quizes.alphabetQuizes, id: \.id) { quiz in
                quizCardView(for: .alphabet(quiz))
            }
            .listRowBackground(AppColors.background)
        }

        .listStyle(PlainListStyle())
        .background(AppColors.background)
    }
    
    @ViewBuilder
    private func quizCardView(for quizType: QuizTypeWrapper) -> some View {
        let status = quizType.status
        let isDisabled = status == .Locked || status == .Failed || status == .Completed
        
        Group {
            switch quizType {
            case .bubbles(let quiz):
                NavigationLink(destination: BubblesView(quiz: quiz)) {
                    GenericQuizCard(
                        title: quiz.title,
                        type: quiz.type,
                        status: quiz.status,
                        score: quiz.score,
                        livesRemaining: quiz.livesRemaining
                    )
                }
                
            case .matching(let quiz):
                NavigationLink(destination: MatchingView(exercise: quiz)) {
                    GenericQuizCard(
                        title: quiz.title,
                        type: quiz.type,
                        status: quiz.status,
                        score: quiz.score,
                        livesRemaining: quiz.livesRemaining
                    )
                }
                
            case .alphabet(let quiz):
                NavigationLink(destination: AlphabetExerciseView(
                    testStrings: quiz.signs?.map { $0.text } ?? ["A", "B", "C", "D", "E"],
                    quizID: quiz.id,
                    startSign: quiz.signs?.first?.text ?? "A"
                )) {
                    GenericQuizCard(
                        title: quiz.title,
                        type: quiz.type,
                        status: quiz.status,
                        score: quiz.score,
                        livesRemaining: quiz.livesRemaining
                    )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(status == .Locked ? 0.6 : 1.0)
    }
}

// Preview provider
struct QuizContainerView_Previews: PreviewProvider {
    static var previews: some View {
        QuizCatalogueView()
    }
}
