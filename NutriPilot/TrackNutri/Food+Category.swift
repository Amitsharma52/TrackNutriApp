import Foundation

enum FoodRole {
    case protein
    case carbBase
    case fiber
    case lightProtein
    case heavyProtein
}

extension FoodItem {
    
    var role: FoodRole {
        let name = self.name.lowercased()
        
        
        // CARB BASES
        
        if name.contains("rice") ||
           name.contains("roti") ||
           name.contains("chapati") ||
           name.contains("poha") ||
           name.contains("upma") ||
           name.contains("oats") ||
           name.contains("idli") ||
           name.contains("dosa") ||
           name.contains("bread") ||
           name.contains("pasta") ||
           name.contains("quinoa") ||
           name.contains("corn") ||
           name.contains("sweet potato") {
            return .carbBase
        }
        
       
        //HEAVY PROTEINS

        if name.contains("chicken breast") {
            return .heavyProtein
        }
        
        if name.contains("soya") {
            return .heavyProtein
        }
        
        
        //NORMAL PROTEINS

        if name.contains("grilled chicken") ||
           name.contains("chicken curry") ||
           name.contains("tandoori chicken") {
            return .protein
        }
        
        
        // LIGHT PROTEINS
       
        if name.contains("egg") ||
           name.contains("yogurt") ||
           name.contains("curd") ||
           name.contains("tofu") ||
           name.contains("paneer") ||
           name.contains("milk") ||
           name.contains("almond") ||
           name.contains("buttermilk") {
            return .lightProtein
        }
        
       
        //  FIBER FOODS
        
        if fiber >= 2 {
            return .fiber
        }
        
       
        //  DEFAULT FALLBACK
         
        return .protein
    }
}
