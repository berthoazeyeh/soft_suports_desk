import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soft_support_decktop/models/attendances.dart';
import 'package:soft_support_decktop/ui/screens/records_screen.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DrawPdfServives {
  final String path = '${Directory.current.path}/assets/images/alert.png';

  PdfLayoutResult drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    // Dimensions pour l'image et le texte
    const double headerHeight = 90;
    const double imageWidth = 70;
    const double padding = 10;

    // Texte à dessiner
    const String headerText = 'Soft Education';
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 30);
    final PdfBrush textBrush = PdfBrushes.white;

    // Mesurer la largeur du texte
    const double textStartX = imageWidth + (2 * padding);

    // Dessiner le fond rectangulaire
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(91, 126, 215)),
      bounds: Rect.fromLTWH(0, 0, pageSize.width, headerHeight),
    );

    // Dessiner le texte
    page.graphics.drawString(
      headerText,
      headerFont,
      brush: textBrush,
      bounds: Rect.fromLTWH(
          textStartX, 0, pageSize.width - textStartX, headerHeight),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
    );

    // Dessiner le montant
    final double amountBoxStartX = pageSize.width - 150;
    page.graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(65, 104, 205)),
      bounds: Rect.fromLTWH(amountBoxStartX, 0, 150, headerHeight),
    );

    page.graphics.drawString(
      'Raport du 19/12/2024',
      PdfStandardFont(PdfFontFamily.helvetica, 18),
      bounds: Rect.fromLTWH(amountBoxStartX, 0, 150, headerHeight),
      brush: PdfBrushes.white,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    // Ajouter les informations de facture (numéro et date)
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    // final DateFormat format = DateFormat.yMMMMd('en_US');

    return PdfTextElement(text: '', font: contentFont).draw(
      page: page,
      bounds: Rect.fromLTWH(
        padding,
        headerHeight + 10,
        pageSize.width - padding,
        pageSize.height - headerHeight - 10,
      ),
    )!;
  }

  //Draws the grid
  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;

    //Draw grand total.
    page.graphics.drawString('Grand Total',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            quantityCellBounds!.left,
            result.bounds.bottom + 10,
            quantityCellBounds!.width,
            quantityCellBounds!.height));
    page.graphics.drawString("0",
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds!.left,
            result.bounds.bottom + 10,
            totalPriceCellBounds!.width,
            totalPriceCellBounds!.height));
  }

  //Draw the invoice footer data.
  void drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));

    const String footerContent =
        // ignore: leading_newlines_in_multiline_strings
        '''800 Interchange Blvd.\r\n\r\nSuite 2501, Austin,
         TX 78721\r\n\r\nAny Questions? support@adventure-works.com''';

    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

  //Create PDF grid and return
  PdfGrid getGrid(
      List<HeaderType> formatHeaderPrint, List<AttendanceRecord> records) {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: formatHeaderPrint.length);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;

    for (var i = 0; i < formatHeaderPrint.length; i++) {
      headerRow.cells[i].stringFormat.lineAlignment =
          PdfVerticalAlignment.middle;
      headerRow.cells[i].value = formatHeaderPrint[i].label;
    }
    for (var record in records) {
      addProducts(record, grid, formatHeaderPrint);
    }

    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[0].width = 130;
    grid.columns[1].width = 100;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        cell.stringFormat.lineAlignment = PdfVerticalAlignment.middle;
        if (j == row.cells.count - 1) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  //Create and row for the grid.
  void addProducts(
    AttendanceRecord record,
    PdfGrid grid,
    List<HeaderType> formatHeaderPrint,
  ) {
    final PdfGridRow row = grid.rows.add();
    for (var i = 0; i < formatHeaderPrint.length; i++) {
      String labels = '';
      switch (formatHeaderPrint[i].width) {
        case 1:
          labels = record.partner.displayName;
          break;
        case 2:
          labels = DateFormat("dd/MM/yyyy HH:mm:ss").format(record.checkIn);
          break;
        case 3:
          labels = record.checkOut != null
              ? DateFormat("dd/MM/yyyy HH:mm:ss").format(record.checkOut!)
              : '--';
          break;
        case 4:
          labels = record.partner.rfidNum;
          break;
        case 5:
          labels = record.partner.rfidCode;
          break;
        case 6:
          labels = record.checkOut != null
              ? '${(record.checkOut!.difference(record.checkIn)).inHours}:${(record.checkOut!.difference(record.checkIn)).inMinutes}:${(record.checkOut!.difference(record.checkIn)).inSeconds}'
              : '0';
          break;
        default:
          labels = record.partner.displayName;
      }
      row.cells[i].value = labels;
    }
  }
}
