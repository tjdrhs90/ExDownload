//
//  ViewController.swift
//  ExDownload
//
//  Created by ssg on 12/12/23.
//

import UIKit

class ViewController: UIViewController {
    
    // 예시: 다운로드할 파일의 URL
    let fileURLString = "https://www.africau.edu/images/default/sample.pdf"
    
    override func viewDidAppear(_ animated: Bool) {
        
        downloadFile(urlString: fileURLString) { localFileURL in
            if let localFileURL = localFileURL {
                // 다운로드 및 저장이 성공하면 파일을 공유
                Task { @MainActor in
                    self.shareFile(fileURL: localFileURL)
                }
            } else {
                print("파일 다운로드 및 저장 실패")
            }
        }
    }
    
    func downloadFile(urlString: String, completion: @escaping (URL?) -> Void) {
        guard let fileURL = URL(string: urlString) else {
            print("잘못된 URL 형식")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: fileURL) { (tempLocalURL, response, error) in
            if let tempLocalURL = tempLocalURL, error == nil {
                // 다운로드 성공시 로컬 파일로 이동
                let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileURL.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: destinationURL.path) { // 경로에 이미 파일 존재 하는 경우
                    try? FileManager.default.removeItem(at: destinationURL) // 제거
                }
                do {
                    try FileManager.default.moveItem(at: tempLocalURL, to: destinationURL)
                    print("다운로드 및 저장 성공: \(destinationURL)")
                    completion(destinationURL)
                } catch {
                    print("파일 이동 오류: \(error)")
                    completion(nil)
                }
            } else {
                print("다운로드 오류: \(error?.localizedDescription ?? "알 수 없는 오류")")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func shareFile(fileURL: URL) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        // iPad에서는 팝오버로 표시
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
        }
        
        // 액티비티 뷰 컨트롤러 표시
        present(activityViewController, animated: true)
    }
}
