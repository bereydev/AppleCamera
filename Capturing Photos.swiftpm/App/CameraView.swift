/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

//This view is our main with all buttons:
// 1 - to check the gallery
// 2 - to take a photo
// 3 - to rotate camera

struct CameraView: View {
    @StateObject private var model = DataModel()
    // model is for accessing our model file with all functionality, below we will use model.camera to access it's functionality
 
    private static let barHeightFactor = 0.15
    // used to move our bar with buttons up
    
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(image:  $model.viewfinderImage )
                    .overlay(alignment: .top) {
                        Color.black
                            .opacity(0.75)
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                        // some space at the top of the screen 1/6 of the whole screen. it's located over our camera, creating a nice effect of opacity
                    }
                    .overlay(alignment: .bottom) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.black.opacity(0.75))
                        // some space at the bottom where we placing our buttons, size the same as at the top. it's located over our camera, creating a nice effect of opacity
                    }
                    .overlay(alignment: .center)  {
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                        // and here is our main space, 4/6 size of the screen, here we can see our camera.
                    }
                    .background(.black)
            }
            .task {
                await model.camera.start() // starting our camera
                await model.loadPhotos() // loading photos to our photo collection
                await model.loadThumbnail() // stands for the image icon on the left side of our camera. This info is from what i found, commenting this line is not changing anything.
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Spacer()
            
            NavigationLink {
                PhotoCollectionView(photoCollection: model.photoCollection)
                    .onAppear {
                        model.camera.isPreviewPaused = true
                        //Pausing our preview when we are in gallery
                    }
                    .onDisappear {
                        model.camera.isPreviewPaused = false
                        //Starting out preview when we are leaving the gallery
                    }
            } label: {
                Label {
                    Text("Gallery")
                } icon: {
                    ThumbnailView(image: model.thumbnailImage)
                    //This line is responsible for showing small image on the left side to go into the gallery
                }
            }
            
            Button {
                model.camera.takePhoto()
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            // Button for taking photo
            
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            // button for switching camera
            
            Spacer()
        
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
    
}


// Added here the preview just to test and see the difference in some functionality
struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

