#!/usr/bin/swift

// JOIN PDFs together

import Foundation
import Quartz

let newFilename = "Combined.pdf"
let shallWeOutline = true

func createOutline(page: Int, label: String, pageObject: PDFPage) -> PDFOutline {
	let pageSize = pageObject.bounds(for: PDFDisplayBox.mediaBox)
	let x = 0.0 as Double
	let y = CGRectGetHeight(pageSize)
	let pagePoint = CGPointMake(x, y-1)
	let myDestination = PDFDestination.init(page: pageObject, at: pagePoint)
	let myOutline = PDFOutline.init()
	myOutline.label = label
	myOutline.destination = myDestination
	return myOutline
}

func joinPDFs(listOfFiles: Array<String>) -> Void {
	let parentPDF = PDFDocument.init()
	let parentOutline = PDFOutline.init()
	let destinationPath = (listOfFiles[0] as NSString).deletingLastPathComponent
	
	// Process each file
	for (index, filepath) in listOfFiles.enumerated() {
		let pdfURL = URL(fileURLWithPath: filepath)
		if let eachPDF = PDFDocument.init(url: pdfURL) {
			let title = (filepath as NSString).lastPathComponent
			let pages = eachPDF.pageCount

			// Process each page of the current PDF
			for p in (0...pages) {
				if let page = eachPDF.page(at: p) {
					parentPDF.insert(page, at: parentPDF.pageCount)
				if p==0{
					// On first page, check for existing Outlines, and make them children of new parent outline, 
					// with filename as label. If no existing outlines, just make outline of filename.
					let newOutline = createOutline(page: parentPDF.pageCount, label: title, pageObject: page)
					if let existingOutline = eachPDF.outlineRoot {
						var i = 0
						while i < existingOutline.numberOfChildren {
							if let childOutline = existingOutline.child(at: i) {
								newOutline.insertChild(childOutline, at: i)
							}
							i+=1
						}
					}
				
					parentOutline.insertChild(newOutline, at: index)
					parentOutline.child(at: index)?.isOpen = true
				}
				}
			}
		}
	}
		let newFilepath = destinationPath+"/"+newFilename
		parentPDF.outlineRoot = parentOutline
			parentPDF.write(toFile: newFilepath)
		
}
	
// "main"
if CommandLine.argc > 1 {
	
			joinPDFs(listOfFiles: Array(CommandLine.arguments[1...]))
			
}
	