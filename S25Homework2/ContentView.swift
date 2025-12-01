import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BreadView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Breads")
                }
            CakeView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Cakes")
                }
        }
    }
}

struct BreadView: View {
    @State private var viewModel = BreadViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            BreadListView(viewModel: viewModel)
            .navigationDestination(for: Bread.self) { bread in
                BreadDetailView(bread: bread)
            }
            .navigationTitle("빵")
            .task {
                await viewModel.loadBreads()
            }
            .refreshable {
                await viewModel.loadBreads()
            }
            .toolbar {
                Button {
                    showingAddSheet.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                BreadAddView(viewModel: viewModel)
            }
        }
    }
}

struct BreadListView: View {
    let viewModel: BreadViewModel
    
    func deleteBread(offsets: IndexSet) {
        Task {
            for index in offsets {
                let bread = viewModel.breads[index]
                await viewModel.deleteBread(bread)
            }
        }
    }
    
    
    var body: some View {
        List {
            ForEach(viewModel.breads) { bread in
                NavigationLink(value: bread) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bread.name)
                                .font(.headline)
                            Text("\(bread.calories)kcal")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onDelete(perform: deleteBread)
        }
    }
}


struct BreadDetailView: View {
    let bread: Bread

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("\(bread.calories) kcal")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(bread.rating))
                        .font(.title)
                        .foregroundColor(.yellow)
                }
                .padding(.bottom, 10)

                Text(bread.description ?? "(설명 없음)")
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .navigationTitle(bread.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CakeView: View {
    var body: some View {
        Text("Cake View")
    }
}

struct BreadAddView: View {
    let viewModel: BreadViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State var name = ""
    @State var calories = ""
    @State var rating = 3
    @State var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("빵 정보 *")) {
                    TextField("빵이름", text: $name)
                    TextField("칼로리", text: $calories)
                }
                
                Section(header: Text("선호도 *")) {
                    Picker("별점", selection: $rating) {
                        ForEach(1...5, id: \.self) { score in
                            Text("\(score)점")
                                .tag(score)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("설명")) {
                    TextEditor(text: $description)
                        .frame(height: 150)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        Task {
                            let cal = Int(calories) ?? 0
                            await viewModel.addBread(
                                Bread(id: UUID(), name: name, calories: cal, rating: rating, description: description)
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || calories.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
