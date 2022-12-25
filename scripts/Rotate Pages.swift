#!/usr/bin/swift

// ROTATE PAGES: Rotate all pages of selected PDFs by 90˚
// v1.0 by Ben Byram-Wigfield

import Foundation
import Quartz

func newURL(filepath: String, newbit: String) -> String {
    var newname = filepath
    var index = 0
    while (FileManager.default.fileExists(atPath: newname)) {
        newname = (filepath as NSString).deletingPathExtension
        if index == 0 {
            newname += newbit
        } else {
            newname += " " + String(index) + newbit
        }
        index += 1
    }
return newname
}

func rotatePage(filepath: String) -> Int {
    let pdfURL = URL(fileURLWithPath: filepath)
    let newFilepath = newURL(filepath: filepath, newbit: " +90.pdf")
    if let pdfDoc = PDFDocument.init(url: pdfURL) {
        let pages = pdfDoc.pageCount
        for p in (0...pages) {
            let page = pdfDoc.page(at: p)
            var newRotation: Int = 90
            if let existingRotation = page?.rotation {
                newRotation = (existingRotation + 90) as Int
            }
            page?.rotation = newRotation
    }
        pdfDoc.write(toFile: newFilepath)
    }
    
    return 1
}

// "main"
if CommandLine.argc > 1 {
    for (index, args) in CommandLine.arguments.enumerated() {
        if index > 0 {
            rotatePage(filepath: args)
            
        }
}
}
