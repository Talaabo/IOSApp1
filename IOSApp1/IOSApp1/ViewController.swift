//
//  ViewController.swift
//  IOSApp1
//
//  Created by Owner on 2024-05-24.
//

import UIKit

class ViewController: UIViewController {
  
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Random Photo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let colors: [UIColor] = [
        .systemRed, .systemGreen, .systemBlue, .systemOrange, .systemYellow, .systemPurple, .systemPink
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        view.addSubview(button)
        getRandomPhoto()
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton() {
        getRandomPhoto()
        view.backgroundColor = colors.randomElement()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.frame = CGRect(
            x: 30,
            y: view.frame.size.height - 150 - view.safeAreaInsets.bottom,
            width: view.frame.size.width - 60,
            height: 55
        )
    }
    
    func getRandomPhoto() {
        let urlString = "https://picsum.photos/600"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch image data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            print("HTTP Response Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data fetched")
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.imageView.image = image
                } else {
                    print("Failed to create image from data")
                }
            }
        }
        task.resume()
    }
}
