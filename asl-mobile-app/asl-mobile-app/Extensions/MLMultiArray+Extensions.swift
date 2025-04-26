import Foundation
import CoreML

extension MLMultiArray {
    // Return the index of the highest value in the MLMultiArray
    func argmax() throws -> Int {
        guard self.count > 0 else {
            throw NSError(domain: "MLMultiArrayError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Array is empty"])
        }
        
        var maxIndex = 0
        var maxValue = self[0].doubleValue
        
        for i in 1..<self.count {
            let value = self[i].doubleValue
            if value > maxValue {
                maxValue = value
                maxIndex = i
            }
        }
        
        return maxIndex
    }
}
