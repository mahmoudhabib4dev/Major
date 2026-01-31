import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    // Set status bar to dark icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Zoom out button
            IconButton(
              icon: const Icon(Icons.zoom_out, color: Color(0xFF000D47)),
              onPressed: () {
                if (_pdfViewerController.zoomLevel > 1) {
                  _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25;
                }
              },
            ),
          ],
        ),
        leadingWidth: 48,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000D47),
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (_totalPages > 0)
              Text(
                'صفحة $_currentPage من $_totalPages',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          // Zoom in button
          IconButton(
            icon: const Icon(Icons.zoom_in, color: Color(0xFF000D47)),
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25;
            },
          ),
          // Back button (left side in RTL)
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF000D47),
            ),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,
        controller: _pdfViewerController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _totalPages = details.document.pages.count;
          });
        },
        onPageChanged: (PdfPageChangedDetails details) {
          setState(() {
            _currentPage = details.newPageNumber;
          });
        },
      ),
      // Page navigation bottom bar
      bottomNavigationBar: _totalPages > 0
          ? Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Next page button
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                    onPressed: _currentPage < _totalPages
                        ? () {
                            _pdfViewerController.nextPage();
                          }
                        : null,
                  ),
                  // Page indicator
                  Text(
                    '$_currentPage / $_totalPages',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Previous page button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: _currentPage > 1
                        ? () {
                            _pdfViewerController.previousPage();
                          }
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
