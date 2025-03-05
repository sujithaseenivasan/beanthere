//
//  UserSettingVC.swift
//  beanthere
//
//  Created by yrone umutesi on 3/4/25.
//

import UIKit
import SwiftUICore
import SwiftUI
// tabView struct
//struct TabView<SelectionValue, Content> where Selection
//Value : Hashable, Content : View

class UserSettingVC: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       //make image round
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    //Tab view for the navigation bar, By creating a tabView and assigning each tabItem to an icon
    struct NavView: View {
        var body: some View {
            TabView {
                FeedView().tabItem{
                    Image(systemName: "house")
                    Text("FEED")
                }
                ConnectView().tabItem{
                    Image(systemName: "person.2")
                    Text("CONNECT")
                }
                MapView().tabItem{
                    Image(systemName: "map")
                    Text("COFFEE MAP")
                }
                BrewLogView().tabItem{
                    Image(systemName: "cup.and.heat.waves")
                    Text("BREW LOG")
                }
                ProfileView().tabItem{
                    Image(systemName: "person.circle")
                    Text("PROFILE")
                }
            }
            .accentColor(.brown) //give the color to the tab
        }
        
    }
    
    //Views Provided
    struct FeedView : View {
        var body: some View {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
        }
    }
    struct ConnectView : View {
        var body: some View {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
        }
    }
    struct MapView : View {
        var body: some View {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
        }
    }
    struct BrewLogView : View {
        var body: some View {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
        }
    }
    struct ProfileView : View {
        var body: some View {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
        }
    }
    
}
