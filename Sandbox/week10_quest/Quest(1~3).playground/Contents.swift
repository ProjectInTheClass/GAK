import UIKit
import Foundation

//문제 1. 홀수 배열
var oddNumber: [Int] = [3,6,9,12,15]

//make evenNumber! 짝수를 만들어요!
for item in oddNumber {
    oddNumber.append(item + 1)
}
print(oddNumber)



/* 문제 2
 문자로 출력하기
 array3에 주어진 실수를 문자로 출력하세요. */
var array3 = [1, 50, 1.02]

// for문을 이용한 구현
var retArray3: [String] = []
for item in array3 {
    
    retArray3.append( String(item) );
}

retArray3







/* 문제 3
 제곱 수 구하기
 array4에 주어진 실수의 제곱수를 구하세요.
 단, 정수로 출력되어야 하며 소수 첫 째 자리에서 반올림하세요. */
var array4 = [4, -6, -1.6, 15]

// for문을 이용한 구현
var retArray4: [Int] = []
for item in array4 {
    
    var squared: Int
    squared = Int(round(item * item))
    retArray4.append( squared );
}

retArray4

/* 문제 5
 약수의 합 구하기.
 주어진 array1은 자연수가 담겨있습니다.
 각 자연수의 약수의 합을 구하세요. */

var array5 = [4, 6, 12, 27]

// for문을 이용한 구현
var retArray5: [Int] = []
for item in array5 {
    var sum = 0;
    for i in 1...item {
        if (item%i == 0){
            sum += i;
        }
    }
    retArray5.append(sum);
}

retArray5
