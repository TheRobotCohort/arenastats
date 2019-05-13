# ArenaStats for Halo 5: Guardians

ArenaStats is an iOS app (11.0 and above) that uses the official Halo API to diplay player and match statistics.

* Code is Swift 4 with the exception of the SWRevealViewController, which is Objective-C.
* There's some legacy patterns around Notification Observers.
* StoryBoard could use some TLC
* Hackathon qulity code scattered through out

Pull Requests welcome, issues too.

https://itunes.apple.com/us/app/arena-stats-for-halo-5/id1071676473?mt=8

If you build and release your own version, make sure to comply with Microsoft's Game Content Rules https://www.xbox.com/en-us/developers/rules


## Getting Started

### Requirements

Halo API Key (https://developer.haloapi.com)

Cocoa Pods (https://cocoapods.org)

### Optional Requirements

Google Ad-Mob Account
App Store / iTunesConnect ID

### Setup

#### 1. Clone GitHub Repo

```
git clone https://github.com/TheRobotCohort/arenastats.git ./path/to/arenastats
```

#### 2. Install Pods

```
cd path/to/arenastats
pod install
```

#### 3. Open Pod Workspace

```
open H5S.xcworkspace/
```

#### 4. Settings / Build

Update `Config.swift` in the project root. In order to connect to the Halo API service you'll need to populate `SUBSCRIPTION_KEY` with a valid developer's key. See https://developer.haloapi.com for more inforamtion (it's free).

Click the build icon in Xcode or cmd-r ro run and build the project in the simulator.


## Project Timeline

Project was originally called "Halo 5 Stats" but due to a copyright claim from Microsoft was changed to (for lack of a more marketable name at the time) "H5Stats". Was rebranded to "Arena Stats for Halo 5" at some point (1.3?) but you'll still find some code refernces to "H5".

* May 2018 - **2.0.0 (Last Release)**
* November 2017 - **1.4.3**
* Aug 2017 - **1.4.2**
* January 2017 - **1.4.1**
* August 2016 - **1.4.0**
* July 2016 - **1.3.2**
* July 2016 - **1.3.1**
* May 2016 - **1.3.0**
* May 2016 - **1.2.2**
* April 2016 - **1.2.1**
* April 2016 - **1.2.0**
* February 2016 - **1.1.2**
* February 2016 - **1.1.0**
* February 2016 - **1.0.2**
* Jan 2016 - **1.0.0 (Original Release)**



