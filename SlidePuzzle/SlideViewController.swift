//
//  SlideViewController.swift
//  SlidePuzzle
//
//  Created by WEI XIE on 2016-11-26.
//  Copyright © 2016 WEI XIE. All rights reserved.
//

import UIKit
import CoreGraphics

class SlideViewController: UIViewController {
    
    enum Directions{
        case Up
        case Down
        case Left
        case Right
        case None
    }
    
    @IBOutlet weak var puzzleView: UIView!

    
    let horizontalPieces = 4
    let verticalPieces = 4
    let tileSpacing = 2
    
    var tileWidth:CGFloat?
    var tileHeight:CGFloat?
    
    var blankPosition:CGPoint!
    
    var tiles:Array<Tile>?
    
    var currentTile:Tile?
    
    var currentTouchedPoint:CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchEnd))
        let drag = UIPanGestureRecognizer(target: self,action: #selector(dragHandler))
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(drag)
        self.initPuzzle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Cut the original picture and shuffle it
    func initPuzzle() {
        self.tiles = Array<Tile>()
        guard let puzzleImage = UIImage(named:"pic.png") else {
            print("Error: Cannot read source image")
            return
        }
        let newSize = CGSize(width:self.puzzleView.bounds.width, height: self.puzzleView.bounds.width)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        puzzleImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let imageResized = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        
        self.tileWidth = imageResized.size.width/CGFloat(self.horizontalPieces)
        self.tileHeight = imageResized.size.height/CGFloat(self.verticalPieces)
        //let randomBlankCount =
        self.blankPosition = CGPoint(x: CGFloat(Int(arc4random())%self.horizontalPieces), y: CGFloat(Int(arc4random())%self.verticalPieces))
        //print("The blank position is \(self.blankPosition.x) and \(blankPosition.y)")
        
        //Cut the picture
        for x in 0...self.horizontalPieces-1 {
            for y in 0...self.verticalPieces-1 {
                let originalPosition = CGPoint(x: x, y: y)
                if self.blankPosition!.x == originalPosition.x && self.blankPosition!.y == originalPosition.y {
                    continue
                }
                
                let frame = CGRect(x: self.tileWidth!*CGFloat(x), y: self.tileHeight!*CGFloat(y), width: self.tileWidth!, height: self.tileHeight!)
                let tileImageRef = imageResized.cgImage!.cropping(to: frame)
                let tileImage = UIImage(cgImage:tileImageRef!)
                let tileFrame = CGRect(x: (self.tileWidth! + CGFloat(self.tileSpacing))*CGFloat(x), y: (self.tileHeight! + CGFloat(self.tileSpacing))*CGFloat(y), width:self.tileWidth!, height: self.tileHeight!)
                self.currentTile = Tile(image: tileImage)
                
                guard  let currentTile = self.currentTile else {
                    print("Error: Cannot generate tile")
                    return
                }
                currentTile.frame = tileFrame
                currentTile.originalPosition = originalPosition
                currentTile.currentPosition = originalPosition
                
                self.tiles?.append(currentTile)
                
                self.puzzleView.insertSubview(currentTile, at: 0)
                
            }
        }
        //To do a quick test to see what it looks like when the puzzle is completed, comment the line below
        self.shuffleTiles()
    }
    
    //Give the direction of the tile that can move towards
    func isValidToMove(selectedTile: Tile) -> Directions {
        if (selectedTile.currentPosition?.x == self.blankPosition.x && selectedTile.currentPosition?.y == self.blankPosition.y+1) {
            return .Up
        }
        
        if (selectedTile.currentPosition?.x == self.blankPosition.x && selectedTile.currentPosition?.y == self.blankPosition.y-1) {
            return .Down
        }
        
        if (selectedTile.currentPosition?.x == self.blankPosition.x+1 && selectedTile.currentPosition?.y == self.blankPosition.y) {
            return .Left
        }
        
        if (selectedTile.currentPosition?.x == self.blankPosition.x-1 && selectedTile.currentPosition?.y == self.blankPosition.y) {
            return .Right
        }
        return .None
    }
    
    func moveTile(selectedTile: Tile, withAnimation animation:Bool) {
        switch self.isValidToMove(selectedTile: selectedTile) {
            case .Up:
                self.moveTile(selectedTile: selectedTile, inDirectionX: 0, inDirectionY: -1, withAnimation: animation)
            case .Down:
                self.moveTile(selectedTile: selectedTile, inDirectionX: 0, inDirectionY: 1, withAnimation: animation)
            case .Left:
                self.moveTile(selectedTile: selectedTile, inDirectionX: -1, inDirectionY: 0, withAnimation: animation)
            case .Right:
                self.moveTile(selectedTile: selectedTile, inDirectionX: 1, inDirectionY: 0, withAnimation: animation)
            default:
                break
        }
    }
    
    func moveTile(selectedTile: Tile, inDirectionX dx:Int, inDirectionY dy:Int, withAnimation animation:Bool) {
        selectedTile.currentPosition = CGPoint(x: selectedTile.currentPosition!.x+CGFloat(dx), y: selectedTile.currentPosition!.y+CGFloat(dy))
        self.blankPosition = CGPoint(x: self.blankPosition.x-CGFloat(dx),y: self.blankPosition.y-CGFloat(dy))
        let x = selectedTile.currentPosition!.x
        let y = selectedTile.currentPosition!.y
        if (animation)  {
            UIView.beginAnimations("frame", context: nil)
        }
        selectedTile.frame = CGRect(x: (self.tileWidth! + CGFloat(self.tileSpacing))*CGFloat(x), y: (self.tileHeight! + CGFloat(self.tileSpacing))*CGFloat(y), width: self.tileWidth!, height: self.tileHeight!)
        if (animation)  {
            UIView.commitAnimations()
        }
        
    }
    
    func shuffleTiles(){
        var validMoves = Array<Tile>()
        for _ in 1...1000 {
            //Move 50 times
            for tile in self.tiles! {
                if(self.isValidToMove(selectedTile:tile) != .None){
                    validMoves.append(tile)
                }
            }
            let pick:Int = Int(arc4random())%validMoves.count
            self.moveTile(selectedTile:validMoves[pick], withAnimation: false)

        }
        
    }
    
    func getTileAtPoint(point:CGPoint) -> Tile? {
        let touchRect = CGRect(x: point.x, y: point.y, width: 1.0, height: 1.0)
        for tile in self.tiles! {
            if(tile.frame.intersects(touchRect)){
                return tile
            }
        }
        return nil
    }
    
    func isPuzzleCompleted() -> Bool {
        for tile in self.tiles! {
            if (tile.originalPosition!.x != tile.currentPosition!.x)||(tile.originalPosition!.y != tile.currentPosition!.y) {
                return false
            }
        }
        
        return true
    }
    
    
    //We filter the tiles that are not in line with blank postion, also sort them based on the distance to the blank tile so that we can move them in sequence
    func getMovableTiles() -> Array<Tile>? {
        guard let touchedTile  = self.getTileAtPoint(point: self.currentTouchedPoint!) else {
            return nil
        }
        
        if(touchedTile.currentPosition!.x == self.blankPosition.x){
            let minPosition = min(touchedTile.currentPosition!.y,self.blankPosition!.y)
            let maxPosition = max(touchedTile.currentPosition!.y,self.blankPosition!.y)
            return self.tiles!.filter({ (tile) -> Bool in
                tile.currentPosition!.y<=maxPosition&&tile.currentPosition!.y>=minPosition
            }).filter({ (tile) -> Bool in
                tile.currentPosition!.x == self.blankPosition.x
            }).sorted(by: {
                abs($0.currentPosition!.y-self.blankPosition!.y) < abs($1.currentPosition!.y-self.blankPosition!.y)
            })
        } else if (touchedTile.currentPosition!.y == self.blankPosition.y){
            let minPosition = min(touchedTile.currentPosition!.x,self.blankPosition!.x)
            let maxPosition = max(touchedTile.currentPosition!.x,self.blankPosition!.x)
            return self.tiles!.filter({ (tile) -> Bool in
                tile.currentPosition!.x<=maxPosition&&tile.currentPosition!.x>=minPosition
            }).filter({ (tile) -> Bool in
                tile.currentPosition!.y == self.blankPosition.y
            }).sorted(by: {
                abs($0.currentPosition!.x-self.blankPosition!.x) < abs($1.currentPosition!.x-self.blankPosition!.x)
            })
        } else {
            return nil
        }
    }
    
    //Touch delegate
    func touchEnd(gesture: UITapGestureRecognizer) {
        self.currentTouchedPoint = gesture.location(in: self.puzzleView)
        let tile = self.getTileAtPoint(point: self.currentTouchedPoint!)
        guard tile != nil  else {
            return
        }
        
        guard let tiles = self.getMovableTiles() else {
            return
        }
        for tile in tiles {
            self.moveTile(selectedTile:tile, withAnimation: true)
        }
        
        
        if (self.isPuzzleCompleted()) {
           self.handlePuzzleCompleted()
        }
        
    }
    
    
    //Drag delegate
    func dragHandler(gesture: UIPanGestureRecognizer) {
        if (gesture.state == .changed) {
            self.currentTouchedPoint = gesture.location(in: self.puzzleView)
            let tile = self.getTileAtPoint(point: self.currentTouchedPoint!)
            guard tile != nil  else {
                return
            }
            
            guard let tiles = self.getMovableTiles() else {
                return
            }
            
            let point = gesture.velocity(in: gesture.view?.superview)
            if (point.x > 0 && (self.isValidToMove(selectedTile:tiles[0]) == .Right)) {
                for tile in tiles {
                    self.moveTile(selectedTile:tile, withAnimation: true)
                }
            } else if (point.x < 0 && (self.isValidToMove(selectedTile:tiles[0]) == .Left)) {
                for tile in tiles {
                    self.moveTile(selectedTile:tile, withAnimation: true)
                }
            } else if (point.y > 0 && (self.isValidToMove(selectedTile:tiles[0]) == .Down)) {
                for tile in tiles {
                    self.moveTile(selectedTile:tile, withAnimation: true)
                }
            } else if (point.y < 0 && (self.isValidToMove(selectedTile:tiles[0]) == .Up)) {
                for tile in tiles {
                    self.moveTile(selectedTile:tile, withAnimation: true)
                }
            }
            if (self.isPuzzleCompleted()) {
                self.handlePuzzleCompleted()
            }
        }
    }
    
    func handlePuzzleCompleted(){
        let completedAlert = UIAlertController(title: "Congratulations!", message: "You have completed the puzzle!", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default, handler: { (action) -> Void in
            self.shuffleTiles()
        })
        completedAlert.addAction(tryAgainAction)
        self.present(completedAlert, animated: true, completion: nil)

    }
    
    
    
    @IBAction func ResetButtonPressed(_ sender: Any) {
        self.shuffleTiles()
    }

}

