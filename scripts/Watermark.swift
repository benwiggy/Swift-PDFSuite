#!/usr/bin/swift

// WATERMARK: Add text to PDF pages
// v1.0 by Ben Byram-Wigfield

import Foundation
import Quartz

// OPTIONS
let watermarkText = "Sample"
let textColor = NSColor.red
let startCoord = CGPoint(x: 150, y: 200)


func newURL(filepath: String, newbit: String) -> String {
    var newname = filepath
    while (FileManager.default.fileExists(atPath: newname)) {
    newname = (newname as NSString).deletingPathExtension
// Could be improved with incremental number added to filename
    newname += newbit
    }
return newname
}

func watermark(filepath: String, myText: String, myColor: NSColor, myPoint: CGPoint) -> Void {
    let pdfURL = URL(fileURLWithPath: filepath)
    if let pdfDoc: PDFDocument = PDFDocument(url: pdfURL) {
        let newFilepath = newURL(filepath: filepath, newbit: " WM.pdf")
        let pages = pdfDoc.pageCount
        if let firstPage = pdfDoc.page(at: 0) {
            var mediaBox: CGRect = firstPage.bounds(for: .mediaBox)
            let newURL = URL(fileURLWithPath: newFilepath) as CFURL
            let gc = CGContext(newURL, mediaBox: &mediaBox, nil)!
        for p in (0...pages-1) {
        let page: PDFPage = pdfDoc.page(at: p)!

        let nsgc = NSGraphicsContext(cgContext: gc, flipped: false)
        NSGraphicsContext.current = nsgc
        gc.beginPDFPage(nil); do {
            page.draw(with: .mediaBox, to: gc)

            let style = NSMutableParagraphStyle()
            style.alignment = .center

            let richText = NSAttributedString(string: myText, attributes: [
                NSAttributedString.Key.font: NSFont.systemFont(ofSize: 150),
                NSAttributedString.Key.foregroundColor: myColor,
                NSAttributedString.Key.paragraphStyle: style
                ])
// Possible automatic placement of text in the middle of the page.
         // let richTextBounds = richText.size()
       // var point = CGPoint(x: mediaBox.midX - richTextBounds.width / 2, y: mediaBox.midY - richTextBounds.height / 2)
           
            gc.saveGState(); do {
                gc.translateBy(x: myPoint.x, y: myPoint.y)
                gc.rotate(by: .pi / 5)
                richText.draw(at: .zero)
            }; gc.restoreGState()
        }; gc.endPDFPage()

            if p == pages-1 {
                NSGraphicsContext.current = nil
        gc.closePDF()
            }
        }
        }
        }
    return
}


if CommandLine.argc > 1 {
    for (index, args) in CommandLine.arguments.enumerated() {
        if index > 0 {
            watermark(filepath: args, myText: watermarkText, myColor: textColor, myPoint: startCoord)
            
        }
}
}