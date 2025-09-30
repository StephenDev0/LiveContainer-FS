struct FSCategory: Identifiable, Codable {
    let id: String
    let name: String
}

let categories: [FSCategory] = [
    .init(id: "1", name: "Emulators"),
    .init(id: "3", name: "Adult"),
    .init(id: "7", name: "Music"),
    .init(id: "15", name: "Social media"),
    .init(id: "16", name: "Movies"),
    .init(id: "23", name: "Tools"),
    .init(id: "24", name: "Jailbreak"),
    .init(id: "30", name: "Photo & Video"),
    .init(id: "31", name: "Games"),
    .init(id: "32", name: " Arcade"),
    .init(id: "42", name: "AI tools"),
    .init(id: "45", name: "Sport")
]
