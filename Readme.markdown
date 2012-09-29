SimplePopoverView
=================

This project is a very simple version of the `UIPopoverController` for iOS. I wanted to create a simple, easy to use and flexible popover view for *iPhone* and *iPad*. Existing projects aim to copy the UIPopoverController functionality. I created a new implementation from scratch, optimized for iOS 6.0, to be used for any purpose.

The class uses the `QuartzCore` framework to draw the popover, so there is no need to include any additional resources. The code is very compact (only *369 lines*) any easy to understand. Simply create a popover instance, snap it to a anchor view or origin point, set the content size and add any subview. That's it.

Please give support so I can continue to make SimplePopoverView even more awesome!

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4S886F7EHPR6Q">
<img src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!" />
</a>

Your help is much appreciated. Please send pull requests for useful additions you make or ask me what work is required.

Credits
-------

Credits go to [mobilebricks](http://www.mobilebricks.com) for their [ALPopoverView](http://www.mobilebricks.com/ios/alpopoverview), for the basic idea and to [AllFreeVectors](http://www.allfreevectors.com) for the beautiful background image for the demo app.

License
-------

It is open source and covered by a standard MIT license. That means you have to mention *Kristian Kraljic (dikrypt.com, ksquared.de)* as the original author of this code. You can purchase a Non-Attribution-License from me.

Documentation
-------------

*Sorry, I'm to lazy to create a documentation for a single class…* ~~Documentation can be [browsed online](http://kayk.github.com/SimplePopoverView) or installed in your Xcode Organizer via the [Atom Feed URL](http://kayk.github.com/SimplePopoverView/SimplePopoverView.atom).~~

Usage
-----

SimplePopoverView needs a minimum iOS deployment target of 4.3 because of:

- QuartzCore
- Blocks
- ARC

The best way to use SimplePopoverView with Xcode 4.2 is to add the source files to your Xcode project with the following steps.

1. Download SimplePopoverView as a subfolder of your project folder
2. Open the destination project and drag the folder as a subordinate item in the Project Navigator (Copy all classes and headers)
3. In your prefix.pch file add:
	
		#import "SimplePopoverView.h"

4. In your application target's Build Phases add the following framework to the Link Binary With Libraries phase (you can also do this from the Target's Summary view in the Linked Frameworks and Libraries):

		QuartzCore.framework

5. Go to File: Project Settings… and change the derived data location to project-relative.
6. Add the DerivedData folder to your git ignore. 
7. In your application's target Build Settings:
	- If your app does not use ARC yet (but SimplePopoverView does) then you need to add the the -fobjc-arc linker flag to the app target's "Other Linker Flags".

If you do not want to deal with Git submodules simply add SimplePopoverView to your project's git ignore file and pull updates to SimplePopoverView as its own independent Git repository. Otherwise you are free to add SimplePopoverView as a submodule.

Known Issues
------------

*None, so far… Yay!*

If you find an issue then you are welcome to fix it and contribute your fix via a GitHub pull request.