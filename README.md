Beta Release Document
BeanThere
Group 6

Test Account you can try with already populated friends and reviews:
email/user: testaccount2@gmail.com
Password: testaccount2

Contributions:
Sujitha Seenivasan (Release: 25%, Overall: 18.75%):
Created UI for the AddReview screen and all the functionalities for creating reviews and storing them into Firebase
Added reviews feed to CafeProfile screens and refactored CoffeeSearch to include aggregated ratings and tags from user reviews.
Created Coffee Connect Feed Screen by pulling reviews from friends’ activity and creating a new UI for these cells.
Set up Firebase Authentication + created login and create account screens
Table View that displays the list of cafe profiles
Search functionality within the table view that allows you to search for a cafe and the segue to click on a profile
Eshi Kohli (Release: 25%, Overal1: 18.75%):
Created the UI for the friends connect screen, the friend requests screen, and the search for friends screen
For the friends connect screen, created the logic for populating the suggested friends and created the custom UICollectionView cell class. Also attempted implementing the logic for populating the friends from contacts and created the associated custom UICollectionView cell class
For the friend requests screen, populated the TableView and created the accompanying custom UITableView cell class
For the search for friends screen, populated the TableView and created the accompanying custom UITableView cell class. Connected the cell to the FriendProfileVC.
Added necessary fields to incorporate friend adding system to each “user” collection in Firebase when an account is created (following, followers, requests, and requested lists)
Added UI to change password on Login screen and User Settings screen which will send a password reset email to the user and update their password in Firebase Authentication
Wrote Python script to fill in Firestore Database with coffee shops and their information (name, address, image, etc.) from Yelp Search API and added manual descriptions for cafes
Yrone Umutesi (Release: 25%, Overall : 18.75):
Did the UI for the UserProfile screen and the FriendsProfile 
Added the like tap, the comment sections 
Added the following and followers sections in the UserProfile screen and the FriendsProfile in firebase 
Created the Navigation Bar for the screens and set up the segues that connected it to all other screens
Created the User Setting and Edit Settings pages and connected them to firebase to import the data to and from and change it
Set up the Storage file in firebase that stores all the user’s profile pictures and updates them whenever user changes it and created a link between firebase and swift for picture upload
Sarah Fedorchak (Release: 25%, Overall: 18.75%):
Did the UI for BrewTabVC, BrewLogVC, and WantToTryVC, including table views to display the user's reviewed coffee shops and bookmarked cafés
Implemented backend functionality for these screens by fetching data from Firebase and creating a segmented control with a container view on the BrewTabs screen to enable tab switching
Embedded navigation controllers in BrewLogVC and WantToTryVC
Added bookmark functionality to the button in CafeProfileVC by creating a wantToTry field in Firebase and updating the array with the selected café
The UI for the Cafe Profile screen and did the backend for that screen which included fetching data about the coffee shops from Firestore
The UI for the Coffee Search page which included making custom cell for the Table View that displays the list of cafe profiles

Deviations
Friend suggestions from contacts aren’t fully functional yet. We’ve been working on getting this up and running, and we’re pretty sure we have most of the right code in place. That said, we’ve been running into a thread error that’s been blocking it from working properly. We’re expecting to have it fixed soon and ready to go by the next release.
The Friend Profile screen isn’t currently being populated with the correct data—it’s showing up empty. This is because when we segue from the “Search” screen to a friend’s profile, the friendID we’re trying to pass is nil, so no data is being fetched. The UI is complete, and the backend code to fetch data from Firebase is in place. For now, we’ve hardcoded a friendID so you can see what the screen is meant to look like. We’re still figuring out why the friendID isn’t coming through, but we’ve been actively working on it and are confident it’ll be fixed by Final.
Going to do the comment on the next release and removed the number for been and wantToTry on the user profiles because they weren’t needed because you can just segue and see on your brew Logs and removed the share option in the userprofiles was because we don’t have a post share action so it doesn’t make sense for our app to have a share button
One small note is that the feed isn’t populating on first load, but loads in when you navigate away and back to it. We have tried using viewWillAppear but it still doesn’t work. We will troubleshoot this more for the next release.

