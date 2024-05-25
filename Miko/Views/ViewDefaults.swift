let bottomSheetAnchor = 0.50
let viewFinderCenterY = (1.0 - bottomSheetAnchor) / 2

// Delay between each time the text updates, in miliseconds
let cameraSampleDelay: UInt64 = 500

// The maximum amount of movement users are allow to make while searching for text.
// App will stop looking for text if the use is moving their phone a lot.
let maximumUserAcceleration = 0.03

// Text will not be picked up if the string has fewer characters
let minimumSearchTextLength = 3

let cameraFadeOutHeight = 0.9
let cameraFadeInHeight = 0.6
let fadeInAndOutHeightDifference = cameraFadeOutHeight - cameraFadeInHeight
