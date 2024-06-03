//
//  ViewController.swift
//  IOSApp1
//
//  Created by Owner on 2024-05-24.
//

import UIKit

class ViewController: UIViewController {
    
    // UI elements
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private let randomButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Random Photo", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Next Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Previous Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let slideshowButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("Start Slideshow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let photoIndexLabel: UILabel = {
        let label = UILabel()
        label.text = "Photo 1"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let slideshowStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Slideshow: Stopped"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    // Properties for managing photos and slideshow
    private var photoURLs: [String] = []
    private var currentIndex: Int = 0
    private var slideshowTimer: Timer?
    private var isSlideshowRunning = false
    
    private let colors: [UIColor] = [
        .systemRed, .systemGreen, .systemCyan, .systemOrange, .systemYellow, .systemPurple, .systemPink
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemCyan
        
        // Add UI elements to the view
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        
        view.addSubview(randomButton)
        view.addSubview(nextButton)
        view.addSubview(prevButton)
        view.addSubview(slideshowButton)
        view.addSubview(photoIndexLabel)
        view.addSubview(slideshowStatusLabel)
        
        // Fetch photo URLs and update the initial photo
        fetchPhotoURLs {
            self.updatePhoto()
        }
        
        // Add target actions for buttons
        randomButton.addTarget(self, action: #selector(didTapRandomButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(didTapPrevButton), for: .touchUpInside)
        slideshowButton.addTarget(self, action: #selector(didTapSlideshowButton), for: .touchUpInside)
    }
    
    @objc func didTapRandomButton() {
        // Fetch and display a random photo
        getRandomPhoto()
        view.backgroundColor = colors.randomElement()
    }
    
    @objc func didTapNextButton() {
        // Show the next photo in the array
        guard !photoURLs.isEmpty else { return }
        currentIndex = (currentIndex + 1) % photoURLs.count
        updatePhoto()
    }
    
    @objc func didTapPrevButton() {
        // Show the previous photo in the array
        guard !photoURLs.isEmpty else { return }
        currentIndex = (currentIndex - 1 + photoURLs.count) % photoURLs.count
        updatePhoto()
    }
    
    @objc func didTapSlideshowButton() {
        // Start or stop the slideshow
        if isSlideshowRunning {
            stopSlideshow()
        } else {
            startSlideshow()
        }
    }
    
    private func startSlideshow() {
        // Start a timer to show the next photo every 2 seconds
        slideshowTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(showNextPhoto), userInfo: nil, repeats: true)
        slideshowStatusLabel.text = "Slideshow: Running"
        slideshowButton.setTitle("Stop Slideshow", for: .normal)
        isSlideshowRunning = true
    }
    
    private func stopSlideshow() {
        // Stop the slideshow timer
        slideshowTimer?.invalidate()
        slideshowTimer = nil
        slideshowStatusLabel.text = "Slideshow: Stopped"
        slideshowButton.setTitle("Start Slideshow", for: .normal)
        isSlideshowRunning = false
    }
    
    @objc private func showNextPhoto() {
        // Show the next photo in the array
        guard !photoURLs.isEmpty else { return }
        currentIndex = (currentIndex + 1) % photoURLs.count
        updatePhoto()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Layout the UI elements
        randomButton.frame = CGRect(
            x: 30,
            y: view.frame.size.height - 250 - view.safeAreaInsets.bottom,
            width: view.frame.size.width - 60,
            height: 55
        )
        
        nextButton.frame = CGRect(
            x: 30,
            y: randomButton.frame.maxY + 20,
            width: (view.frame.size.width - 90) / 2,
            height: 55
        )
        
        prevButton.frame = CGRect(
            x: nextButton.frame.maxX + 30,
            y: randomButton.frame.maxY + 20,
            width: (view.frame.size.width - 90) / 2,
            height: 55
        )
        
        slideshowButton.frame = CGRect(
            x: 30,
            y: nextButton.frame.maxY + 20,
            width: view.frame.size.width - 60,
            height: 55
        )
        
        photoIndexLabel.frame = CGRect(
            x: 30,
            y: slideshowButton.frame.maxY + 20,
            width: view.frame.size.width - 60,
            height: 45
        )
        
        slideshowStatusLabel.frame = CGRect(
            x: 30,
            y: photoIndexLabel.frame.maxY + 10,
            width: view.frame.size.width - 60,
            height: 45
        )
    }
    
    private func updatePhoto() {
        // Update the image view with the current photo
        guard !photoURLs.isEmpty else { return }
        let urlString = photoURLs[currentIndex]
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
                    self.photoIndexLabel.text = "Photo \(self.currentIndex + 1)"
                } else {
                    print("Failed to create image from data")
                }
            }
        }
        task.resume()
    }
    
    private func fetchPhotoURLs(completion: @escaping () -> Void) {
        // Fetch a list of photo URLs from the API
        let urlString = "https://picsum.photos/v2/list"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch photo URLs: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data fetched")
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    for json in jsonArray {
                        if let urlString = json["download_url"] as? String {
                            self.photoURLs.append(urlString)
                        }
                    }
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func getRandomPhoto() {
        // Fetch and display a random photo
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
