//
//  VideoGenerator.swift
//  Prodo-iOS
//
//  Created by Jean Pierre on 6/19/18.
//  Copyright © 2018 Jean Pierre. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Firebase

protocol VideoProgress {
    func updateUI(string: String, progress: Progress?)
}
class VideoGenerator {
    let composition: CardComposition
    var delegate: VideoProgress!
    
    init(with: CardComposition) {
        self.composition = with
    }
    
    func StartProcess(forDeviceID: String, completion: @escaping (_ videolink: URL) -> ()) {
        delegate.updateUI(string: "Starting export...", progress: nil)
        
        let mixComposition = AVMutableComposition()
        let videoComposition = CreateVideoComposition(forCard: composition.cards[0], editorSize: composition.editorWindowSize, mixComposition: mixComposition)
        
        let width = composition.editorWindowSize.width
        let height = composition.editorWindowSize.height

        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        parentLayer.isGeometryFlipped = true
        videoLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        videoLayer.isGeometryFlipped = true
        
        let background = CALayer()
        background.frame = CGRect(x: 0, y: 0, width: width, height: height)
        background.contents = self.composition.cards[0].backgroundImage.cgImage
        background.masksToBounds = true
        parentLayer.addSublayer(background)
        
        for asset in composition.cards[0].assets {
            parentLayer.addSublayer(ConvertAssetToCALayer(asset: asset))
        }
        
       
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = documentsPath + "/FinalVid\(String(arc4random())).mp4"
        let urlexport = URL(fileURLWithPath: path)
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPreset1920x1080)
        
        exporter?.outputURL = urlexport
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = videoComposition
        exporter?.exportAsynchronously(completionHandler: {
            if exporter?.error == nil {
                print("success creating m4a")
                completion(urlexport)
            }
            
            
            let storage = Storage.storage()
            let storageRef  = storage.reference()
            let riversRef =  storageRef.child("\(forDeviceID)/video.mp4")
            
            DispatchQueue.main.async {
                self.uploadThumbnail(forDeviceID: forDeviceID, video: urlexport)
                
                self.delegate.updateUI(string: "Uploading video...", progress: nil)
                let uploadTask = riversRef.putFile(from: urlexport , metadata: nil) { metadata, error in
                    riversRef.downloadURL { (url, error) in
                        guard let downloadURL = url else { return }
                        
                        let body = ["contentLinks": downloadURL.absoluteString,"deviceId": forDeviceID]
                        URLSessionHelper.apiWithAuth(url: "/publish", user: User.currentUser()!, methodType: "POST", body: body, completion: { (res) in
                            print(res)
                        })
                    }
                }
                
                let _ = uploadTask.observe(.progress) { snapshot in
                    // A progress event occured
                    self.delegate.updateUI(string: "Uploading video...", progress: snapshot.progress)
                }
            }
        })
    }
    
    func uploadThumbnail(forDeviceID: String, video: URL) {
        let storage = Storage.storage()
        let storageRef  = storage.reference()
        let riversRef =  storageRef.child("\(forDeviceID)/thumbnail/thumbnail.png")
        riversRef.putFile(from: getThumbnail(forVideo: video)! , metadata: nil) { metadata, error in
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                let body = ["thumbnailLink": downloadURL.absoluteString]
                URLSessionHelper.apiWithAuth(url: "/device/\(forDeviceID)", user: User.currentUser()!, methodType: "POST", body: body, completion: { (res) in
                    print(res)
                })
            }
        
        }
    }
    
    func getThumbnail(forVideo:URL) -> URL? {
        let asset = AVURLAsset(url: forVideo)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let image: CGImage
        do {
            image = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            if let filePath = paths.first?.appendingPathComponent("temp.png") {
                try UIImagePNGRepresentation(UIImage(cgImage: image))?.write(to: filePath, options: .atomic)
                return filePath
            }
        }
        catch { print(error)}
        return nil
    }
    
    func CreateVideoComposition(forCard: Card, editorSize: CGSize, mixComposition: AVMutableComposition) -> AVMutableVideoComposition  {
        let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let urlpath = Bundle.main.path(forResource: "video", ofType: ".mov")
        let url = URL(fileURLWithPath: urlpath!)
        let videoasset = AVAsset.init(url: url)
        
        do {
            try videoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoasset.duration), of: videoasset.tracks(withMediaType: AVMediaType.video).first!, at: kCMTimeZero)
        }
        catch {
            print(error)
        }
        
        let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack!)
        let scale = CGFloat(1.0)
        let transform = CGAffineTransform.init(scaleX: CGFloat(scale), y: CGFloat(scale))
        videolayerInstruction.setTransform(transform, at: kCMTimeZero)
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoasset.duration)
        mainInstruction.layerInstructions = [videolayerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: editorSize.width, height: editorSize.height)
        videoComposition.instructions = [mainInstruction]
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderScale = 1.0
        
        delegate.updateUI(string: "Finished exporting video...", progress: nil)
        
        return videoComposition
    }

    
//    func converToOutput(forRect: CGRect, outputSize: CGSize ) -> CGRect {
//        let hightMultiplier = outputSize.height /
//        return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width/1920, height: )
//        
//    }
    
    func ConvertAssetToCALayer(asset: Asset) -> CALayer {

        if let asset = asset as? Icon {
            let  CAIcon = CALayer()
            CAIcon.frame = CGRect(x: (asset.frame.origin.x), y: (asset.frame.origin.y), width: (asset.frame.width), height: (asset.frame.height))
                CAIcon.contents = asset.previewImage.cgImage
            CAIcon.masksToBounds = true
            return CAIcon
        }
        else if let asset = asset as? Text {
            let CAText = CATextLayer()
             CAText.frame = CGRect(x: (asset.frame.origin.x), y: (asset.frame.origin.y), width: (asset.frame.width), height: (asset.frame.height))
            CAText.font = asset.font
            CAText.string = asset.textLabel.text
            CAText.alignmentMode = kCAAlignmentCenter
            return CAText

        }
        return CALayer()
    }
}
//    struct TransitionComposition {
//
//        let composition: AVComposition
//
//        let videoComposition: AVVideoComposition
//
//        func makePlayable() -> AVPlayerItem {
//            let playerItem = AVPlayerItem(asset: composition.copy() as! AVAsset)
//            playerItem.videoComposition = self.videoComposition
//            return playerItem
//        }
//
//        func makeExportSession(preset: String, outputURL: NSURL, outputFileType: String) -> AVAssetExportSession? {
//            let session = AVAssetExportSession(asset: composition, presetName: preset)
//            session?.outputFileType = AVFileType(rawValue: outputFileType)
//            session?.outputURL = outputURL as URL
//            session?.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
//            session?.videoComposition = videoComposition
//            session?.canPerformMultiplePassesOverSourceMediaData = true
//            return session
//        }
//    }
//
//    struct TransitionCompositionBuilder {
//
//        let assets: [AVAsset]
//
//        private var transitionDuration: CMTime
//
//        private var composition = AVMutableComposition()
//
//        private var compositionVideoTracks = [AVMutableCompositionTrack]()
//
//        init?(assets: [AVAsset], transitionDuration: Float64 = 0.3) {
//
//            guard !assets.isEmpty else { return nil }
//
//            self.assets = assets
//            self.transitionDuration = CMTimeMakeWithSeconds(transitionDuration, 600)
//        }
//
//        mutating func buildComposition() -> TransitionComposition {
//
//            var durations = assets.map { $0.duration }
//
//            durations.sorted(by:{
//                CMTimeCompare($0, $1) < 1
//            })
//
//            // Make transitionDuration no greater than half the shortest video duration.
//            let shortestVideoDuration = durations[0]
//            var halfDuration = shortestVideoDuration
//            halfDuration.timescale *= 2
//            transitionDuration = CMTimeMinimum(transitionDuration, halfDuration)
//
//            // Now call the functions to do the preperation work for preparing a composition to export.
//            // First create the tracks needed for the composition.
//            buildCompositionTracks(composition: composition,
//                                   transitionDuration: transitionDuration,
//                                   assets: assets)
//
//            // Create the passthru and transition time ranges.
//            let timeRanges = calculateTimeRanges(transitionDuration: transitionDuration,
//                                                 assetsWithVideoTracks: assets)
//
//            // Create the instructions for which movie to show and create the video composition.
//            let videoComposition = buildVideoCompositionAndInstructions(
//                composition: composition,
//                passThroughTimeRanges: timeRanges.passThroughTimeRanges,
//                transitionTimeRanges: timeRanges.transitionTimeRanges)
//
//            return TransitionComposition(composition: composition, videoComposition: videoComposition)
//        }
//
//        /// Build the composition tracks
//        private mutating func buildCompositionTracks(composition: AVMutableComposition,
//                                                     transitionDuration: CMTime,
//                                                     assets: [AVAsset]) {
//
//            let compositionVideoTrackA = composition.addMutableTrack(withMediaType: AVMediaType.video,
//                                                                                  preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
//
//            let compositionVideoTrackB = composition.addMutableTrack(withMediaType: AVMediaType.video,
//                                                                                  preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
//
//            let compositionAudioTrackA = composition.addMutableTrack(withMediaType: AVMediaType.audio,
//                                                                                  preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
//
//            let compositionAudioTrackB = composition.addMutableTrack(withMediaType: AVMediaType.audio,
//                                                                                  preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
//
//            compositionVideoTracks = [compositionVideoTrackA, compositionVideoTrackB] as! [AVMutableCompositionTrack]
//            let compositionAudioTracks = [compositionAudioTrackA, compositionAudioTrackB]
//
//            var cursorTime = kCMTimeZero
//
//            for i in 0..<assets.count {
//
//                let trackIndex = i % 2
//
//                let currentVideoTrack = compositionVideoTracks[trackIndex]
//                let currentAudioTrack = compositionAudioTracks[trackIndex]
//
//                let assetVideoTrack = assets[i].tracks(withMediaType: AVMediaType.video)[0]
//                let assetAudioTrack = assets[i].tracks(withMediaType: AVMediaType.audio)[0]
//
//                currentVideoTrack.preferredTransform = assetVideoTrack.preferredTransform
//
//                let timeRange = CMTimeRangeMake(kCMTimeZero, assets[i].duration)
//
//                do {
//                    try currentVideoTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: cursorTime)
//                    try currentAudioTrack?.insertTimeRange(timeRange, of: assetAudioTrack, at: cursorTime)
//
//                } catch let error as NSError {
//                    print("Failed to insert append track: \(error.localizedDescription)")
//                }
//
//                // Overlap clips by tranition duration
//                cursorTime = CMTimeAdd(cursorTime, assets[i].duration)
//                cursorTime = CMTimeSubtract(cursorTime, transitionDuration)
//            }
//        }
//
//        /// Calculate both the pass through time and the transition time ranges.
//        private func calculateTimeRanges(transitionDuration: CMTime,
//                                         assetsWithVideoTracks: [AVAsset])
//            -> (passThroughTimeRanges: [NSValue], transitionTimeRanges: [NSValue]) {
//
//                var passThroughTimeRanges = [NSValue]()
//                var transitionTimeRanges = [NSValue]()
//                var cursorTime = kCMTimeZero
//
//                for i in 0..<assetsWithVideoTracks.count {
//
//                    let asset = assetsWithVideoTracks[i]
//                    var timeRangeValue = CMTimeRangeMake(cursorTime, asset.duration)
//
//                    if i > 0 {
//                        timeRangeValue.start = CMTimeAdd(timeRangeValue.start, transitionDuration)
//                        timeRangeValue.duration = CMTimeSubtract(timeRangeValue.duration, transitionDuration)
//                    }
//
//                    if i + 1 < assetsWithVideoTracks.count {
//                        timeRangeValue.duration = CMTimeSubtract(timeRangeValue.duration, transitionDuration)
//                    }
//
//                    passThroughTimeRanges.append(NSValue(timeRange:timeRangeValue))
//                    cursorTime = CMTimeAdd(cursorTime, asset.duration)
//                    cursorTime = CMTimeSubtract(cursorTime, transitionDuration)
//
//                    if i + 1 < assetsWithVideoTracks.count {
//                        timeRangeValue = CMTimeRangeMake(cursorTime, transitionDuration)
//                        transitionTimeRanges.append(NSValue(timeRange:timeRangeValue))
//                    }
//                }
//                return (passThroughTimeRanges, transitionTimeRanges)
//        }
//
//        // Build the video composition and instructions.
//        private func buildVideoCompositionAndInstructions(composition: AVMutableComposition,
//                                                          passThroughTimeRanges: [NSValue],
//                                                          transitionTimeRanges: [NSValue])
//            -> AVMutableVideoComposition {
//
//                var instructions = [AVMutableVideoCompositionInstruction]()
//
//                /// http://www.stackoverflow.com/a/31146867/1638273
//                let videoTracks = compositionVideoTracks // guaranteed the correct time range
//                let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
//
//                let videoWidth: CGFloat
//                let videoHeight: CGFloat
//
//                let transform: CGAffineTransform
//
//                let videoAngleInDegree  = atan2(videoTracks[0].preferredTransform.b, videoTracks[0].preferredTransform.a) * 180 / CGFloat(Double.pi)
//
//                if videoAngleInDegree == 90 {
//
//                    videoWidth = composition.naturalSize.height
//                    videoHeight = composition.naturalSize.width
//                    transform = videoTracks[0].preferredTransform.concatenating(CGAffineTransform(translationX: videoWidth, y: 0.0))
//
//                } else {
//
//                    transform = videoTracks[0].preferredTransform
//                    videoWidth = composition.naturalSize.width
//                    videoHeight = composition.naturalSize.height
//                }
//
//                // Now create the instructions from the various time ranges.
//                for i in 0..<passThroughTimeRanges.count {
//
//                    let trackIndex = i % 2
//                    let currentVideoTrack = videoTracks[trackIndex]
//
//                    let passThroughInstruction = AVMutableVideoCompositionInstruction()
//                    passThroughInstruction.timeRange = passThroughTimeRanges[i].timeRangeValue
//
//                    let passThroughLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: currentVideoTrack)
//
//                    passThroughLayerInstruction.setTransform(transform, at: kCMTimeZero)
//
//                    // You can use it to debug.
//                    //                passThroughLayerInstruction.setTransformRampFromStartTransform(CGAffineTransformIdentity, toEndTransform: transform, timeRange: passThroughTimeRanges[i].CMTimeRangeValue)
//
//                    passThroughInstruction.layerInstructions = [passThroughLayerInstruction]
//
//                    instructions.append(passThroughInstruction)
//
//                    if i < transitionTimeRanges.count {
//
//                        let transitionInstruction = AVMutableVideoCompositionInstruction()
//                        transitionInstruction.timeRange = transitionTimeRanges[i].timeRangeValue
//
//                        // Determine the foreground and background tracks.
//                        let fromTrack = videoTracks[trackIndex]
//                        let toTrack = videoTracks[1 - trackIndex]
//
//                        let fromLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: fromTrack)
//                        fromLayerInstruction.setTransform(transform, at: kCMTimeZero)
//
//                        // Make the opacity ramp and apply it to the from layer instruction.
//                        fromLayerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity:0.0, timeRange: transitionInstruction.timeRange)
//
//                        let toLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: toTrack)
//                        toLayerInstruction.setTransform(transform, at: kCMTimeZero)
//
//                        transitionInstruction.layerInstructions = [fromLayerInstruction, toLayerInstruction]
//
//                        instructions.append(transitionInstruction)
//
//                    }
//                }
//
//                videoComposition.instructions = instructions
//                videoComposition.frameDuration = CMTimeMake(1, 30)
//                videoComposition.renderSize = CGSize(width: videoWidth, height: videoHeight)
//
//                return videoComposition
//        }
//    }
//}


