// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
@testable import TensorFlow


final class MatrixTests: XCTestCase {
    func testDiagonalPart() {
        // Test on a matrix.
        let t1 = Tensor<Float>(shape: [4, 4], scalars: (1...16).map(Float.init))
        let target1 = Tensor<Float>([1, 6, 11, 16])
        XCTAssertEqual(t1.diagonalPart(), target1)

        // Test on a matrix with 2 leading dimentions.
        let t2 = Tensor<Float>([[[[1, 0, 0, 0],
                                  [0, 2, 0, 0],
                                  [0, 0, 3, 0],
                                  [0, 0, 0, 4]],
                                 [[5, 0, 0, 0],
                                  [0, 6, 0, 0],
                                  [0, 0, 7, 0],
                                  [0, 0, 0, 8]]]])
        let target2 = Tensor<Float>([[[1, 2, 3, 4], [5, 6, 7, 8]]])
        XCTAssertEqual(t2.diagonalPart(), target2)
        
        // Test diaginalPart gradient on matrix with 1 leading dimension
        let t3 = Tensor<Float>([[[1, 2, 3], [4, 5, 6], [7, 8, 9]]])
        let computedGrad = gradient(at: t3) { 2 * $0.diagonalPart().sum() }
        let expectedGrad = Tensor<Float>([[[2, 0, 0], [0, 2, 0], [0, 0, 2]]])
        XCTAssertEqual(computedGrad, expectedGrad)
    }
    
    func testDiagonal() {
        // Test on a matrix
        let t1 = Tensor<Float>(shape: [4], scalars: (1...4).map(Float.init))
        let target1 = Tensor<Float>([[1, 0, 0, 0],
                                     [0, 2, 0, 0],
                                     [0, 0, 3, 0],
                                     [0, 0, 0, 4]])
        XCTAssertEqual(t1.diagonal(), target1)
        
        // Test on a matrix with 2 leading dimentions
        let t2 = Tensor<Float>(shape: [2, 4], scalars: (1...8).map(Float.init))
        let target2 = Tensor<Float>([[[1, 0, 0, 0],
                                      [0, 2, 0, 0],
                                      [0, 0, 3, 0],
                                      [0, 0, 0, 4]],
                                     [[5, 0, 0, 0],
                                      [0, 6, 0, 0],
                                      [0, 0, 7, 0],
                                      [0, 0, 0, 8]]])
        XCTAssertEqual(t2.diagonal(), target2)
        
        // Test diaginalPart gradient on matrix with 1 leading dimension
        let t3 = Tensor<Float>(shape: [1, 3], scalars: (1...3).map(Float.init))
        let computedGrad = gradient(at: t3) { $0.squared().diagonal().sum() }
        let expectedGrad = 2 * t3
        XCTAssertEqual(computedGrad, expectedGrad)
    }
    
    func testBandPart() {
        let t1 = Tensor<Float>([[ 0,  1,  2, 3],
                                [-1,  0,  1, 2],
                                [-2, -1,  0, 1],
                                [-3, -2, -1, 0]])
        
        let target1 = Tensor<Float>([[ 0,  1,  2, 3],
                                     [-1,  0,  1, 2],
                                     [ 0, -1,  0, 1],
                                     [ 0,  0, -1, 0]])
        XCTAssertEqual(t1.bandPart(1, -1), target1)
        
        let target2 = Tensor<Float>([[ 0,  1,  0, 0],
                                     [-1,  0,  1, 0],
                                     [-2, -1,  0, 1],
                                     [ 0, -2, -1, 0]])
        XCTAssertEqual(t1.bandPart(2, 1), target2)
        
        // Test special case - diagonal
        XCTAssertEqual(t1.bandPart(0, 0), Tensor<Float>(zeros: [4, 4]))
        
        // Test leading dimensions with special case - lower triangular
        let t2 = Tensor<Float>(stacking: [t1, t1 + 1])
        let target3 = Tensor<Float>([[[ 0,  0,  0, 0],
                                      [-1,  0,  0, 0],
                                      [-2, -1,  0, 0],
                                      [-3, -2, -1, 0]],
                                     [[ 1,  0,  0, 0],
                                      [ 0,  1,  0, 0],
                                      [-1,  0,  1, 0],
                                      [-2, -1,  0, 1]]])
        XCTAssertEqual(t2.bandPart(-1, 0), target3)
        
        // Test bandPart gradient with special case - upper triangular
        let t3 = Tensor<Float>(shape: [2, 4, 4], scalars: (1...(2 * 16)).map(Float.init))
        let computedGrad = gradient(at: t3) { $0.squared().bandPart(0, -1).sum() }
        let expectedGrad = 2 * t3.bandPart(0, -1)
        XCTAssertEqual(computedGrad, expectedGrad)
    }
    
    static var allTests = [
        ("testDiagonalPart", testDiagonalPart),
        ("testDiagonal", testDiagonal),
        ("testBandPart", testBandPart)
    ]
}
