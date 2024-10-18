# Steps to Run the App
Open in Xcode 16.0(or higher) and run on any iPhone or iPhone simulator

# Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
I mainly focused on loading and caching the recipes and recipe photos instead of creating a unique or incredibly interesting UI. It felt more appropraite to display my ability to handle complex network tasks for this project.

# Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent about 8 hours on this. I started by setting up and verifying network protocols, and then created the UI at the end.

# Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
For the sake of time I didn't mkae the UI as intersting as I could have, but I think it still looks nice. I would have liked to build the the UI with SwiftUI, but I decided to use UIKit for speeds sake since I am very familar with UICollectionView

# Weakest Part of the Project: What do you think is the weakest part of your project?
I noticed at the end that I am not properly decoding some utf-8 special characters in the JSON data! I did some poking around and I THINK it's because the JSON data is compressed with Brotli compression and I don't have it properly set-up to decompress that, but I didn't have time to further investiagte and left it as is.

I also didn't dp a crazy amount of unit testing, just basic stuff for my networking classes.

# External Code and Dependencies: Did you use any external code, libraries, or dependencies?
Yes, I re-used some of my own code for the networking classes! No need to re-build the wheel =)

# Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
I had a fun time building this! Thanks for the opportunity to be considered for this role. I look forward to hearing back!

