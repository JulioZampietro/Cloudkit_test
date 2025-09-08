# Cloudkit_test
A test project for me to learn and apply CloudKit

SwiftUI / CloudKit

## Project overview
A learning project in which I implemented code for a to-do app based on AzamSharp's tutorial and project (see https://github.com/azamsharp/TaskAppCloudKit/tree/main/TaskTracker). Afterwards, I included a tab bar with two new features: a button for uploading videos for the iCloud database, and a feed view to display and delete these videos.

## Features
To-do functionalities (add / delete / filter tasks)
Upload video to iCloud
Fetch, watch and delete videos from iCloud

## Configuration guides
For this app to function, you must configure its connection to iCloud and define the data structure in the CloudKit Dashboard. Follow these steps carefully.

### 1. Configure the Xcode Project
First, you need to link the app to your own Apple Developer account and CloudKit container.

Open the project in Xcode and select the project file in the Navigator pane.

Go to the Signing & Capabilities tab.

Change the Bundle Identifier to something unique, like com.yourname.cloudkittest.

Click + Capability and add iCloud.

In the iCloud section, check the CloudKit service.

Under Containers, click the + button and create a new container that matches your unique bundle identifier (e.g., iCloud.com.yourname.cloudkittest). Xcode might do this for you automatically.

### 2. Set Up the Schema in CloudKit Dashboard
Now, you need to tell CloudKit what kind of data your app will save. You'll create two "Record Types," which are like blueprints for your data.

Go to the CloudKit Dashboard.

Select the container you created in the previous step.

Navigate to the Schema section in the sidebar.

Make sure you are in the Private Database. All data for this app is stored privately for each user.

Follow the instructions below to create two new record types.

### Record Type 1: TaskItem
This record stores the to-do list items.

Click New Type and name it TaskItem.

Add the following custom fields by clicking New Field:

| Field Name	|  Field Type |
| --- | --- |
| title  | 	String |
| dateAssigned  | 	Date/Time |
| isCompleted  | 	Int (64-bit) |

Add an Index: Your code sorts tasks by their assigned date. To make this work efficiently, you must create an index.

Click Indexes for the TaskItem type.

Click Add Index.

For Index Type, select SORTABLE.

For Field, select dateAssigned.

Click Save.

### Record Type 2: Videos
This record stores the user-uploaded videos.

Click New Type and name it Videos.

Add the following custom fields:

| Field Name  |  Field Type |
| --- | --- |
| title  |  String |
| videoFile  |  Asset |


## Future steps
As this learning project was created in the context of a broader project that is already being implemented, I will probably never add funcitonalities to it. Nonetheless, a plausible next step would be to implement users, so that different people can send videos to a public database.

