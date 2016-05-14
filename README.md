# wallet
Wallet Test Code

3rd party libraries: None*
It's a simple project, no finished library was necessary. *I did however reuse the modified CoreDataUtils class that wraps some basic CoreData operations like saving the context etc. Networking is using the NSURLSession with basic retry logic.

Class organization:
Standard iOS style MVC. I aimed to treat the data as financial data, hence CoreData despite the tiny model and use of Strings+NSDecimalNumber to represent balance. M->C communication is using a completion block so it's fully extendable. The WalletDisplayDelegate class has hardcoded data that would normally come from a json/plist.

Improvements
Everything! The project is set up for easy refactoring and extension but it's all basic as it is. The model resets after the load so a reload would be easy to write if this was a thin client, otherwise rearchitecting of WalletManager is necessary. WalletManager has a potential to baloon if model can be modified locally so it needs to be broken apart into read/write classes plus an API wrapper instead of doing the networking code directly in it.
In terms of model logic, it needs more points where the UI can ask for expired/valid date cards.
The UI needs a ton of work, there's no reason to have a full separate page for each wallet, a collection view would be a great choice (and since there's already core data in it, would be easy to update).
The model is reading/writing on the main thread which is great for 99% of apps and lets us avoid crashes or complicated CoreData multithreading, however this won't do if the app should show wallets for 10000+ employees.
The types of cards displayed are hardcoded when NSFetchedResultsController is reading the wallets, however they should be passed as an argument from the caller so UI controller can pick and choose which to show.
There's no feedback to the user if the load fails, they'll be stuck with a spinner.
And of course if this is supposed to go into production it desperately needs tracking and crash reporting...
