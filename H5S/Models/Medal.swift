import SwiftyJSON

class Medal
{
    var medalId: Int = 0
    var count: Int = 0
    var description: String = ""
    var name: String = ""
    var classification: String = ""
    var difficulty: Int = 0
    var sprite: UIImage?

    init(medalId: Int, count: Int, description: String, name: String, classification: String, difficulty: Int)
    {
        self.medalId = medalId
        self.count = count
        self.description = description
        self.name = name
        self.classification = classification
        self.difficulty = difficulty
    }
}

extension Medal
{
    struct PropertyKeys {
        static let leftKey = "left"
        static let heightKey = "height"
        static let widthKey = "width"
        static let topKey = "top"
        static let spriteSheetUriKey = "spriteSheetUri"
    }

    static func createSprite(spriteLocation: JSON) -> UIImage
    {
        let x = CGFloat(spriteLocation[PropertyKeys.leftKey].floatValue)
        let y = CGFloat(spriteLocation[PropertyKeys.topKey].floatValue)
        let h = CGFloat(spriteLocation[PropertyKeys.heightKey].floatValue)
        let w = CGFloat(spriteLocation[PropertyKeys.widthKey].floatValue)

        let rect = CGRect(origin: CGPoint(x: x,y :y), size: CGSize(width: w, height: h))

        let filename = "medals-spritesheet.png"

        let sheetImage = UIImage(named: filename)
        return sheetImage!.crop(rect: rect)
    }
}

extension UIImage
{
    func crop(rect: CGRect) -> UIImage
    {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)

        return image
    }
}
