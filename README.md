# Image proposal with cropping flow

This repository contains a swift iOS project, that uses nyris SDK to take an image, see suggested objects from the image and enable custom cropping.

# Structure

## Camera
This is handled by `ImageCaptureController.swift` a subclass of `CameraController.swift` which uses nyris `CameraManager.swift` to handle Camera permission and setup.

`ImageCaptureController` offers the possibility to take a picture, loads its object proposal from nyris API, and send it to Object proposal and cropping screen

## Object proposal and Cropping
This is managed by `CropController.swift`, This screen will display the previously taken image, and layout the objects that nyris SDK found on the image. If the user clicks on an object, it will provide the possibility to change the object cropping.

Once the user validate the object and its size, the `CropController` will find offers and takes the user to results screen.

## nyris service
You can either use the nyris SDK if you wanna use `CropController` directly or you can use wrapper arround it called `VisualSearchService` that allows you to get both Object proposal and Offers at the same time.

## Navigation
The navigation is done with the help of `DataTransferProtocol` This is a simple protocol that helps passing data between controllers. You can use your own system.

## Localization
The project doesn't support localization since every client has their own implementation for localization. 


# Integration
You need a nyris api key and the nyris SDK to be able to use this project.
If you want to start the flow:
```swift
        // use CropController if you want to start from Crop controller
        let startingPoint = "ImageCaptureController"
        let storyboard = UIStoryboard(name: startingPoint, bundle: Bundle.main)
        let captureController = storyboard.instantiateViewController(withIdentifier: startingPoint) as! ImageCaptureController
        
        // If you start with CropController, make sure to pass
        // - Image we want to search for 
        // - List of objects you get from ImageMatchingService's getExtractObjects method 
        controller.transfer(data: (image:image, offers:offers, boxes:boxes))
        // or any other type of navigation
        self.navigationController.pushViewController(captureController, animated: false)
```

# Product result
You can modify or bring your own product result page.