import SwiftUI

let bottomSheetAnchor = 0.66
let cameraViewButtonLocation = 1 - bottomSheetAnchor
let viewFinderCenterY = 0.22

let restSheetAnchor = PresentationDetent.fraction(bottomSheetAnchor)
let fullSheetAnchor = PresentationDetent.fraction(0.999)

// Delay between each time the text updates, in miliseconds
let cameraSampleDelay: UInt64 = 500
let cameraTextUpdateDelay: UInt64 = 1500

// The maximum amount of movement users are allow to make while searching for text.
// App will stop looking for text if the use is moving their phone a lot.
let maximumUserAcceleration = 0.03

// Text will not be picked up if the string has fewer characters
let minimumSearchTextLength = 3

let cameraFadeOutHeight = 0.9
let cameraFadeInHeight = 0.7
let fadeInAndOutHeightDifference = cameraFadeOutHeight - cameraFadeInHeight
