#!/usr/bin/swift

// PDF2PNG: Convert PDF to PNG images
// v1.0 © 2022 Ben Byram-Wigfield

import Quartz
import CoreGraphics

//PARAMETERS
let resolution = 300.0
let scale = resolution/72.0
let imageType = "public.png" as CFString // or tiff, jpeg, gif

let sp = CGColorSpace(name:CGColorSpace.sRGB)!
let whitecolor = CGColor.init(srgbRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
let transparency = CGImageAlphaInfo.noneSkipLast //The number 5

// Apparently we need a pointy thing
var pointything: UnsafeMutableRawPointer?

///////////////////
func createDir(filepath: String) -> String {
let baseName = (filepath as NSString).deletingPathExtension
var dirURL = URL(fileURLWithPath: baseName) as URL
var dirName = baseName
var myIndex = 0
while (FileManager.default.fileExists(atPath: dirName)) {
	myIndex += 1
	// Have to convert URL to String to append index, and back again
	let dirIndex = " " + String(format: "%02d", myIndex)
	dirName = baseName + dirIndex
	dirURL = URL(fileURLWithPath: dirName) as URL
}
	
	do {
			try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
				} catch {
					print(error.localizedDescription)
				}
	
	return dirName
}


func writeImage(image: CGImage, filepath: String, type: CFString, options: CFDictionary) -> Void {
	let fileURL = URL(fileURLWithPath: filepath) as CFURL
	if let destination = CGImageDestinationCreateWithURL(fileURL, type, 1, options) {
		CGImageDestinationAddImage(destination, image, options)
		CGImageDestinationFinalize(destination)
	}
}


func pdf2image(filepath: String) -> Void {
	let pathNoExt = (filepath as NSString).deletingPathExtension
	let titlename = (pathNoExt as NSString).lastPathComponent
	if let myPDF = CGPDFDocument.init(CGDataProvider.init(filename: filepath)!) {
		let numPages = myPDF.numberOfPages
	
		let location = createDir(filepath: pathNoExt)
	
	for i in 1...numPages+1 {
		if let page = myPDF.page(at: i) {
			let mediabox = page.getBoxRect(CGPDFBox.mediaBox)
			let xwidth = (mediabox.width*scale)
			let yheight = (mediabox.height*scale)
			let r = CGRect.init(x: 0, y: 0, width: xwidth, height: yheight)
			// Create a Bitmap context, draw a white background, and add the PDF
			let writeContext = CGContext.init(data: pointything, width: Int(xwidth), height: Int(yheight), bitsPerComponent: 8, bytesPerRow: 0, space: sp, bitmapInfo: 5)
			writeContext?.saveGState()
			writeContext?.scaleBy(x: scale, y: scale)
			writeContext?.setFillColor(whitecolor)
			writeContext?.fill(r)
			writeContext?.drawPDFPage(page)
			writeContext?.restoreGState()
			if let image = writeContext?.makeImage() {
				let options: CFDictionary = [kCGImagePropertyDPIHeight : String(resolution), kCGImagePropertyDPIWidth :  String(resolution)] as CFDictionary
								
				let pageFile = location + "/" + titlename + " " + String(format: "%02d", i) + ".png"
				print(pageFile)
				writeImage(image: image, filepath: pageFile, type: imageType, options: options)
			}
		}
		
	}
	
	}	
}

// "main"
if CommandLine.argc > 1 {
	for (index, args) in CommandLine.arguments.enumerated() {
		if index > 0 {
			pdf2image(filepath: args)
		}
}
}