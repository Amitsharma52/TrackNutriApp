import Foundation

struct MotivationEngine {
    
    static func message(
        eaten: Int,
        goal: Int
    ) -> String {
        
        guard goal > 0 else { return "Start tracking today 💪" }
        
        let progress = Double(eaten) / Double(goal)
        
        switch progress {
        case 0..<0.25:
            return "Let's get started! 💪"
            
        case 0.25..<0.6:
            return "You're doing great — keep going! 🔥"
            
        case 0.6..<0.9:
            return "Almost there — stay strong! 🚀"
            
        case 0.9...1.1:
            return "Perfect tracking today! 🎯"
            
        default:
            return "Slightly over today — balance tomorrow 👍"
        }
    }
}
